//
//  PokerLogic.swift
//  PokerMojo
//

import Foundation

struct PokerLogic {

    static func createDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        return deck
    }

    static func evaluateHand(_ cards: [Card]) -> EvaluatedHand {
        let sorted = cards.sorted { $0.rank > $1.rank }
        let values = sorted.map { $0.rank.rawValue }
        let suits = sorted.map { $0.suit }

        let isFlush = suits.allSatisfy { $0 == suits[0] }
        let isWheel = values == [14, 5, 4, 3, 2] // A-2-3-4-5
        let isStraight = isWheel || zip(values, values.dropFirst()).allSatisfy { $0 - $1 == 1 }

        var counts: [Int: Int] = [:]
        for v in values {
            counts[v, default: 0] += 1
        }
        let countValues = counts.values.sorted(by: >)
        let countKeys = counts.sorted {
            if $0.value != $1.value { return $0.value > $1.value }
            return $0.key > $1.key
        }

        let rank: HandRank
        let tiebreakers: [Int]

        if isFlush && isStraight {
            if values[0] == 14 && values[1] == 13 {
                rank = .royalFlush
            } else {
                rank = .straightFlush
            }
            tiebreakers = isWheel ? [5] : [values[0]]
        } else if countValues[0] == 4 {
            rank = .fourOfAKind
            let quadValue = countKeys.first { $0.value == 4 }!.key
            let kicker = countKeys.first { $0.value == 1 }!.key
            tiebreakers = [quadValue, kicker]
        } else if countValues[0] == 3 && countValues[1] == 2 {
            rank = .fullHouse
            let tripValue = countKeys.first { $0.value == 3 }!.key
            let pairValue = countKeys.first { $0.value == 2 }!.key
            tiebreakers = [tripValue, pairValue]
        } else if isFlush {
            rank = .flush
            tiebreakers = values
        } else if isStraight {
            rank = .straight
            tiebreakers = isWheel ? [5] : [values[0]]
        } else if countValues[0] == 3 {
            rank = .threeOfAKind
            let tripValue = countKeys.first { $0.value == 3 }!.key
            let kickers = countKeys.filter { $0.value == 1 }.map { $0.key }.sorted(by: >)
            tiebreakers = [tripValue] + kickers
        } else if countValues[0] == 2 && countValues[1] == 2 {
            rank = .twoPair
            let pairs = countKeys.filter { $0.value == 2 }.map { $0.key }.sorted(by: >)
            let kicker = countKeys.first { $0.value == 1 }!.key
            tiebreakers = pairs + [kicker]
        } else if countValues[0] == 2 {
            rank = .pair
            let pairValue = countKeys.first { $0.value == 2 }!.key
            let kickers = countKeys.filter { $0.value == 1 }.map { $0.key }.sorted(by: >)
            tiebreakers = [pairValue] + kickers
        } else {
            rank = .highCard
            tiebreakers = values
        }

        return EvaluatedHand(cards: cards, rank: rank, tiebreakers: tiebreakers)
    }

    static func compareHands(_ handA: EvaluatedHand, _ handB: EvaluatedHand) -> String {
        if handA.rank != handB.rank {
            return handA.rank > handB.rank ? "A" : "B"
        }
        for i in 0..<handA.tiebreakers.count {
            if handA.tiebreakers[i] != handB.tiebreakers[i] {
                return handA.tiebreakers[i] > handB.tiebreakers[i] ? "A" : "B"
            }
        }
        return "tie"
    }

    // Helper to create cards with placeholder suits (will be randomized later)
    private static func c(_ rank: String, _ suit: Suit) -> Card {
        Card(rank, suit)
    }

    // Randomize suits for a hand while preserving the hand type
    private static func randomizeSuits(_ cards: [Card], isFlush: Bool) -> [Card] {
        let suits: [Suit] = [.spades, .hearts, .diamonds, .clubs]

        if isFlush {
            // All cards must have the same suit for a flush
            let randomSuit = suits.randomElement()!
            return cards.map { Card($0.rank.display, randomSuit) }
        } else {
            // Assign random suits to each card, avoiding accidental flushes
            var result: [Card] = []
            var usedSuits: [String: [Suit]] = [:]

            for card in cards {
                let key = card.rank.display
                if usedSuits[key] == nil { usedSuits[key] = [] }

                // Find a suit not yet used for this rank
                var availableSuits = suits.filter { !usedSuits[key]!.contains($0) }
                if availableSuits.isEmpty { availableSuits = suits }

                let randomSuit = availableSuits.randomElement()!
                usedSuits[key]!.append(randomSuit)
                result.append(Card(key, randomSuit))
            }

            // Check if we accidentally created a flush, if so, change one card's suit
            var suitCounts: [Suit: Int] = [:]
            for card in result {
                suitCounts[card.suit, default: 0] += 1
            }
            if let (maxSuit, count) = suitCounts.max(by: { $0.value < $1.value }), count >= 5 {
                let otherSuit = suits.first { $0 != maxSuit }!
                if let index = result.firstIndex(where: { $0.suit == maxSuit }) {
                    let oldCard = result[index]
                    result[index] = Card(oldCard.rank.display, otherSuit)
                }
            }

            return result
        }
    }

    // Check if cards form a flush
    private static func isFlush(_ cards: [Card]) -> Bool {
        let suits = Set(cards.map { $0.suit })
        return suits.count == 1
    }

    // All 44 curated tricky scenarios for hard mode
    static func generateTrickyHands() -> (handA: EvaluatedHand, handB: EvaluatedHand, winner: String) {
        let scenarios: [() -> ([Card], [Card])] = [
            // 1. Flush vs Flush (different high cards)
            { ([c("K", .spades), c("J", .spades), c("8", .spades), c("5", .spades), c("3", .spades)],
               [c("Q", .hearts), c("J", .hearts), c("9", .hearts), c("6", .hearts), c("2", .hearts)]) },

            // 2. Flush vs Flush (close, kicker decides)
            { ([c("A", .diamonds), c("10", .diamonds), c("8", .diamonds), c("4", .diamonds), c("2", .diamonds)],
               [c("A", .clubs), c("10", .clubs), c("7", .clubs), c("5", .clubs), c("3", .clubs)]) },

            // 3. Full House vs Full House (different trips)
            { ([c("J", .spades), c("J", .hearts), c("J", .diamonds), c("4", .clubs), c("4", .spades)],
               [c("9", .spades), c("9", .hearts), c("9", .diamonds), c("A", .clubs), c("A", .spades)]) },

            // 4. Full House vs Four of a Kind
            { ([c("7", .spades), c("7", .hearts), c("7", .diamonds), c("K", .clubs), c("K", .hearts)],
               [c("8", .clubs), c("8", .spades), c("8", .hearts), c("8", .diamonds), c("Q", .clubs)]) },

            // 5. Straight vs Straight (different high)
            { ([c("9", .spades), c("8", .hearts), c("7", .diamonds), c("6", .clubs), c("5", .spades)],
               [c("8", .spades), c("7", .hearts), c("6", .diamonds), c("5", .clubs), c("4", .spades)]) },

            // 6. Straight vs Wheel (6-high vs 5-high)
            { ([c("6", .spades), c("5", .hearts), c("4", .diamonds), c("3", .clubs), c("2", .spades)],
               [c("5", .clubs), c("4", .spades), c("3", .hearts), c("2", .diamonds), c("A", .clubs)]) },

            // 7. Pair vs Pair (same pair, kicker decides)
            { ([c("Q", .spades), c("Q", .hearts), c("J", .diamonds), c("8", .clubs), c("3", .spades)],
               [c("Q", .diamonds), c("Q", .clubs), c("10", .spades), c("9", .hearts), c("4", .diamonds)]) },

            // 8. Pair vs Pair (different pairs)
            { ([c("10", .spades), c("10", .hearts), c("A", .diamonds), c("K", .clubs), c("5", .spades)],
               [c("J", .spades), c("J", .hearts), c("7", .diamonds), c("4", .clubs), c("2", .spades)]) },

            // 9. Two Pair vs Two Pair (same high pair, different low pair)
            { ([c("K", .spades), c("K", .hearts), c("8", .diamonds), c("8", .clubs), c("3", .spades)],
               [c("K", .diamonds), c("K", .clubs), c("6", .spades), c("6", .hearts), c("A", .diamonds)]) },

            // 10. Two Pair vs Two Pair (different high pairs)
            { ([c("Q", .spades), c("Q", .hearts), c("5", .diamonds), c("5", .clubs), c("9", .spades)],
               [c("J", .diamonds), c("J", .clubs), c("10", .spades), c("10", .hearts), c("A", .diamonds)]) },

            // 11. Three of a Kind vs Three of a Kind
            { ([c("8", .spades), c("8", .hearts), c("8", .diamonds), c("K", .clubs), c("4", .spades)],
               [c("6", .diamonds), c("6", .clubs), c("6", .spades), c("A", .hearts), c("Q", .diamonds)]) },

            // 12. High Card vs High Card (tricky)
            { ([c("A", .spades), c("J", .hearts), c("9", .diamonds), c("6", .clubs), c("3", .spades)],
               [c("A", .diamonds), c("J", .clubs), c("9", .spades), c("5", .hearts), c("4", .diamonds)]) },

            // 13. Straight Flush vs Flush (rare hand!)
            { ([c("8", .hearts), c("7", .hearts), c("6", .hearts), c("5", .hearts), c("4", .hearts)],
               [c("A", .spades), c("K", .spades), c("Q", .spades), c("J", .spades), c("3", .spades)]) },

            // 14. Straight Flush vs Straight Flush
            { ([c("9", .diamonds), c("8", .diamonds), c("7", .diamonds), c("6", .diamonds), c("5", .diamonds)],
               [c("7", .clubs), c("6", .clubs), c("5", .clubs), c("4", .clubs), c("3", .clubs)]) },

            // 15. Four of a Kind vs Full House
            { ([c("5", .spades), c("5", .hearts), c("5", .diamonds), c("5", .clubs), c("2", .spades)],
               [c("A", .spades), c("A", .hearts), c("A", .diamonds), c("K", .clubs), c("K", .spades)]) },

            // 16. Four of a Kind vs Four of a Kind
            { ([c("9", .spades), c("9", .hearts), c("9", .diamonds), c("9", .clubs), c("3", .spades)],
               [c("7", .spades), c("7", .hearts), c("7", .diamonds), c("7", .clubs), c("A", .spades)]) },

            // 17. Straight vs Three of a Kind
            { ([c("6", .spades), c("5", .hearts), c("4", .diamonds), c("3", .clubs), c("2", .spades)],
               [c("A", .diamonds), c("A", .clubs), c("A", .spades), c("K", .hearts), c("Q", .diamonds)]) },

            // 18. Flush vs Straight
            { ([c("9", .hearts), c("7", .hearts), c("5", .hearts), c("3", .hearts), c("2", .hearts)],
               [c("A", .spades), c("K", .hearts), c("Q", .diamonds), c("J", .clubs), c("10", .spades)]) },

            // 19. Flush vs Flush (third card decides)
            { ([c("A", .spades), c("Q", .spades), c("10", .spades), c("6", .spades), c("2", .spades)],
               [c("A", .hearts), c("Q", .hearts), c("9", .hearts), c("7", .hearts), c("4", .hearts)]) },

            // 20. Flush vs Flush (fourth card decides)
            { ([c("K", .diamonds), c("J", .diamonds), c("9", .diamonds), c("7", .diamonds), c("3", .diamonds)],
               [c("K", .clubs), c("J", .clubs), c("9", .clubs), c("5", .clubs), c("4", .clubs)]) },

            // 21. Straight (broadway) vs Straight (king high)
            { ([c("A", .spades), c("K", .hearts), c("Q", .diamonds), c("J", .clubs), c("10", .spades)],
               [c("K", .diamonds), c("Q", .clubs), c("J", .spades), c("10", .hearts), c("9", .diamonds)]) },

            // 22. Straight (queen high) vs Straight (jack high)
            { ([c("Q", .spades), c("J", .hearts), c("10", .diamonds), c("9", .clubs), c("8", .spades)],
               [c("J", .diamonds), c("10", .clubs), c("9", .spades), c("8", .hearts), c("7", .diamonds)]) },

            // 23. Straight (7-high) vs Wheel (5-high)
            { ([c("7", .spades), c("6", .hearts), c("5", .diamonds), c("4", .clubs), c("3", .spades)],
               [c("5", .clubs), c("4", .spades), c("3", .hearts), c("2", .diamonds), c("A", .clubs)]) },

            // 24. Two Pair vs Two Pair (same pairs, kicker decides)
            { ([c("A", .spades), c("A", .hearts), c("9", .diamonds), c("9", .clubs), c("K", .spades)],
               [c("A", .diamonds), c("A", .clubs), c("9", .spades), c("9", .hearts), c("Q", .diamonds)]) },

            // 25. Two Pair vs Two Pair (aces over vs kings over)
            { ([c("A", .spades), c("A", .hearts), c("4", .diamonds), c("4", .clubs), c("7", .spades)],
               [c("K", .diamonds), c("K", .clubs), c("Q", .spades), c("Q", .hearts), c("J", .diamonds)]) },

            // 26. Two Pair (low pairs) vs Two Pair (low pairs)
            { ([c("6", .spades), c("6", .hearts), c("4", .diamonds), c("4", .clubs), c("A", .spades)],
               [c("5", .diamonds), c("5", .clubs), c("3", .spades), c("3", .hearts), c("K", .diamonds)]) },

            // 27. Pair vs Pair (aces, second kicker decides)
            { ([c("A", .spades), c("A", .hearts), c("K", .diamonds), c("10", .clubs), c("4", .spades)],
               [c("A", .diamonds), c("A", .clubs), c("K", .spades), c("9", .hearts), c("5", .diamonds)]) },

            // 28. Pair vs Pair (low pairs, kickers decide)
            { ([c("3", .spades), c("3", .hearts), c("A", .diamonds), c("K", .clubs), c("Q", .spades)],
               [c("3", .diamonds), c("3", .clubs), c("A", .spades), c("K", .hearts), c("J", .diamonds)]) },

            // 29. Pair vs Pair (consecutive pairs)
            { ([c("8", .spades), c("8", .hearts), c("A", .diamonds), c("K", .clubs), c("Q", .spades)],
               [c("7", .diamonds), c("7", .clubs), c("A", .spades), c("K", .hearts), c("Q", .diamonds)]) },

            // 30. Three of a Kind (close ranks)
            { ([c("10", .spades), c("10", .hearts), c("10", .diamonds), c("5", .clubs), c("2", .spades)],
               [c("9", .diamonds), c("9", .clubs), c("9", .spades), c("A", .hearts), c("K", .diamonds)]) },

            // 31. Three of a Kind (aces vs kings)
            { ([c("A", .spades), c("A", .hearts), c("A", .diamonds), c("4", .clubs), c("2", .spades)],
               [c("K", .diamonds), c("K", .clubs), c("K", .spades), c("Q", .hearts), c("J", .diamonds)]) },

            // 32. High Card vs High Card (ace high vs ace high, second card)
            { ([c("A", .spades), c("K", .hearts), c("8", .diamonds), c("5", .clubs), c("3", .spades)],
               [c("A", .diamonds), c("Q", .clubs), c("J", .spades), c("10", .hearts), c("4", .diamonds)]) },

            // 33. High Card vs High Card (king high vs king high)
            { ([c("K", .spades), c("Q", .hearts), c("10", .diamonds), c("6", .clubs), c("2", .spades)],
               [c("K", .diamonds), c("Q", .clubs), c("9", .spades), c("7", .hearts), c("3", .diamonds)]) },

            // 34. High Card vs High Card (fifth card decides)
            { ([c("A", .spades), c("J", .hearts), c("9", .diamonds), c("7", .clubs), c("4", .spades)],
               [c("A", .diamonds), c("J", .clubs), c("9", .spades), c("7", .hearts), c("3", .diamonds)]) },

            // 35. Full House (kings full) vs Full House (queens full)
            { ([c("K", .spades), c("K", .hearts), c("K", .diamonds), c("6", .clubs), c("6", .spades)],
               [c("Q", .diamonds), c("Q", .clubs), c("Q", .spades), c("A", .hearts), c("A", .diamonds)]) },

            // 36. Full House (threes full of aces) vs Full House (twos full of kings)
            { ([c("3", .spades), c("3", .hearts), c("3", .diamonds), c("A", .clubs), c("A", .spades)],
               [c("2", .diamonds), c("2", .clubs), c("2", .spades), c("K", .hearts), c("K", .diamonds)]) },

            // 37. Straight Flush (steel wheel) vs Straight
            { ([c("5", .hearts), c("4", .hearts), c("3", .hearts), c("2", .hearts), c("A", .hearts)],
               [c("A", .spades), c("K", .hearts), c("Q", .diamonds), c("J", .clubs), c("10", .spades)]) },

            // 38. Four of a Kind (low) vs Four of a Kind (lower)
            { ([c("4", .spades), c("4", .hearts), c("4", .diamonds), c("4", .clubs), c("A", .spades)],
               [c("3", .diamonds), c("3", .clubs), c("3", .spades), c("3", .hearts), c("K", .diamonds)]) },

            // 39. Full House vs Flush (common mistake)
            { ([c("6", .spades), c("6", .hearts), c("6", .diamonds), c("2", .clubs), c("2", .spades)],
               [c("A", .clubs), c("K", .clubs), c("Q", .clubs), c("J", .clubs), c("9", .clubs)]) },

            // 40. Two Pair vs Pair (close decision)
            { ([c("5", .spades), c("5", .hearts), c("3", .diamonds), c("3", .clubs), c("2", .spades)],
               [c("A", .diamonds), c("A", .clubs), c("K", .spades), c("Q", .hearts), c("J", .diamonds)]) },

            // 41. Pair vs High Card (close)
            { ([c("2", .spades), c("2", .hearts), c("7", .diamonds), c("5", .clubs), c("3", .spades)],
               [c("A", .diamonds), c("K", .clubs), c("Q", .spades), c("J", .hearts), c("9", .diamonds)]) },

            // 42. Three of a Kind vs Two Pair (common mistake)
            { ([c("4", .spades), c("4", .hearts), c("4", .diamonds), c("3", .clubs), c("2", .spades)],
               [c("A", .diamonds), c("A", .clubs), c("K", .spades), c("K", .hearts), c("Q", .diamonds)]) },

            // 43. Almost Straight Flush (one card off-suit) vs Flush - it's just a straight!
            { ([c("9", .hearts), c("8", .hearts), c("7", .hearts), c("6", .hearts), c("5", .spades)],
               [c("A", .diamonds), c("K", .diamonds), c("J", .diamonds), c("8", .diamonds), c("3", .diamonds)]) },

            // 44. Almost Straight Flush (gap in sequence) vs Straight - it's just a flush!
            { ([c("J", .clubs), c("10", .clubs), c("8", .clubs), c("7", .clubs), c("6", .clubs)],
               [c("10", .spades), c("9", .hearts), c("8", .diamonds), c("7", .clubs), c("6", .spades)]) },
        ]

        var (cardsA, cardsB) = scenarios.randomElement()!()

        // Detect if each hand is a flush to preserve during randomization
        let isFlushA = isFlush(cardsA)
        let isFlushB = isFlush(cardsB)

        // Randomize suits while preserving hand types
        cardsA = randomizeSuits(cardsA, isFlush: isFlushA)
        cardsB = randomizeSuits(cardsB, isFlush: isFlushB)

        // Randomly swap A and B so the winner isn't predictable
        if Bool.random() {
            swap(&cardsA, &cardsB)
        }

        // Shuffle card order within each hand
        cardsA.shuffle()
        cardsB.shuffle()

        let handA = evaluateHand(cardsA)
        let handB = evaluateHand(cardsB)
        let winner = compareHands(handA, handB)

        return (handA, handB, winner)
    }

    static func generateRandomHands() -> (handA: EvaluatedHand, handB: EvaluatedHand, winner: String) {
        var handA: EvaluatedHand
        var handB: EvaluatedHand
        var winner: String

        repeat {
            var deck = createDeck().shuffled()
            let cardsA = Array(deck.prefix(5))
            deck.removeFirst(5)
            let cardsB = Array(deck.prefix(5))

            handA = evaluateHand(cardsA)
            handB = evaluateHand(cardsB)
            winner = compareHands(handA, handB)
        } while winner == "tie" || handA.rank == handB.rank

        return (handA, handB, winner)
    }

    static func generateHands(mode: GameMode) -> (handA: EvaluatedHand, handB: EvaluatedHand, winner: String) {
        if mode == .hard {
            // Hard mode: 50% curated tricky scenarios, 50% random hands
            if Bool.random() {
                return generateTrickyHands()
            } else {
                return generateRandomHands()
            }
        } else {
            // Standard mode: random hands with different types
            return generateRandomHands()
        }
    }
}
