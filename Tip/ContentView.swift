//
//  ContentView.swift
//  Tip
//
//  Created by erhan gumus on 11/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Brand colors - Dark + Neon Green (matches logo)
    let primaryColor = Color(red: 0.0, green: 1.0, blue: 0.53)  // Neon green #00FF88
    let darkColor = Color(red: 0.05, green: 0.05, blue: 0.05)   // Near black
    let charcoalColor = Color(red: 0.12, green: 0.12, blue: 0.12) // Dark charcoal
    
    var body: some View {
        ZStack {
            // Background gradient - Dark theme
            LinearGradient(
                colors: [charcoalColor, darkColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    // App Icon with neon glow
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .shadow(color: primaryColor.opacity(0.6), radius: 20, x: 0, y: 0)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Klavyeya Kurmancî ya Jîr")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Tab Selector
                HStack(spacing: 4) {
                    TabButton(title: "Taybetmendî", icon: "sparkles", isSelected: selectedTab == 0) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                    }
                    TabButton(title: "Çawa Bikar Bînin", icon: "keyboard", isSelected: selectedTab == 1) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Content
                TabView(selection: $selectedTab) {
                    FeaturesView(primaryColor: primaryColor)
                        .tag(0)
                    
                    SetupView(primaryColor: primaryColor)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    // Neon green accent
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? accentColor : .white.opacity(0.1))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
        }
    }
}

// MARK: - Features View (What makes this keyboard special)
struct FeaturesView: View {
    let primaryColor: Color
    @State private var animatePrediction = false
    @State private var animateAutocorrect = false
    
    // Neon green accent
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    let cardBgColor = Color(red: 0.15, green: 0.15, blue: 0.16)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Main Feature: Kurdish Characters
                FeatureSection(
                    icon: "character.textbox",
                    iconColor: accentColor,
                    title: "Tîpên Kurdî",
                    subtitle: "Kurdish Characters"
                ) {
                    VStack(spacing: 12) {
                        Text("Hemû tîpên Kurmancî di nav de ne")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Kurdish character showcase
                        HStack(spacing: 8) {
                            ForEach(["Ê", "Î", "Û", "Ş", "Ç"], id: \.self) { char in
                                Text(char)
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .frame(width: 50, height: 50)
                                    .background(accentColor.opacity(0.15))
                                    .foregroundColor(accentColor)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Text("ê î û ş ç")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Main Feature: Word Prediction
                FeatureSection(
                    icon: "text.bubble.fill",
                    iconColor: .cyan,
                    title: "Pêşbîniya Peyvan",
                    subtitle: "Smart Word Prediction"
                ) {
                    VStack(spacing: 16) {
                        Text("Bi modela N-gram, peyvên pêşniyar dide")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Prediction Demo
                        VStack(spacing: 8) {
                            HStack {
                                Text("Ez diçim")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.gray)
                                
                                Text("...")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                            }
                            
                            // Suggestion pills
                            HStack(spacing: 8) {
                                PredictionPill(word: "bazarê", isHighlighted: true)
                                PredictionPill(word: "malê", isHighlighted: false)
                                PredictionPill(word: "dibistanê", isHighlighted: false)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                            Text("Ji 50,000+ hevokan hînbûyî")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                // Main Feature: Autocorrect
                FeatureSection(
                    icon: "checkmark.seal.fill",
                    iconColor: accentColor,
                    title: "Rastnivîsa Jîr",
                    subtitle: "Smart Autocorrect"
                ) {
                    VStack(spacing: 16) {
                        Text("Şaşiyên nivîsandinê otomatîk rast dike")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Autocorrect Demo
                        VStack(spacing: 12) {
                            // Before
                            HStack {
                                Text("pirtuk")
                                    .font(.system(size: 18))
                                    .strikethrough(true, color: .red)
                                    .foregroundColor(.red.opacity(0.7))
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(accentColor)
                                
                                Text("pirtûk")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Another example
                            HStack {
                                Text("xwendkra")
                                    .font(.system(size: 16))
                                    .strikethrough(true, color: .red)
                                    .foregroundColor(.red.opacity(0.7))
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(accentColor)
                                
                                Text("xwendekar")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                        }
                        
                        // Technical explanation
                        HStack(spacing: 4) {
                            Image(systemName: "keyboard")
                                .font(.caption)
                            Text("Keyboard-aware: Tîpên nêzîk hev dizane")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                // Privacy Feature
                FeatureSection(
                    icon: "lock.shield.fill",
                    iconColor: accentColor,
                    title: "Nepenî & Ewlehî",
                    subtitle: "Privacy & Security"
                ) {
                    VStack(spacing: 12) {
                        PrivacyRow(icon: "wifi.slash", text: "Bê înternetê dixebite")
                        PrivacyRow(icon: "icloud.slash", text: "Tu dane nayê şandin")
                        PrivacyRow(icon: "eye.slash", text: "Nivîsandina te nepenî ye")
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

// MARK: - Prediction Pill
struct PredictionPill: View {
    let word: String
    let isHighlighted: Bool
    
    // Neon green accent
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    
    var body: some View {
        Text(word)
            .font(.system(size: 14, weight: isHighlighted ? .semibold : .regular))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isHighlighted ? accentColor : Color(.systemGray5))
            .foregroundColor(isHighlighted ? .black : .primary)
            .cornerRadius(16)
    }
}

// MARK: - Privacy Row
struct PrivacyRow: View {
    let icon: String
    let text: String
    
    // Neon green accent
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(accentColor)
        }
    }
}

// MARK: - Feature Section Card
struct FeatureSection<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    
    // Card background - dark theme
    let cardBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.2))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Setup View
struct SetupView: View {
    let primaryColor: Color
    
    // Neon green accent & dark card
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    let cardBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Setup Instructions Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "keyboard.fill")
                            .font(.title2)
                            .foregroundColor(accentColor)
                        Text("Çawa Aktîv Bikin")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 4)
                    
                    SetupStepView(
                        number: 1,
                        title: "Mîhengên Vekin",
                        subtitle: "Settings → General → Keyboard",
                        icon: "gearshape.fill",
                        primaryColor: accentColor
                    )
                    
                    SetupStepView(
                        number: 2,
                        title: "Klavyeyan Hilbijêrin",
                        subtitle: "Keyboards → Add New Keyboard",
                        icon: "plus.rectangle.on.rectangle",
                        primaryColor: accentColor
                    )
                    
                    SetupStepView(
                        number: 3,
                        title: "Tîp Hilbijêrin",
                        subtitle: "Di lîsteyê de \"Tîp\" bibînin",
                        icon: "checkmark.circle.fill",
                        primaryColor: accentColor
                    )
                    
                    SetupStepView(
                        number: 4,
                        title: "Bikar Bînin!",
                        subtitle: "🌍 bikirtînin bo guherandinê",
                        icon: "globe",
                        primaryColor: accentColor
                    )
                    
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Mîhengan Veke")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Tips Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Serişteyên Bikêrhatî")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    TipRow(text: "🌍 Pêl bikin bo guherandina klavyeyê")
                    TipRow(text: "📝 Pêşniyaran bikirtînin bo zêdekirinê")
                    TipRow(text: "⌫ Dirêj pêl bikin bo jêbirina zû")
                }
                .padding(20)
                .background(cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Version info
                Text("Guhertoya 1.0")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 20)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let text: String
    
    // Neon green accent
    let accentColor = Color(red: 0.0, green: 1.0, blue: 0.53)
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accentColor.opacity(0.5))
                .frame(width: 8, height: 8)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Setup Step View
struct SetupStepView: View {
    let number: Int
    let title: String
    let subtitle: String
    let icon: String
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(primaryColor.opacity(0.6))
        }
    }
}

#Preview {
    ContentView()
}
