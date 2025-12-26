//
//  ContentView.swift
//  PokerMojo
//

import SwiftUI

struct ContentView: View {
    @State private var game = GameState()

    var body: some View {
        GeometryReader { geometry in
            let scale = min(max(geometry.size.width / 1024, 0.6), 1.3)

            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.28, blue: 0.16), Color(red: 0.18, green: 0.35, blue: 0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10 * scale) {
                        Text("🃏 Poker Mojo")
                            .font(.system(size: 40 * scale, weight: .bold))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)

                        if game.screen == .start {
                            Text("Which hand wins?")
                                .font(.system(size: 18 * scale))
                                .opacity(0.8)
                        }
                    }
                    .padding(.top, 20 * scale)

                    // Screen content
                    switch game.screen {
                    case .start:
                        StartScreen(game: game)
                    case .game:
                        GameScreen(game: game)
                    case .results:
                        ResultsScreen(game: game)
                    }
                }

                // Countdown overlay at top level to cover everything
                if let countdown = game.countdown {
                    CountdownOverlay(number: countdown)
                }
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
