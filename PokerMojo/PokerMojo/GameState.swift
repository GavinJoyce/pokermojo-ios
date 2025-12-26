//
//  GameState.swift
//  PokerMojo
//

import SwiftUI

@Observable
class GameState {
    var screen: Screen = .start
    var mode: GameMode = .standard
    var round: Int = 1
    var score: Int = 0
    var elapsedTime: Int = 0
    var countdown: Int? = nil

    var handA: EvaluatedHand?
    var handB: EvaluatedHand?
    var correctHand: String = ""
    var selectedHand: String? = nil
    var showResult: Bool = false

    var results: [RoundResult] = []
    var leaderboard: [LeaderboardEntry] = []

    var playerName: String = ""
    var nameSaved: Bool = false
    var deleteToast: String? = nil

    private var timer: Timer?
    private var countdownTimer: Timer?

    init() {
        loadLeaderboard()
    }

    func startGame(mode: GameMode) {
        self.mode = mode
        self.round = 1
        self.score = 0
        self.elapsedTime = 0
        self.results = []
        self.nameSaved = false
        self.playerName = ""
        self.screen = .game
        generateNewHands()
        startCountdown()
    }

    func startCountdown() {
        countdownTimer?.invalidate()
        countdown = 3
        SoundManager.shared.playCountdownBeep(number: 3)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if let current = self.countdown, current > 1 {
                self.countdown = current - 1
                SoundManager.shared.playCountdownBeep(number: current - 1)
            } else {
                self.countdown = nil
                timer.invalidate()
                SoundManager.shared.playGameStart()
                self.startTimer()
            }
        }
    }

    func cancelGame() {
        stopTimer()
        countdownTimer?.invalidate()
        countdown = nil
        screen = .start
    }

    func generateNewHands() {
        let (a, b, winner) = PokerLogic.generateHands(mode: mode)
        handA = a
        handB = b
        correctHand = winner
        selectedHand = nil
        showResult = false
    }

    func selectHand(_ hand: String) {
        guard !showResult, countdown == nil else { return }
        guard let handA = handA, let handB = handB else { return }

        selectedHand = hand
        let isCorrect = hand == correctHand

        let result = RoundResult(
            round: round,
            handA: handA,
            handB: handB,
            correctHand: correctHand,
            selectedHand: hand
        )
        results.append(result)

        if isCorrect {
            score += 1
            showResult = true
            SoundManager.shared.playCorrect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.advanceRound()
            }
        } else {
            // Wrong answer - game over, stop the timer
            stopTimer()
            showResult = true
            SoundManager.shared.playWrong()
        }
    }

    func advanceRound() {
        if round < 20 {
            round += 1
            generateNewHands()
        } else {
            stopTimer()
            screen = .results
            // Perfect score!
            if score == 20 {
                SoundManager.shared.playVictory()
            }
            leaderboard = leaderboard.map { entry in
                var e = entry
                e.isNew = false
                return e
            }
        }
    }

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    func saveName() {
        guard !playerName.trimmingCharacters(in: .whitespaces).isEmpty, score == 20 else { return }

        var entry = LeaderboardEntry(
            name: playerName.trimmingCharacters(in: .whitespaces),
            time: elapsedTime,
            mode: mode.rawValue
        )
        entry.isNew = true

        leaderboard.append(entry)
        leaderboard.sort { a, b in
            if a.mode != b.mode { return a.mode == "hard" }
            return a.time < b.time
        }

        saveLeaderboard()
        nameSaved = true
    }

    func resetGame() {
        screen = .start
        loadLeaderboard()
    }

    func getIncorrectResults() -> [RoundResult] {
        results.filter { !$0.isCorrect }
    }

    func getLeaderboardByMode(_ mode: String) -> [LeaderboardEntry] {
        leaderboard
            .filter { $0.mode == mode }
            .sorted { $0.time < $1.time }
            .prefix(10)
            .map { $0 }
    }

    func deleteEntry(_ entry: LeaderboardEntry) {
        leaderboard.removeAll { $0.id == entry.id }
        saveLeaderboard()

        // Show toast
        deleteToast = "Entry deleted"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.deleteToast = nil
        }
    }

    private func loadLeaderboard() {
        if let data = UserDefaults.standard.data(forKey: "pokerMojoLeaderboard"),
           let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            leaderboard = decoded
        }
    }

    private func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: "pokerMojoLeaderboard")
        }
    }
}
