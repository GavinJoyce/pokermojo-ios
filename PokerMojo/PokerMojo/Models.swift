//
//  Models.swift
//  PokerMojo
//

import Foundation

enum Suit: String, CaseIterable, Codable {
    case spades = "♠"
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
}

enum Rank: Int, CaseIterable, Comparable, Codable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen = 12, king = 13, ace = 14

    var display: String {
        switch self {
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let rank: Rank
    let suit: Suit

    init(rank: Rank, suit: Suit) {
        self.id = UUID()
        self.rank = rank
        self.suit = suit
    }

    init(_ rankString: String, _ suit: Suit) {
        self.id = UUID()
        self.suit = suit
        switch rankString {
        case "2": self.rank = .two
        case "3": self.rank = .three
        case "4": self.rank = .four
        case "5": self.rank = .five
        case "6": self.rank = .six
        case "7": self.rank = .seven
        case "8": self.rank = .eight
        case "9": self.rank = .nine
        case "10": self.rank = .ten
        case "J": self.rank = .jack
        case "Q": self.rank = .queen
        case "K": self.rank = .king
        case "A": self.rank = .ace
        default: self.rank = .two
        }
    }
}

enum HandRank: Int, Comparable, Codable {
    case highCard = 1
    case pair = 2
    case twoPair = 3
    case threeOfAKind = 4
    case straight = 5
    case flush = 6
    case fullHouse = 7
    case fourOfAKind = 8
    case straightFlush = 9
    case royalFlush = 10

    var name: String {
        switch self {
        case .highCard: return "High Card"
        case .pair: return "Pair"
        case .twoPair: return "Two Pair"
        case .threeOfAKind: return "Three of a Kind"
        case .straight: return "Straight"
        case .flush: return "Flush"
        case .fullHouse: return "Full House"
        case .fourOfAKind: return "Four of a Kind"
        case .straightFlush: return "Straight Flush"
        case .royalFlush: return "Royal Flush"
        }
    }

    static func < (lhs: HandRank, rhs: HandRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct EvaluatedHand: Codable {
    let cards: [Card]
    let rank: HandRank
    let tiebreakers: [Int]

    var name: String { rank.name }
}

struct RoundResult: Identifiable, Codable {
    let id: UUID
    let round: Int
    let handA: EvaluatedHand
    let handB: EvaluatedHand
    let correctHand: String
    let selectedHand: String
    let isCorrect: Bool

    init(round: Int, handA: EvaluatedHand, handB: EvaluatedHand, correctHand: String, selectedHand: String) {
        self.id = UUID()
        self.round = round
        self.handA = handA
        self.handB = handB
        self.correctHand = correctHand
        self.selectedHand = selectedHand
        self.isCorrect = correctHand == selectedHand
    }
}

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let time: Int
    let mode: String
    let date: Date
    var isNew: Bool

    init(name: String, time: Int, mode: String) {
        self.id = UUID()
        self.name = name
        self.time = time
        self.mode = mode
        self.date = Date()
        self.isNew = true
    }
}

enum GameMode: String, Codable {
    case standard
    case hard
}

enum Screen {
    case start
    case game
    case results
}
