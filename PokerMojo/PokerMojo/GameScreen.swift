//
//  GameScreen.swift
//  PokerMojo
//

import SwiftUI

struct GameScreen: View {
    @Bindable var game: GameState

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header with stats
                HStack {
                    // Mode indicator on the left
                    StatView(value: game.mode == .hard ? "🔥" : "⭐", label: game.mode.rawValue.capitalized)

                    Spacer()
                    StatView(value: game.formatTime(game.elapsedTime), label: "Time")
                    Spacer()
                    StatView(value: "\(game.score)/\(game.round - (game.showResult ? 0 : 1))", label: "Score")
                    Spacer()

                    // Game control buttons on the right
                    HStack(spacing: 8) {
                        Button(action: { game.startGame(mode: game.mode) }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Button(action: { game.cancelGame() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                // Progress tracker
                ProgressTracker(
                    round: game.round,
                    results: game.results,
                    showResult: game.showResult
                )

                Spacer()

                // Hands
                if let handA = game.handA, let handB = game.handB {
                    HStack(spacing: 40) {
                        HandContainer(
                            label: "Hand A",
                            hand: handA,
                            isHidden: game.countdown != nil,
                            isCorrect: game.showResult && game.correctHand == "A",
                            isIncorrect: game.showResult && game.selectedHand == "A" && game.correctHand != "A",
                            showHandType: game.showResult && game.selectedHand != game.correctHand
                        ) {
                            game.selectHand("A")
                        }

                        HandContainer(
                            label: "Hand B",
                            hand: handB,
                            isHidden: game.countdown != nil,
                            isCorrect: game.showResult && game.correctHand == "B",
                            isIncorrect: game.showResult && game.selectedHand == "B" && game.correctHand != "B",
                            showHandType: game.showResult && game.selectedHand != game.correctHand
                        ) {
                            game.selectHand("B")
                        }
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Game over on wrong answer
                if game.showResult && game.selectedHand != game.correctHand {
                    VStack(spacing: 20) {
                        Text("Game Over! You got \(game.score)/\(game.round) correct.")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.94, green: 0.60, blue: 0.60))

                        HStack(spacing: 15) {
                            Button(action: { game.startGame(mode: game.mode) }) {
                                Text("Play Again")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 18)
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
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 18)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(30)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, 20)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
            Text(label.uppercased())
                .font(.system(size: 14))
                .opacity(0.7)
        }
    }
}

struct ProgressTracker: View {
    let round: Int
    let results: [RoundResult]
    let showResult: Bool

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...20, id: \.self) { i in
                ProgressDot(
                    number: i,
                    status: dotStatus(for: i)
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

    enum Status {
        case pending, current, correct, incorrect
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 36, height: 36)

            if status == .current {
                Circle()
                    .stroke(Color(red: 1, green: 0.84, blue: 0), lineWidth: 2)
                    .frame(width: 36, height: 36)
            }

            Text(displayText)
                .font(.system(size: 16, weight: .bold))
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                Text(label)
                    .font(.system(size: 28, weight: .bold))

                HandView(hand: hand, isHidden: isHidden, cardSize: .large)

                if showHandType {
                    Text(hand.name)
                        .font(.system(size: 20))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(30)
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
