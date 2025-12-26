//
//  StartScreen.swift
//  PokerMojo
//

import SwiftUI

struct StartScreen: View {
    @Bindable var game: GameState

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Compare 20 poker hands as fast as you can!")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)

                    Text("Get all 20 correct to make the leaderboard.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .opacity(0.8)

                    HStack(spacing: 20) {
                        ModeButton(icon: "⭐", title: "Standard", subtitle: "Clear-cut hand differences") {
                            game.startGame(mode: .standard)
                        }

                        ModeButton(icon: "🔥", title: "Hard", subtitle: "Tricky kickers & close calls") {
                            game.startGame(mode: .hard)
                        }
                    }
                    .padding(.top, 20)

                    // Split leaderboards
                    if !game.leaderboard.isEmpty {
                        HStack(alignment: .top, spacing: 20) {
                            LeaderboardPanel(
                                icon: "⭐",
                                title: "Standard",
                                entries: game.getLeaderboardByMode("standard"),
                                game: game
                            )

                            LeaderboardPanel(
                                icon: "🔥",
                                title: "Hard",
                                entries: game.getLeaderboardByMode("hard"),
                                game: game
                            )
                        }
                        .padding(.top, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 40)
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

struct ModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Text(icon)
                        .font(.system(size: 20))
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                }
                Text(subtitle)
                    .font(.system(size: 14))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .frame(minWidth: 200)
            .padding(.vertical, 30)
            .padding(.horizontal, 40)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct LeaderboardPanel: View {
    let icon: String
    let title: String
    let entries: [LeaderboardEntry]
    let game: GameState

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 20, weight: .bold))
            }

            if entries.isEmpty {
                Text("No scores yet")
                    .font(.system(size: 15))
                    .opacity(0.6)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 5) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.system(size: 15, weight: .bold))
                                .frame(width: 30, alignment: .leading)

                            Text(entry.name)
                                .font(.system(size: 15))
                                .lineLimit(1)

                            Spacer()

                            Text(game.formatTime(entry.time))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))

                            Button(action: { game.deleteEntry(entry) }) {
                                Text("×")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.25))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(entry.isNew ? Color(red: 1, green: 0.84, blue: 0).opacity(0.2) : Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(entry.isNew ? Color(red: 1, green: 0.84, blue: 0) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(20)
        .frame(minWidth: 280, maxWidth: 400)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
    }
}

// Keep for backwards compatibility with ResultsScreen
struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    let game: GameState
    var highlightNew: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            LeaderboardPanel(
                icon: "⭐",
                title: "Standard",
                entries: game.getLeaderboardByMode("standard"),
                game: game
            )

            LeaderboardPanel(
                icon: "🔥",
                title: "Hard",
                entries: game.getLeaderboardByMode("hard"),
                game: game
            )
        }
    }
}

#Preview {
    StartScreen(game: GameState())
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
