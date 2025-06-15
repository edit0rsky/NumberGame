//
//  AudioManager.swift
//  NumberGame
//
//  Created by 정민규 on 6/15/25.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    private var bgmPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?

    // 배경음악
    func playBackgroundMusic() {
        playAudio(&bgmPlayer, fileName: "bgm", fileExtension: "mp3", loop: true, volume: 0.4)
    }

    func stopBackgroundMusic() {
        bgmPlayer?.stop()
    }

    // 효과음
    func playEffectSound(named name: String, volume: Float = 1.0) {
        playAudio(&effectPlayer, fileName: name, fileExtension: "mp3", loop: false, volume: volume)
    }

    private func playAudio(_ player: inout AVAudioPlayer?, fileName: String, fileExtension: String, loop: Bool, volume: Float) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("파일 '\(fileName).\(fileExtension)' 없음")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("\(fileName) 재생 실패:", error)
        }
    }
}
