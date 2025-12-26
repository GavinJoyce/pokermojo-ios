//
//  GameScreen.swift
//  PokerMojo
//

import SwiftUI

struct GameScreen: View {
    @Bindable var game: GameState

    var body: some View {
        GeometryReader { geometry in
            let metrics = LayoutMetrics(size: geometry.size)

            ZStack {
                VStack(spacing: metrics.verticalSpacing) {
                    // Header with stats
                    HStack {
                        // Mode indicator on the left
                        StatView(value: game.mode == .hard ? "🔥" : "⭐", label: game.mode.rawValue.capitalized, metrics: metrics)

                        Spacer()
                        StatView(value: game.formatTime(game.elapsedTime), label: "Time", metrics: metrics)
                        Spacer()
                        StatView(value: "\(game.score)/\(game.round - (game.showResult ? 0 : 1))", label: "Score", metrics: metrics)
                        Spacer()

                        // Game control buttons on the right
                        HStack(spacing: 8) {
                            Button(action: { game.startGame(mode: game.mode) }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: metrics.buttonIconSize))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(metrics.buttonPadding)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)

                            Button(action: { game.cancelGame() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: metrics.buttonIconSize))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(metrics.buttonPadding)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)

                    // Progress tracker
                    ProgressTracker(
                        round: game.round,
                        results: game.results,
                        showResult: game.showResult,
                        metrics: metrics
                    )

                    Spacer()

                    // Hands
                    if let handA = game.handA, let handB = game.handB {
                        HStack(spacing: metrics.handSpacing) {
                            HandContainer(
                                label: "Hand A",
                                hand: handA,
                                isHidden: game.countdown != nil,
                                isCorrect: game.showResult && game.correctHand == "A",
                                isIncorrect: game.showResult && game.selectedHand == "A" && game.correctHand != "A",
                                showHandType: game.showResult && game.selectedHand != game.correctHand,
                                metrics: metrics
                            ) {
                                game.selectHand("A")
                            }

                            HandContainer(
                                label: "Hand B",
                                hand: handB,
                                isHidden: game.countdown != nil,
                                isCorrect: game.showResult && game.correctHand == "B",
                                isIncorrect: game.showResult && game.selectedHand == "B" && game.correctHand != "B",
                                showHandType: game.showResult && game.selectedHand != game.correctHand,
                                metrics: metrics
                            ) {
                                game.selectHand("B")
                            }
                        }
                        .padding(.horizontal, metrics.handContainerPadding)
                    }

                    Spacer()

                    // Game over on wrong answer
                    if game.showResult && game.selectedHand != game.correctHand {
                        VStack(spacing: metrics.verticalSpacing) {
                            Text("Game Over! You got \(game.score)/\(game.round) correct.")
                                .font(.system(size: metrics.gameOverFontSize))
                                .foregroundColor(Color(red: 0.94, green: 0.60, blue: 0.60))

                            HStack(spacing: 15) {
                                Button(action: { game.startGame(mode: game.mode) }) {
                                    Text("Play Again")
                                        .font(.system(size: metrics.buttonFontSize, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, metrics.actionButtonHorizontalPadding)
                                        .padding(.vertical, metrics.actionButtonVerticalPadding)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(red: 1, green: 0.84, blue: 0), Color(red: 1, green: 0.67, blue: 0)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(30)
                                }
                                .buttonStyle(.plain)

                                Button(action: { game.resetGame() }) {
                                    Text("Main Menu")
                                        .font(.system(size: metrics.buttonFontSize, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, metrics.actionButtonHorizontalPadding)
                                        .padding(.vertical, metrics.actionButtonVerticalPadding)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(30)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, metrics.verticalSpacing)
            }
        }
    }
}

// MARK: - Layout Metrics
struct LayoutMetrics {
    let size: CGSize

    // Base scale factor based on screen width
    var scale: CGFloat {
        let baseWidth: CGFloat = 1024 // iPad baseline
        return min(max(size.width / baseWidth, 0.6), 1.3)
    }

    // Spacing
    var verticalSpacing: CGFloat { 20 * scale }
    var horizontalPadding: CGFloat { 20 * scale }
    var handSpacing: CGFloat { 40 * scale }
    var handContainerPadding: CGFloat { 40 * scale }

    // Progress dots
    var dotSize: CGFloat {
        // Calculate based on available width, ensuring all 20 dots fit
        let availableWidth = size.width - (2 * horizontalPadding)
        let spacing: CGFloat = 10 * scale
        let calculatedSize = (availableWidth - (19 * spacing)) / 20
        return min(max(calculatedSize, 24), 36) // Clamp between 24 and 36
    }
    var dotSpacing: CGFloat { 10 * scale }
    var dotFontSize: CGFloat { dotSize * 0.44 }

    // Stats
    var statValueFontSize: CGFloat { 36 * scale }
    var statLabelFontSize: CGFloat { 14 * scale }

    // Buttons
    var buttonIconSize: CGFloat { 18 * scale }
    var buttonPadding: CGFloat { 10 * scale }
    var buttonFontSize: CGFloat { 22 * scale }
    var actionButtonHorizontalPadding: CGFloat { 40 * scale }
    var actionButtonVerticalPadding: CGFloat { 18 * scale }

    // Game over
    var gameOverFontSize: CGFloat { 24 * scale }

    // Hand container
    var handLabelFontSize: CGFloat { 28 * scale }
    var handTypeFontSize: CGFloat { 20 * scale }
    var handContainerInnerPadding: CGFloat { 30 * scale }

    // Card size selection based on available space
    var cardSize: CardView.CardSize {
        // Calculate available width per hand (accounting for spacing and padding)
        let handsAreaWidth = size.width - (2 * handContainerPadding) - handSpacing
        let perHandWidth = handsAreaWidth / 2
        // Each hand has 5 cards with spacing
        let cardSpacing: CGFloat = 8
        let availableCardWidth = (perHandWidth - (4 * cardSpacing) - (2 * handContainerInnerPadding)) / 5

        if availableCardWidth >= 85 {
            return .large
        } else if availableCardWidth >= 55 {
            return .regular
        } else {
            return .small
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    var metrics: LayoutMetrics? = nil

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: metrics?.statValueFontSize ?? 36, weight: .bold))
            Text(label.uppercased())
                .font(.system(size: metrics?.statLabelFontSize ?? 14))
                .opacity(0.7)
        }
    }
}

struct ProgressTracker: View {
    let round: Int
    let results: [RoundResult]
    let showResult: Bool
    var metrics: LayoutMetrics? = nil

    var body: some View {
        HStack(spacing: metrics?.dotSpacing ?? 10) {
            ForEach(1...20, id: \.self) { i in
                ProgressDot(
                    number: i,
                    status: dotStatus(for: i),
                    metrics: metrics
                )
            }
        }
    }

    func dotStatus(for index: Int) -> ProgressDot.Status {
        if let result = results.first(where: { $0.round == index }) {
            return result.isCorrect ? .correct : .incorrect
        } else if index == round && !showResult {
            return .current
        } else {
            return .pending
        }
    }
}

struct ProgressDot: View {
    let number: Int
    let status: Status
    var metrics: LayoutMetrics? = nil

    enum Status {
        case pending, current, correct, incorrect
    }

    private var dotSize: CGFloat { metrics?.dotSize ?? 36 }
    private var fontSize: CGFloat { metrics?.dotFontSize ?? 16 }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: dotSize, height: dotSize)

            if status == .current {
                Circle()
                    .stroke(Color(red: 1, green: 0.84, blue: 0), lineWidth: 2)
                    .frame(width: dotSize, height: dotSize)
            }

            Text(displayText)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(textColor)
        }
    }

    var displayText: String {
        switch status {
        case .correct: return "✓"
        case .incorrect: return "✗"
        default: return "\(number)"
        }
    }

    var backgroundColor: Color {
        switch status {
        case .pending: return Color.white.opacity(0.1)
        case .current: return Color(red: 1, green: 0.84, blue: 0).opacity(0.3)
        case .correct: return Color(red: 0.3, green: 0.69, blue: 0.31).opacity(0.3)
        case .incorrect: return Color(red: 0.96, green: 0.26, blue: 0.21).opacity(0.3)
        }
    }

    var textColor: Color {
        switch status {
        case .pending: return Color.white.opacity(0.3)
        case .current: return Color(red: 1, green: 0.84, blue: 0)
        case .correct: return Color(red: 0.3, green: 0.69, blue: 0.31)
        case .incorrect: return Color(red: 0.96, green: 0.26, blue: 0.21)
        }
    }
}

struct HandContainer: View {
    let label: String
    let hand: EvaluatedHand
    var isHidden: Bool = false
    var isCorrect: Bool = false
    var isIncorrect: Bool = false
    var showHandType: Bool = false
    var metrics: LayoutMetrics? = nil
    let action: () -> Void

    var borderColor: Color {
        if isCorrect { return Color(red: 0.3, green: 0.69, blue: 0.31) }
        if isIncorrect { return Color(red: 0.96, green: 0.26, blue: 0.21) }
        return Color.clear
    }

    var backgroundColor: Color {
        if isCorrect { return Color(red: 0.3, green: 0.69, blue: 0.31).opacity(0.2) }
        if isIncorrect { return Color(red: 0.96, green: 0.26, blue: 0.21).opacity(0.2) }
        return Color.black.opacity(0.2)
    }

    private var cardSize: CardView.CardSize { metrics?.cardSize ?? .large }
    private var labelFontSize: CGFloat { metrics?.handLabelFontSize ?? 28 }
    private var handTypeFontSize: CGFloat { metrics?.handTypeFontSize ?? 20 }
    private var innerPadding: CGFloat { metrics?.handContainerInnerPadding ?? 30 }

    var body: some View {
        Button(action: action) {
            VStack(spacing: metrics?.verticalSpacing ?? 20) {
                Text(label)
                    .font(.system(size: labelFontSize, weight: .bold))

                HandView(hand: hand, isHidden: isHidden, cardSize: cardSize)

                if showHandType {
                    Text(hand.name)
                        .font(.system(size: handTypeFontSize))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(innerPadding)
            .background(backgroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 4)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCorrect || isIncorrect)
    }
}

struct CountdownOverlay: View {
    let number: Int
    @State private var scale: CGFloat = 2.0
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            Text("\(number)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.7)) {
                        scale = 0.6
                        opacity = 0.0
                    }
                    // Quick pop in first
                    scale = 2.0
                    opacity = 0.0
                    withAnimation(.easeOut(duration: 0.2)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                    // Then fade out
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        scale = 0.6
                        opacity = 0.0
                    }
                }
                .id(number) // Force re-render on number change
        }
    }
}

#Preview {
    GameScreen(game: {
        let g = GameState()
        g.screen = .game
        g.countdown = nil
        g.handA = PokerLogic.evaluateHand([
            Card("A", .spades), Card("K", .spades), Card("Q", .spades), Card("J", .spades), Card("10", .spades)
        ])
        g.handB = PokerLogic.evaluateHand([
            Card("9", .hearts), Card("9", .diamonds), Card("9", .clubs), Card("5", .hearts), Card("5", .spades)
        ])
        return g
    }())
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(red: 0.1, green: 0.28, blue: 0.16), Color(red: 0.18, green: 0.35, blue: 0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
    .foregroundColor(.white)
}
