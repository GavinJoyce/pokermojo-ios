//
//  ResultsScreen.swift
//  PokerMojo
//

import SwiftUI

struct ResultsScreen: View {
    @Bindable var game: GameState

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                // Result icon
                Text(game.score == 20 ? "🏆" : "😢")
                    .font(.system(size: 64))
                    .padding(.top, 20)

                Text(game.score == 20 ? "Perfect Score!" : "Game Over")
                    .font(.system(size: 32, weight: .bold))

                // Stats
                HStack(spacing: 40) {
                    ResultStat(value: "\(game.score)/20", label: "Correct")
                    ResultStat(value: game.formatTime(game.elapsedTime), label: "Time")
                }
                .padding(.vertical, 20)

                // Name input for perfect score
                if game.score == 20 && !game.nameSaved {
                    VStack(spacing: 15) {
                        Text("Enter your name for the leaderboard:")
                            .font(.system(size: 16))

                        TextField("Your name", text: $game.playerName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 18))
                            .padding(15)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .frame(maxWidth: 300)
                            .multilineTextAlignment(.center)
                            .onSubmit { game.saveName() }

                        Button(action: { game.saveName() }) {
                            Text("Save Score")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
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
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.3, green: 0.69, blue: 0.31))
                }

                // Leaderboard
                if !game.leaderboard.isEmpty {
                    LeaderboardView(entries: Array(game.leaderboard.prefix(10)), game: game)
                }

                // Review incorrect answers
                let incorrect = game.getIncorrectResults()
                if !incorrect.isEmpty {
                    ReviewSection(results: incorrect)
                }

                // Play again button
                Button(action: { game.resetGame() }) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
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
                .padding(.vertical, 30)
            }
            .padding(.horizontal, 20)
        }

            // Toast
            if let toast = game.deleteToast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeOut(duration: 0.3), value: game.deleteToast)
            }
        }
    }
}

struct ResultStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
            Text(label)
                .font(.system(size: 14))
                .opacity(0.7)
        }
    }
}

struct ReviewSection: View {
    let results: [RoundResult]

    var body: some View {
        VStack(spacing: 20) {
            Text("Review Incorrect Answers")
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 20)

            ForEach(results) { result in
                ReviewItem(result: result)
            }
        }
    }
}

struct ReviewItem: View {
    let result: RoundResult

    var body: some View {
        VStack(spacing: 15) {
            Text("Round \(result.round)")
                .font(.system(size: 14))
                .opacity(0.7)

            HStack(spacing: 15) {
                ReviewHand(
                    label: "Hand A",
                    hand: result.handA,
                    isWinner: result.correctHand == "A",
                    wasPicked: result.selectedHand == "A"
                )

                ReviewHand(
                    label: "Hand B",
                    hand: result.handB,
                    isWinner: result.correctHand == "B",
                    wasPicked: result.selectedHand == "B"
                )
            }
        }
        .padding(15)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ReviewHand: View {
    let label: String
    let hand: EvaluatedHand
    let isWinner: Bool
    let wasPicked: Bool

    var borderColor: Color {
        if isWinner { return Color(red: 0.3, green: 0.69, blue: 0.31) }
        if wasPicked { return Color(red: 0.96, green: 0.26, blue: 0.21) }
        return Color.clear
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Text(label)
                    .font(.system(size: 14))

                if isWinner {
                    Text("Winner")
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.3, green: 0.69, blue: 0.31).opacity(0.3))
                        .foregroundColor(Color(red: 0.3, green: 0.69, blue: 0.31))
                        .cornerRadius(4)
                }

                if wasPicked && !isWinner {
                    Text("Your pick")
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.96, green: 0.26, blue: 0.21).opacity(0.3))
                        .foregroundColor(Color(red: 0.96, green: 0.26, blue: 0.21))
                        .cornerRadius(4)
                }
            }

            HandView(hand: hand, cardSize: .small)

            Text(hand.name)
                .font(.system(size: 13))
                .opacity(0.8)
        }
        .padding(10)
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
