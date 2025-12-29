import Foundation

class PredictionEngine {
    
    var model: [String: Any] = [:]
    
    // MARK: - Autocorrect Properties
    var validWords: Set<String> = []  // Fast O(1) lookup for valid words
    var wordFrequencies: [String: Double] = [:]  // Word frequencies for ranking corrections
    
    // Valid Kurdish letters (including special characters)
    let validLetters = CharacterSet(charactersIn: "abcçdefghijklmnopqrstuvwxyzêîşûABCÇDEFGHIJKLMNOPQRSTUVWXYZÊÎŞÛ")
    
    // Keyboard adjacency map for Kurdish keyboard (keys that are physically close)
    let keyboardAdjacency: [Character: Set<Character>] = [
        "q": ["w", "a"],
        "w": ["q", "e", "a", "s"],
        "e": ["w", "r", "s", "d"],
        "r": ["e", "t", "d", "f"],
        "t": ["r", "y", "f", "g"],
        "y": ["t", "u", "g", "h"],
        "u": ["y", "i", "h", "j"],
        "i": ["u", "o", "j", "k"],
        "o": ["i", "p", "k", "l"],
        "p": ["o", "ê", "l", "ş"],
        "ê": ["p", "û", "ş", "î"],
        "û": ["ê", "î"],
        "a": ["q", "w", "s", "z"],
        "s": ["a", "w", "e", "d", "z", "x"],
        "d": ["s", "e", "r", "f", "x", "c"],
        "f": ["d", "r", "t", "g", "c", "v"],
        "g": ["f", "t", "y", "h", "v", "b"],
        "h": ["g", "y", "u", "j", "b", "n"],
        "j": ["h", "u", "i", "k", "n", "m"],
        "k": ["j", "i", "o", "l", "m", "ç"],
        "l": ["k", "o", "p", "ş"],
        "ş": ["l", "p", "ê", "î"],
        "î": ["ş", "ê", "û"],
        "z": ["a", "s", "x"],
        "x": ["z", "s", "d", "c"],
        "c": ["x", "d", "f", "v"],
        "v": ["c", "f", "g", "b"],
        "b": ["v", "g", "h", "n"],
        "n": ["b", "h", "j", "m"],
        "m": ["n", "j", "k", "ç"],
        "ç": ["m", "k"]
    ]
    
    init() {
        loadModel()
    }
    
    // MARK: - Data Validation
    /// Check if a string is a clean word (only Kurdish letters, no garbage)
    func isCleanWord(_ word: String) -> Bool {
        // Must have at least 1 character
        guard word.count >= 1 else { return false }
        
        // Must only contain valid Kurdish letters
        let wordChars = CharacterSet(charactersIn: word)
        guard validLetters.isSuperset(of: wordChars) else { return false }
        
        return true
    }
    
    func loadModel() {
        guard let path = Bundle.main.path(forResource: "kurmanji_model_optimized", ofType: "json") else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.model = json
                    
                    // Extract vocabulary from unigrams for autocorrect
                    self.extractVocabulary()
                    
                    print("✅ Brain Loaded (Autocorrect Version 3.0)")
                }
            } catch {
                print("❌ Error loading brain: \(error)")
            }
        }
    }
    
    // MARK: - Vocabulary Extraction
    private func extractVocabulary() {
        // Extract words from unigrams (key "1")
        if let unigrams = model["1"] as? [String: [String: Double]] {
            for (_, nextWords) in unigrams {
                for (word, frequency) in nextWords {
                    // Only add clean words (no garbage data)
                    guard isCleanWord(word) else { continue }
                    validWords.insert(word)
                    // Keep the highest frequency if word appears multiple times
                    if let existing = wordFrequencies[word] {
                        wordFrequencies[word] = max(existing, frequency)
                    } else {
                        wordFrequencies[word] = frequency
                    }
                }
            }
        }
        
        // Also extract from 2-grams for more coverage
        if let bigrams = model["2"] as? [String: [String: Double]] {
            for (contextWord, nextWords) in bigrams {
                // Only add clean words
                if isCleanWord(contextWord) {
                    validWords.insert(contextWord)
                }
                for (word, frequency) in nextWords {
                    guard isCleanWord(word) else { continue }
                    validWords.insert(word)
                    if let existing = wordFrequencies[word] {
                        wordFrequencies[word] = max(existing, frequency)
                    } else {
                        wordFrequencies[word] = frequency
                    }
                }
            }
        }
        
        print("📚 Vocabulary loaded: \(validWords.count) clean words")
    }
    
    // MARK: - Autocorrect Methods
    
    /// Check if a word is valid (exists in dictionary)
    func isValidWord(_ word: String) -> Bool {
        return validWords.contains(word.lowercased())
    }
    
    /// Calculate Levenshtein distance between two strings
    func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        // Edge cases
        if m == 0 { return n }
        if n == 0 { return m }
        
        // Create distance matrix
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        // Initialize first row and column
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        
        // Fill the matrix
        for i in 1...m {
            for j in 1...n {
                if s1Array[i - 1] == s2Array[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = 1 + min(
                        dp[i - 1][j],     // deletion
                        dp[i][j - 1],     // insertion
                        dp[i - 1][j - 1]  // substitution
                    )
                }
            }
        }
        
        return dp[m][n]
    }
    
    /// Calculate keyboard-aware distance (adjacent keys cost less)
    func keyboardAwareDistance(_ s1: String, _ s2: String) -> Double {
        let s1Array = Array(s1.lowercased())
        let s2Array = Array(s2.lowercased())
        let m = s1Array.count
        let n = s2Array.count
        
        if m == 0 { return Double(n) }
        if n == 0 { return Double(m) }
        
        var dp = Array(repeating: Array(repeating: 0.0, count: n + 1), count: m + 1)
        
        for i in 0...m { dp[i][0] = Double(i) }
        for j in 0...n { dp[0][j] = Double(j) }
        
        for i in 1...m {
            for j in 1...n {
                if s1Array[i - 1] == s2Array[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    // Check if keys are adjacent (typo more likely)
                    let char1 = s1Array[i - 1]
                    let char2 = s2Array[j - 1]
                    let adjacentKeys = keyboardAdjacency[char1] ?? []
                    
                    // Adjacent key substitution costs 0.5, non-adjacent costs 1.0
                    let substitutionCost = adjacentKeys.contains(char2) ? 0.5 : 1.0
                    
                    dp[i][j] = min(
                        dp[i - 1][j] + 1.0,                    // deletion
                        dp[i][j - 1] + 1.0,                    // insertion
                        dp[i - 1][j - 1] + substitutionCost   // substitution
                    )
                }
            }
        }
        
        return dp[m][n]
    }
    
    /// Get autocorrect suggestion for a misspelled word
    /// Returns nil if word is valid or no good correction found
    func getCorrection(for word: String) -> String? {
        let lowercased = word.lowercased()
        
        // If word is valid, no correction needed
        if isValidWord(lowercased) {
            return nil
        }
        
        // Don't correct very short words (1-2 chars) - too many false positives
        if lowercased.count < 3 {
            return nil
        }
        
        // Find candidates within edit distance threshold
        let maxDistance: Double = 2.0
        var candidates: [(word: String, distance: Double, frequency: Double)] = []
        
        // Only check words of similar length (±2 characters)
        let minLen = max(1, lowercased.count - 2)
        let maxLen = lowercased.count + 2
        
        for validWord in validWords {
            guard validWord.count >= minLen && validWord.count <= maxLen else { continue }
            
            // Quick filter: first letter should match or be adjacent
            let firstChar = lowercased.first!
            let validFirstChar = validWord.first!
            let adjacentToFirst = keyboardAdjacency[firstChar] ?? []
            
            if firstChar != validFirstChar && !adjacentToFirst.contains(validFirstChar) {
                continue
            }
            
            let distance = keyboardAwareDistance(lowercased, validWord)
            
            if distance <= maxDistance {
                let frequency = wordFrequencies[validWord] ?? 0.0
                candidates.append((validWord, distance, frequency))
            }
        }
        
        // No candidates found
        if candidates.isEmpty {
            return nil
        }
        
        // Sort by: 1) distance (lower is better), 2) frequency (higher is better)
        candidates.sort { (a, b) in
            if a.distance != b.distance {
                return a.distance < b.distance
            }
            return a.frequency > b.frequency
        }
        
        // Return best candidate if it's confident enough
        let best = candidates[0]
        
        // Only autocorrect if distance is low enough relative to word length
        // For longer words, we're more lenient
        let confidenceThreshold = lowercased.count >= 5 ? 2.0 : 1.5
        
        if best.distance <= confidenceThreshold {
            // Preserve original capitalization pattern
            return matchCapitalization(original: word, correction: best.word)
        }
        
        return nil
    }
    
    /// Match the capitalization pattern of the original word
    private func matchCapitalization(original: String, correction: String) -> String {
        if original.isEmpty { return correction }
        
        // All uppercase
        if original == original.uppercased() && original != original.lowercased() {
            return correction.uppercased()
        }
        
        // First letter uppercase (Title Case)
        if original.first?.isUppercase == true {
            return correction.prefix(1).uppercased() + correction.dropFirst()
        }
        
        // Default: lowercase
        return correction
    }
    
    func getSuggestions(for text: String) -> [String] {
        // 1. Is the user typing a new word or finishing one?
        let isTypingNewWord = text.hasSuffix(" ")
        
        var tokens = text.lowercased().split(separator: " ").map { String($0) }
        if tokens.isEmpty { return [] }
        
        var partialWord = ""
        
        // 2. If finishing a word, remove it from history so we can predict IT, not what comes AFTER it.
        if !isTypingNewWord {
            partialWord = tokens.last ?? ""
            tokens.removeLast()
        }
        
        // 3. N-Gram Lookup
        var candidates: [String] = []
        let maxN = 5
        
        for n in stride(from: maxN, through: 2, by: -1) {
            let requiredHistory = n - 1
            if tokens.count >= requiredHistory {
                let historyTokens = tokens.suffix(requiredHistory)
                let historyKey = historyTokens.joined(separator: " ")
                
                if let nGramLevel = model[String(n)] as? [String: [String: Double]],
                   let matches = nGramLevel[historyKey] {
                    
                    // Filter out garbage data - only keep clean words
                    let sortedMatches = matches
                        .filter { isCleanWord($0.key) }
                        .sorted { $0.value > $1.value }
                        .map { $0.key }
                    candidates.append(contentsOf: sortedMatches)
                    if candidates.count > 5 { break }
                }
            }
        }
        
        // 4. Filter Logic
        if isTypingNewWord {
            // Remove duplicates and return top 3
            let unique = Array(NSOrderedSet(array: candidates)) as! [String]
            return Array(unique.prefix(3))
        } else {
            // Filter candidates to only show ones starting with the partial word
            let filtered = candidates.filter { $0.hasPrefix(partialWord) }
            let unique = Array(NSOrderedSet(array: filtered)) as! [String]
            return Array(unique.prefix(3))
        }
    }
}
