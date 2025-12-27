import UIKit

class KeyboardViewController: UIInputViewController {

    // 1. The Brain
    var predictionEngine: PredictionEngine?
    
    // 2. UI Elements
    var suggestionBar: UIStackView!
    var suggestionButtons: [UIButton] = []
    var mainStackView: UIStackView!
    
    // Key Pop-up Preview
    var keyPopupView: UIView?
    var keyPopupLabel: UILabel?
    
    // 3. State Management
    enum KeyboardMode {
        case letters
        case numbers
    }
    var currentMode: KeyboardMode = .letters
    var isUppercase: Bool = false
    
    // 4. Layout Definitions
    // LOWERCASE (Standard)
    let keysLower = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "ê", "û"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ş", "î"],
        ["z", "x", "c", "v", "b", "n", "m", "ç"]
    ]
    
    // NUMBERS & SYMBOLS (Mapped to match the letter grid size roughly)
    let keysNumbers = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "/"],
        ["@", "#", "$", "&", "(", ")", "'", "\"", ":", ";", "!"],
        ["%", "*", "+", "=", "?", ",", ".", "_"]
    ]
    
    // 5. Colors - Dynamic (Light/Dark mode)
    var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
    
    // Light mode colors
    let lightBackground = UIColor(red: 210/255, green: 213/255, blue: 219/255, alpha: 1.0)
    let lightKeyNormal = UIColor.white
    let lightKeyFunction = UIColor(red: 172/255, green: 177/255, blue: 185/255, alpha: 1.0)
    let lightKeyShadow = UIColor(red: 136/255, green: 138/255, blue: 142/255, alpha: 1.0)
    let lightTextColor = UIColor.black
    
    // Dark mode colors
    let darkBackground = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    let darkKeyNormal = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)  // #4A4A4A
    let darkKeyFunction = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1.0)  // Slightly darker
    let darkKeyShadow = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
    let darkTextColor = UIColor.white
    
    // Computed properties for current theme
    var colorBackground: UIColor { isDarkMode ? darkBackground : lightBackground }
    var colorKeyNormal: UIColor { isDarkMode ? darkKeyNormal : lightKeyNormal }
    var colorKeyFunction: UIColor { isDarkMode ? darkKeyFunction : lightKeyFunction }
    var colorKeyShadow: UIColor { isDarkMode ? darkKeyShadow : lightKeyShadow }
    var colorText: UIColor { isDarkMode ? darkTextColor : lightTextColor }
    var colorDivider: UIColor { isDarkMode ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.7, alpha: 1.0) }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Brain
        DispatchQueue.global(qos: .userInitiated).async {
            self.predictionEngine = PredictionEngine()
            // Update predictions as soon as engine is ready
            DispatchQueue.main.async {
                self.updatePredictions()
            }
        }
        
        setupSuggestionBar()
        // Initial Layout
        applyTheme()
        updateKeyboardLayout()
        
        // Register for theme changes (iOS 17+)
        registerTraitChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh predictions when keyboard appears
        applyTheme()
        updatePredictions()
    }
    
    // Handle dark/light mode changes (iOS 17+)
    func registerTraitChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.applyTheme()
                self.updateKeyboardLayout()
            }
        }
    }
    
    func applyTheme() {
        view.backgroundColor = colorBackground
        suggestionBar?.backgroundColor = colorBackground
        
        // Update suggestion button colors
        for btn in suggestionButtons {
            btn.setTitleColor(colorText, for: .normal)
        }
        
        // Update divider colors
        for subview in suggestionBar?.subviews ?? [] {
            if subview.tag == 999 { // Divider tag
                subview.backgroundColor = colorDivider
            }
        }
    }
    
    // MARK: - 1. Suggestion Bar
    var suggestionDividers: [UIView] = []
    
    func setupSuggestionBar() {
        suggestionBar = UIStackView()
        suggestionBar.axis = .horizontal
        suggestionBar.distribution = .fill
        suggestionBar.spacing = 0
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.backgroundColor = colorBackground
        
        for i in 0..<3 {
            // Add button
            let btn = UIButton(type: .system)
            btn.backgroundColor = .clear
            btn.setTitleColor(colorText, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            btn.isHidden = true
            btn.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(btn)
            suggestionBar.addArrangedSubview(btn)
            
            // Add divider after each button except last
            if i < 2 {
                let divider = UIView()
                divider.backgroundColor = colorDivider
                divider.tag = 999  // Tag for identifying dividers
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
                divider.isHidden = true
                suggestionDividers.append(divider)
                suggestionBar.addArrangedSubview(divider)
            }
        }
        
        // Make buttons equal width
        if suggestionButtons.count >= 3 {
            suggestionButtons[1].widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
            suggestionButtons[2].widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
        }
        
        view.addSubview(suggestionBar)
        
        NSLayoutConstraint.activate([
            suggestionBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            suggestionBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    // MARK: - 2. Layout Engine (Redraws keys based on state)
    func updateKeyboardLayout() {
        // 1. Remove old layout if it exists
        mainStackView?.removeFromSuperview()
        
        // 2. Determine which keys to show
        var currentKeys: [[String]]
        
        if currentMode == .numbers {
            currentKeys = keysNumbers
        } else {
            // If Uppercase, map everything to uppercase
            if isUppercase {
                currentKeys = keysLower.map { row in row.map { $0.uppercased() } }
            } else {
                currentKeys = keysLower
            }
        }
        
        // 3. Build Stack
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 12
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // --- ROWS 1, 2, 3 ---
        for (rowIndex, rowKeys) in currentKeys.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually
            
            // Row 3 Special Logic (Shift/Back)
            if rowIndex == 2 {
                // LEFT SIDE FUNCTION KEY
                if currentMode == .letters {
                    // Show SHIFT
                    let shiftTitle = isUppercase ? "⬆" : "⇧" // Filled arrow if active
                    let shiftBtn = createKeyButton(title: shiftTitle, isFunctionKey: true)
                    // Highlight shift if active
                    if isUppercase {
                        shiftBtn.backgroundColor = isDarkMode ? .white : .white
                        shiftBtn.setTitleColor(isDarkMode ? .black : .black, for: .normal)
                    }
                    shiftBtn.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
                    rowStack.addArrangedSubview(shiftBtn)
                } else {
                    // Show SYMBOLS Toggle (Simplified: Just a placeholder or specific symbol logic)
                    // For now, we keep it aligned with letters, maybe add a specific symbol key later
                    // Let's put a placeholder spacer to keep alignment or more symbols
                    let spacer = createKeyButton(title: "#+=", isFunctionKey: true)
                     // (Action not implemented for brevity, acts as spacer)
                    rowStack.addArrangedSubview(spacer)
                }
                
                // CENTER KEYS
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                
                // RIGHT SIDE: Backspace
                let backspaceBtn = createKeyButton(title: "⌫", isFunctionKey: true)
                backspaceBtn.removeTarget(nil, action: nil, for: .allEvents)
                backspaceBtn.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(backspaceBtn)
                
                mainStackView.addArrangedSubview(rowStack)
            } else {
                // Standard Rows 1 & 2
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                mainStackView.addArrangedSubview(rowStack)
            }
        }
        
        // --- ROW 4 (Bottom) ---
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally
        
        // 123 / ABC Button
        let modeTitle = (currentMode == .letters) ? "123" : "ABC"
        let modeBtn = createKeyButton(title: modeTitle, isFunctionKey: true)
        modeBtn.widthAnchor.constraint(equalToConstant: 90).isActive = true
        modeBtn.addTarget(self, action: #selector(modeTapped), for: .touchUpInside)
        
        // Dot Key (with autocorrect)
        let dotBtn = createKeyButton(title: ".", isFunctionKey: false)
        dotBtn.removeTarget(nil, action: nil, for: .allEvents)
        dotBtn.addTarget(self, action: #selector(punctuationTapped(_:)), for: .touchUpInside)
        dotBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Space
        let spaceBtn = createKeyButton(title: "Navber", isFunctionKey: false)
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        
        // Return
        let returnBtn = createKeyButton(title: "⏎", isFunctionKey: true)
        returnBtn.widthAnchor.constraint(equalToConstant: 90).isActive = true
        returnBtn.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        bottomRow.addArrangedSubview(modeBtn)
        bottomRow.addArrangedSubview(dotBtn)
        bottomRow.addArrangedSubview(spaceBtn)
        bottomRow.addArrangedSubview(returnBtn)
        
        mainStackView.addArrangedSubview(bottomRow)
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 3),
            mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - 3. Styling Engine
    func createKeyButton(title: String, isFunctionKey: Bool) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = isFunctionKey ? colorKeyFunction : colorKeyNormal
        btn.setTitleColor(colorText, for: .normal)
        btn.layer.shadowColor = colorKeyShadow.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        btn.layer.shadowOpacity = isDarkMode ? 0.5 : 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 5.0
        
        if title.count > 1 {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        } else {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        }

        // Auto-add action for standard keys (single character keys)
        if !["⌫", "Navber", "⏎", "123", "ABC", "⇧", "⬆", "#+=", "."].contains(title) {
            btn.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
            btn.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        return btn
    }
    
    // MARK: - Key Pop-up Preview
    func showKeyPopup(for button: UIButton, character: String) {
        // Remove existing popup
        hideKeyPopup()
        
        // Create popup container
        let popupWidth: CGFloat = 56
        let popupHeight: CGFloat = 76
        let bubbleTailHeight: CGFloat = 10
        
        let popup = UIView()
        popup.backgroundColor = .clear
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the bubble shape - matches theme
        let bubbleView = UIView()
        bubbleView.backgroundColor = isDarkMode ? UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0) : .white
        bubbleView.layer.cornerRadius = 9
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowOpacity = isDarkMode ? 0.5 : 0.3
        bubbleView.layer.shadowRadius = 4
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(bubbleView)
        
        // Create the label - matches theme
        let label = UILabel()
        label.text = character
        label.font = UIFont.systemFont(ofSize: 36, weight: .light)
        label.textColor = isDarkMode ? .white : .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(label)
        
        // Add to view hierarchy (above everything)
        view.addSubview(popup)
        
        // Position popup above the key
        let buttonFrame = button.convert(button.bounds, to: view)
        
        NSLayoutConstraint.activate([
            // Bubble constraints
            bubbleView.topAnchor.constraint(equalTo: popup.topAnchor),
            bubbleView.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
            bubbleView.widthAnchor.constraint(equalToConstant: popupWidth),
            bubbleView.heightAnchor.constraint(equalToConstant: popupHeight - bubbleTailHeight),
            
            // Label constraints
            label.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            
            // Popup position
            popup.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: buttonFrame.midX),
            popup.bottomAnchor.constraint(equalTo: view.topAnchor, constant: buttonFrame.minY + 4),
            popup.widthAnchor.constraint(equalToConstant: popupWidth),
            popup.heightAnchor.constraint(equalToConstant: popupHeight)
        ])
        
        keyPopupView = popup
        keyPopupLabel = label
        
        // Animate in
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popup.alpha = 0
        UIView.animate(withDuration: 0.1) {
            popup.transform = .identity
            popup.alpha = 1
        }
    }
    
    func hideKeyPopup() {
        if let popup = keyPopupView {
            UIView.animate(withDuration: 0.08, animations: {
                popup.alpha = 0
            }) { _ in
                popup.removeFromSuperview()
            }
            keyPopupView = nil
            keyPopupLabel = nil
        }
    }
    
    @objc func keyTouchDown(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), title.count == 1 else { return }
        showKeyPopup(for: sender, character: title)
    }
    
    @objc func keyTouchUp(_ sender: UIButton) {
        hideKeyPopup()
        
        // Actually insert the character
        guard let letter = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(letter)
        UIDevice.current.playInputClick()
        
        // Update predictions immediately after typing
        updatePredictions()
        
        // Auto-lowercase after typing a letter (standard behavior)
        if isUppercase {
            isUppercase = false
            updateKeyboardLayout()
        }
    }
    
    // MARK: - Actions
    
    @objc func shiftTapped() {
        isUppercase.toggle()
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func modeTapped() {
        if currentMode == .letters {
            currentMode = .numbers
        } else {
            currentMode = .letters
        }
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func spaceTapped() {
        performAutocorrect()
        textDocumentProxy.insertText(" ")
        updatePredictions()
    }
    
    @objc func backspaceTapped() {
        textDocumentProxy.deleteBackward()
        updatePredictions()
    }
    
    @objc func returnTapped() {
        performAutocorrect()
        textDocumentProxy.insertText("\n")
        updatePredictions()
    }
    
    // MARK: - Autocorrect Logic
    
    /// Performs autocorrect on the current word before inserting space/punctuation
    func performAutocorrect() {
        guard let engine = predictionEngine else { return }
        
        // Get the current word being typed
        guard let currentWord = getCurrentWord(), !currentWord.isEmpty else { return }
        
        // Check if we have a correction
        if let correction = engine.getCorrection(for: currentWord) {
            // Delete the misspelled word
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            // Insert the corrected word
            textDocumentProxy.insertText(correction)
            
            print("✨ Autocorrected: '\(currentWord)' → '\(correction)'")
        }
    }
    
    /// Gets the current word being typed (before cursor)
    func getCurrentWord() -> String? {
        guard let context = textDocumentProxy.documentContextBeforeInput else { return nil }
        
        // Find the last word (text after last space/newline)
        let trimmed = context.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        
        // Split by whitespace and get the last word
        let words = trimmed.components(separatedBy: .whitespacesAndNewlines)
        return words.last
    }
    
    /// Handler for punctuation keys (autocorrect before inserting)
    @objc func punctuationTapped(_ sender: UIButton) {
        guard let punctuation = sender.title(for: .normal) else { return }
        performAutocorrect()
        textDocumentProxy.insertText(punctuation)
        UIDevice.current.playInputClick()
        updatePredictions()
    }

    @objc func suggestionTapped(_ sender: UIButton) {
        guard var word = sender.title(for: .normal) else { return }
        let proxy = self.textDocumentProxy
        
        // Remove quotes if this is the first button (quoted suggestion)
        if word.hasPrefix("\"") && word.hasSuffix("\"") {
            word = String(word.dropFirst().dropLast())
        }
        
        // Check if user is typing a partial word (no trailing space)
        if let context = proxy.documentContextBeforeInput, !context.hasSuffix(" ") {
            // Delete the partial word first
            if let partialWord = getCurrentWord() {
                for _ in 0..<partialWord.count {
                    proxy.deleteBackward()
                }
            }
        }
        
        // Insert the complete suggestion with a space
        proxy.insertText(word + " ")
        updatePredictions()
    }
    
    // MARK: - Prediction Logic
    override func textDidChange(_ textInput: UITextInput?) {
        updatePredictions()
    }
    
    override func selectionWillChange(_ textInput: UITextInput?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updatePredictions()
        }
    }
    
    func updatePredictions() {
        let proxy = self.textDocumentProxy
        guard let context = proxy.documentContextBeforeInput else {
            updateButtons(with: [])
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let engine = self.predictionEngine else { return }
            let suggestions = engine.getSuggestions(for: context)
            DispatchQueue.main.async {
                self.updateButtons(with: suggestions)
            }
        }
    }
    
    func updateButtons(with words: [String]) {
        // Get the current partial word for quote style
        let currentWord = getCurrentWord() ?? ""
        
        if words.isEmpty {
            for btn in suggestionButtons { btn.isHidden = true }
            for divider in suggestionDividers { divider.isHidden = true }
            return
        }
        
        var visibleCount = 0
        for (index, btn) in suggestionButtons.enumerated() {
            if index < words.count {
                // First suggestion shows what user typed in quotes (if they're typing)
                if index == 0 && !currentWord.isEmpty {
                    btn.setTitle("\"\(currentWord)\"", for: .normal)
                } else {
                    btn.setTitle(words[index], for: .normal)
                }
                btn.setTitleColor(colorText, for: .normal)
                btn.isHidden = false
                visibleCount += 1
            } else {
                btn.isHidden = true
            }
        }
        
        // Show/hide dividers based on visible buttons
        for (index, divider) in suggestionDividers.enumerated() {
            // Show divider only if there are buttons on both sides
            divider.isHidden = (index + 1 >= visibleCount)
            divider.backgroundColor = colorDivider
        }
    }
}
