//
//  StartScreen.swift
//  PokerMojo
//

import SwiftUI

struct StartScreen: View {
    @Bindable var game: GameState

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let scale = min(max(min(availableWidth / 1024, availableHeight / 700), 0.5), 1.5)
            let isCompact = availableWidth < 600
            let contentWidth = min(availableWidth - 40 * scale, 900 * scale)

            ZStack {
                ScrollView {
                    VStack(spacing: 20 * scale) {
                        // Description text
                        VStack(spacing: 8 * scale) {
                            Text("Compare 20 poker hands as fast as you can!")
                                .font(.system(size: 18 * scale))
                                .multilineTextAlignment(.center)

                            Text("Get all 20 correct to make the leaderboard.")
                                .font(.system(size: 18 * scale))
                                .multilineTextAlignment(.center)
                                .opacity(0.8)
                        }

                        // Mode buttons
                        if isCompact {
                            VStack(spacing: 15 * scale) {
                                ModeButton(icon: "⭐", title: "Standard", subtitle: "Clear-cut hand differences", scale: scale, maxWidth: contentWidth) {
                                    game.startGame(mode: .standard)
                                }

                                ModeButton(icon: "🔥", title: "Hard", subtitle: "Tricky kickers & close calls", scale: scale, maxWidth: contentWidth) {
                                    game.startGame(mode: .hard)
                                }
                            }
                            .padding(.top, 10 * scale)
                        } else {
                            HStack(spacing: 20 * scale) {
                                ModeButton(icon: "⭐", title: "Standard", subtitle: "Clear-cut hand differences", scale: scale) {
                                    game.startGame(mode: .standard)
                                }

                                ModeButton(icon: "🔥", title: "Hard", subtitle: "Tricky kickers & close calls", scale: scale) {
                                    game.startGame(mode: .hard)
                                }
                            }
                            .frame(maxWidth: contentWidth)
                            .padding(.top, 10 * scale)
                        }

                        // Leaderboards - always show both panels (even if empty)
                        if isCompact {
                            VStack(spacing: 20 * scale) {
                                LeaderboardPanel(
                                    title: "Standard",
                                    entries: game.getLeaderboardByMode("standard"),
                                    game: game,
                                    scale: scale
                                )
                                .frame(maxWidth: contentWidth)

                                LeaderboardPanel(
                                    title: "Hard",
                                    entries: game.getLeaderboardByMode("hard"),
                                    game: game,
                                    scale: scale
                                )
                                .frame(maxWidth: contentWidth)
                            }
                            .padding(.top, 20 * scale)
                        } else {
                            HStack(alignment: .top, spacing: 20 * scale) {
                                LeaderboardPanel(
                                    title: "Standard",
                                    entries: game.getLeaderboardByMode("standard"),
                                    game: game,
                                    scale: scale
                                )

                                LeaderboardPanel(
                                    title: "Hard",
                                    entries: game.getLeaderboardByMode("hard"),
                                    game: game,
                                    scale: scale
                                )
                            }
                            .frame(maxWidth: contentWidth)
                            .padding(.top, 20 * scale)
                        }

                        Spacer(minLength: 40 * scale)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20 * scale)
                    .padding(.horizontal, 20 * scale)
                }
                .frame(maxWidth: .infinity)

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

struct ModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    var scale: CGFloat = 1.0
    var maxWidth: CGFloat? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10 * scale) {
                HStack(spacing: 8 * scale) {
                    Text(icon)
                        .font(.system(size: 20 * scale))
                    Text(title)
                        .font(.system(size: 24 * scale, weight: .bold))
                }
                Text(subtitle)
                    .font(.system(size: 14 * scale))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .frame(maxWidth: maxWidth ?? .infinity, minHeight: 80 * scale)
            .padding(.vertical, 25 * scale)
            .padding(.horizontal, 30 * scale)
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
    let title: String
    let entries: [LeaderboardEntry]
    let game: GameState
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 15 * scale) {
            Text(title)
                .font(.system(size: 20 * scale, weight: .bold))

            if entries.isEmpty {
                Text("No scores yet")
                    .font(.system(size: 15 * scale))
                    .opacity(0.6)
                    .padding(.vertical, 20 * scale)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 5 * scale) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.system(size: 15 * scale, weight: .bold))
                                .frame(width: 40 * scale, alignment: .leading)

                            Text(entry.name)
                                .font(.system(size: 15 * scale))
                                .lineLimit(1)

                            Spacer()

                            Text(game.formatTime(entry.time))
                                .font(.system(size: 15 * scale, weight: .bold))
                                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))

                            Button(action: { game.deleteEntry(entry) }) {
                                Text("×")
                                    .font(.system(size: 16 * scale, weight: .medium))
                                    .foregroundColor(.white.opacity(0.25))
                                    .padding(.horizontal, 8 * scale)
                                    .padding(.vertical, 4 * scale)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 15 * scale)
                        .padding(.vertical, 10 * scale)
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
        .padding(20 * scale)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
    }
}

// Keep for backwards compatibility with ResultsScreen
struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    let game: GameState
    var highlightNew: Bool = false
    var scale: CGFloat = 1.0
    var maxWidth: CGFloat = 400
    var isCompact: Bool = false

    var body: some View {
        if isCompact {
            VStack(spacing: 20 * scale) {
                LeaderboardPanel(
                    title: "Standard",
                    entries: game.getLeaderboardByMode("standard"),
                    game: game,
                    scale: scale
                )

                LeaderboardPanel(
                    title: "Hard",
                    entries: game.getLeaderboardByMode("hard"),
                    game: game,
                    scale: scale
                )
            }
        } else {
            HStack(alignment: .top, spacing: 20 * scale) {
                LeaderboardPanel(
                    title: "Standard",
                    entries: game.getLeaderboardByMode("standard"),
                    game: game,
                    scale: scale
                )
                .frame(maxWidth: maxWidth)

                LeaderboardPanel(
                    title: "Hard",
                    entries: game.getLeaderboardByMode("hard"),
                    game: game,
                    scale: scale
                )
                .frame(maxWidth: maxWidth)
            }
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
