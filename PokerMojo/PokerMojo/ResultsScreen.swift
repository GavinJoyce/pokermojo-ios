//
//  ResultsScreen.swift
//  PokerMojo
//

import SwiftUI

struct ResultsScreen: View {
    @Bindable var game: GameState

    var body: some View {
        GeometryReader { geometry in
            let scale = min(max(geometry.size.width / 1024, 0.6), 1.3)
            let isCompact = geometry.size.width < 600
            let leaderboardMaxWidth: CGFloat = min(geometry.size.width * 0.45, 500)

            ZStack {
                ScrollView {
                    VStack(spacing: 20 * scale) {
                        // Result icon
                        Text(game.score == 20 ? "🏆" : "😢")
                            .font(.system(size: 64 * scale))
                            .padding(.top, 20 * scale)

                        Text(game.score == 20 ? "Perfect Score!" : "Game Over")
                            .font(.system(size: 32 * scale, weight: .bold))

                        // Stats
                        HStack(spacing: 40 * scale) {
                            ResultStat(value: "\(game.score)/20", label: "Correct", scale: scale)
                            ResultStat(value: game.formatTime(game.elapsedTime), label: "Time", scale: scale)
                        }
                        .padding(.vertical, 20 * scale)

                        // Name input for perfect score
                        if game.score == 20 && !game.nameSaved {
                            VStack(spacing: 15 * scale) {
                                Text("Enter your name for the leaderboard:")
                                    .font(.system(size: 16 * scale))

                                TextField("Your name", text: $game.playerName)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 18 * scale))
                                    .padding(15 * scale)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                    .frame(maxWidth: 300 * scale)
                                    .multilineTextAlignment(.center)
                                    .onSubmit { game.saveName() }

                                Button(action: { game.saveName() }) {
                                    Text("Save Score")
                                        .font(.system(size: 18 * scale, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 40 * scale)
                                        .padding(.vertical, 15 * scale)
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
                                .disabled(game.playerName.trimmingCharacters(in: .whitespaces).isEmpty)
                                .opacity(game.playerName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                            }
                        }

                        // Saved confirmation
                        if game.score == 20 && game.nameSaved {
                            Text("✓ Score saved!")
                                .font(.system(size: 18 * scale))
                                .foregroundColor(Color(red: 0.3, green: 0.69, blue: 0.31))
                        }

                        // Leaderboard
                        if !game.leaderboard.isEmpty {
                            LeaderboardView(
                                entries: Array(game.leaderboard.prefix(10)),
                                game: game,
                                scale: scale,
                                maxWidth: leaderboardMaxWidth,
                                isCompact: isCompact
                            )
                        }

                        // Review incorrect answers
                        let incorrect = game.getIncorrectResults()
                        if !incorrect.isEmpty {
                            ReviewSection(results: incorrect, scale: scale, isCompact: isCompact)
                        }

                        // Play again button
                        Button(action: { game.resetGame() }) {
                            Text("Play Again")
                                .font(.system(size: 18 * scale, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 40 * scale)
                                .padding(.vertical, 15 * scale)
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
                        .padding(.vertical, 30 * scale)
                    }
                    .padding(.horizontal, 20 * scale)
                }

                // Toast
                if let toast = game.deleteToast {
                    VStack {
                        Spacer()
                        Text(toast)
                            .font(.system(size: 14 * scale))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20 * scale)
                            .padding(.vertical, 12 * scale)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(8)
                            .padding(.bottom, 20 * scale)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.3), value: game.deleteToast)
                }
            }
        }
    }
}

struct ResultStat: View {
    let value: String
    let label: String
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 4 * scale) {
            Text(value)
                .font(.system(size: 40 * scale, weight: .bold))
                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
            Text(label)
                .font(.system(size: 14 * scale))
                .opacity(0.7)
        }
    }
}

struct ReviewSection: View {
    let results: [RoundResult]
    var scale: CGFloat = 1.0
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: 20 * scale) {
            Text("Review Incorrect Answers")
                .font(.system(size: 22 * scale, weight: .bold))
                .padding(.top, 20 * scale)

            ForEach(results) { result in
                ReviewItem(result: result, scale: scale, isCompact: isCompact)
            }
        }
    }
}

struct ReviewItem: View {
    let result: RoundResult
    var scale: CGFloat = 1.0
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: 15 * scale) {
            Text("Round \(result.round)")
                .font(.system(size: 14 * scale))
                .opacity(0.7)

            // Stack vertically on compact screens
            if isCompact {
                VStack(spacing: 15 * scale) {
                    ReviewHand(
                        label: "Hand A",
                        hand: result.handA,
                        isWinner: result.correctHand == "A",
                        wasPicked: result.selectedHand == "A",
                        scale: scale
                    )

                    ReviewHand(
                        label: "Hand B",
                        hand: result.handB,
                        isWinner: result.correctHand == "B",
                        wasPicked: result.selectedHand == "B",
                        scale: scale
                    )
                }
            } else {
                HStack(spacing: 15 * scale) {
                    ReviewHand(
                        label: "Hand A",
                        hand: result.handA,
                        isWinner: result.correctHand == "A",
                        wasPicked: result.selectedHand == "A",
                        scale: scale
                    )

                    ReviewHand(
                        label: "Hand B",
                        hand: result.handB,
                        isWinner: result.correctHand == "B",
                        wasPicked: result.selectedHand == "B",
                        scale: scale
                    )
                }
            }
        }
        .padding(15 * scale)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ReviewHand: View {
    let label: String
    let hand: EvaluatedHand
    let isWinner: Bool
    let wasPicked: Bool
    var scale: CGFloat = 1.0

    var borderColor: Color {
        if isWinner { return Color(red: 0.3, green: 0.69, blue: 0.31) }
        if wasPicked { return Color(red: 0.96, green: 0.26, blue: 0.21) }
        return Color.clear
    }

    var body: some View {
        VStack(spacing: 8 * scale) {
            HStack(spacing: 5 * scale) {
                Text(label)
                    .font(.system(size: 14 * scale))

                if isWinner {
                    Text("Winner")
                        .font(.system(size: 11 * scale))
                        .padding(.horizontal, 6 * scale)
                        .padding(.vertical, 2 * scale)
                        .background(Color(red: 0.3, green: 0.69, blue: 0.31).opacity(0.3))
                        .foregroundColor(Color(red: 0.3, green: 0.69, blue: 0.31))
                        .cornerRadius(4)
                }

                if wasPicked && !isWinner {
                    Text("Your pick")
                        .font(.system(size: 11 * scale))
                        .padding(.horizontal, 6 * scale)
                        .padding(.vertical, 2 * scale)
                        .background(Color(red: 0.96, green: 0.26, blue: 0.21).opacity(0.3))
                        .foregroundColor(Color(red: 0.96, green: 0.26, blue: 0.21))
                        .cornerRadius(4)
                }
            }

            HandView(hand: hand, cardSize: .small)

            Text(hand.name)
                .font(.system(size: 13 * scale))
                .opacity(0.8)
        }
        .padding(10 * scale)
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 2)
            )
    }
}

#Preview {
    ResultsScreen(game: {
        let g = GameState()
        g.score = 18
        g.elapsedTime = 125
        g.results = [
            RoundResult(
                round: 5,
                handA: PokerLogic.evaluateHand([Card("A", .spades), Card("K", .spades), Card("Q", .spades), Card("J", .spades), Card("10", .spades)]),
                handB: PokerLogic.evaluateHand([Card("9", .hearts), Card("9", .diamonds), Card("9", .clubs), Card("5", .hearts), Card("5", .spades)]),
                correctHand: "A",
                selectedHand: "B"
            ),
            RoundResult(
                round: 12,
                handA: PokerLogic.evaluateHand([Card("K", .hearts), Card("K", .diamonds), Card("5", .clubs), Card("5", .hearts), Card("3", .spades)]),
                handB: PokerLogic.evaluateHand([Card("A", .spades), Card("A", .hearts), Card("2", .clubs), Card("2", .diamonds), Card("7", .spades)]),
                correctHand: "B",
                selectedHand: "A"
            )
        ]
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
