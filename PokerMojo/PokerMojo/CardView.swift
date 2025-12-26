//
//  CardView.swift
//  PokerMojo
//

import SwiftUI

struct CardView: View {
    let card: Card
    var isHidden: Bool = false
    var size: CardSize = .regular

    enum CardSize {
        case large   // For iPad gameplay
        case regular
        case small   // For review section

        var width: CGFloat {
            switch self {
            case .large: return 90
            case .regular: return 60
            case .small: return 46
            }
        }

        var height: CGFloat {
            switch self {
            case .large: return 126
            case .regular: return 84
            case .small: return 64
            }
        }

        var cornerRankFont: Font {
            switch self {
            case .large: return .system(size: 20, weight: .bold)
            case .regular: return .system(size: 14, weight: .bold)
            case .small: return .system(size: 11, weight: .bold)
            }
        }

        var cornerSuitFont: Font {
            switch self {
            case .large: return .system(size: 16, weight: .bold)
            case .regular: return .system(size: 12, weight: .bold)
            case .small: return .system(size: 9, weight: .bold)
            }
        }

        var centerSuitFont: Font {
            switch self {
            case .large: return .system(size: 44, weight: .bold)
            case .regular: return .system(size: 28, weight: .bold)
            case .small: return .system(size: 20, weight: .bold)
            }
        }

        var cornerPadding: CGFloat {
            switch self {
            case .large: return 8
            case .regular: return 5
            case .small: return 3
            }
        }

        var spacing: CGFloat {
            switch self {
            case .large: return 8
            case .regular: return 4
            case .small: return 4
            }
        }
    }

    var suitColor: Color {
        switch card.suit {
        case .spades: return .black
        case .hearts: return Color(red: 0.77, green: 0.12, blue: 0.23)
        case .diamonds: return Color(red: 0.08, green: 0.40, blue: 0.75)
        case .clubs: return Color(red: 0.18, green: 0.49, blue: 0.20)
        }
    }

    var body: some View {
        if isHidden {
            cardBack
        } else {
            cardFace
        }
    }

    var cardFace: some View {
        ZStack {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(white: 0.97)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )

            // Top-left corner
            VStack(spacing: -2) {
                Text(card.rank.display)
                    .font(size.cornerRankFont)
                Text(card.suit.rawValue)
                    .font(size.cornerSuitFont)
            }
            .foregroundColor(suitColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(size.cornerPadding)

            // Center suit
            Text(card.suit.rawValue)
                .font(size.centerSuitFont)
                .foregroundColor(suitColor)

            // Bottom-right corner (rotated)
            VStack(spacing: -2) {
                Text(card.rank.display)
                    .font(size.cornerRankFont)
                Text(card.suit.rawValue)
                    .font(size.cornerSuitFont)
            }
            .foregroundColor(suitColor)
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(size.cornerPadding)
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
    }

    var cardBack: some View {
        ZStack {
            // Base with diagonal stripes
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.1, green: 0.37, blue: 0.48))
                .overlay(
                    DiagonalStripes()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )

            // Border
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.16, green: 0.5, blue: 0.72), lineWidth: 3)

            // Inner border
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.15), lineWidth: 2)
                .padding(6)
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
    }
}

struct DiagonalStripes: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let stripeWidth: CGFloat = 4
                let spacing: CGFloat = 8
                let totalWidth = geometry.size.width + geometry.size.height

                var x: CGFloat = -geometry.size.height
                while x < totalWidth {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + geometry.size.height, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: x + geometry.size.height + stripeWidth, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: x + stripeWidth, y: 0))
                    path.closeSubpath()
                    x += spacing
                }
            }
            .fill(Color(red: 0.09, green: 0.31, blue: 0.41))
        }
    }
}

struct HandView: View {
    let hand: EvaluatedHand
    var isHidden: Bool = false
    var cardSize: CardView.CardSize = .regular

    var body: some View {
        HStack(spacing: cardSize.spacing) {
            ForEach(hand.cards) { card in
                CardView(card: card, isHidden: isHidden, size: cardSize)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            CardView(card: Card("A", .spades))
            CardView(card: Card("K", .hearts))
            CardView(card: Card("Q", .diamonds))
            CardView(card: Card("J", .clubs))
            CardView(card: Card("10", .spades), isHidden: true)
        }
        HStack(spacing: 10) {
            CardView(card: Card("A", .spades), size: .small)
            CardView(card: Card("K", .hearts), size: .small)
            CardView(card: Card("Q", .diamonds), size: .small)
        }
    }
    .padding()
    .background(Color.green.opacity(0.3))
}
