//
//  SoundManager.swift
//  PokerMojo
//

import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?
    private var toneEngine: AVAudioEngine?
    private var toneNode: AVAudioSourceNode?

    private init() {
        // Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    // Play countdown beep (same tone for each number)
    func playCountdownBeep(number: Int) {
        playTone(frequency: 440, duration: 0.15) // A4
    }

    // Play success sound (ascending arpeggio)
    func playCorrect() {
        // Quick two-tone success sound
        playTone(frequency: 523, duration: 0.1) // C5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playTone(frequency: 659, duration: 0.15) // E5
        }
    }

    // Play error sound (descending tone)
    func playWrong() {
        // Descending two-tone error sound
        playTone(frequency: 349, duration: 0.15) // F4
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.playTone(frequency: 262, duration: 0.2) // C4
        }
    }

    // Play game start fanfare
    func playGameStart() {
        playTone(frequency: 523, duration: 0.1) // C5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.playTone(frequency: 659, duration: 0.1) // E5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            self.playTone(frequency: 784, duration: 0.2) // G5
        }
    }

    // Play victory fanfare for perfect score
    func playVictory() {
        playTone(frequency: 523, duration: 0.12) // C5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.playTone(frequency: 659, duration: 0.12) // E5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            self.playTone(frequency: 784, duration: 0.12) // G5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            self.playTone(frequency: 1047, duration: 0.3) // C6
        }
    }

    // Generate and play a tone
    private func playTone(frequency: Double, duration: Double) {
        let sampleRate: Double = 44100
        let amplitude: Float = 0.3

        let engine = AVAudioEngine()
        let mainMixer = engine.mainMixerNode
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)

        var phase: Double = 0
        let phaseIncrement = (2.0 * .pi * frequency) / sampleRate

        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                let value = Float(sin(phase)) * amplitude
                phase += phaseIncrement
                if phase >= 2.0 * .pi {
                    phase -= 2.0 * .pi
                }

                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }

            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: mainMixer, format: outputFormat)
        engine.connect(mainMixer, to: output, format: outputFormat)

        do {
            try engine.start()
        } catch {
            print("Could not start audio engine: \(error)")
            return
        }

        // Stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            engine.stop()
        }
    }
}
