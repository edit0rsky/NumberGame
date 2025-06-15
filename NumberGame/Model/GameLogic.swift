//
//  GameLogic.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//
import Foundation

struct GameLogic {
    let answer: [Int]

    // 디버깅용 고정 정답
    init(numberCount: Int = 3) {
        if numberCount == 3 {
            self.answer = [1, 2, 3]
            // self.answer = Array((0...9).shuffled().prefix(numberCount))
        } else if numberCount == 4 {
            self.answer = [1, 2, 3, 4]
            // self.answer = Array((0...9).shuffled().prefix(numberCount))
        } else {
            self.answer = Array((0...9).shuffled().prefix(numberCount))
        }
    }

    // 고정 정답 사용용 (멀티플레이 사용자 입력 대응)
    init(fixedAnswer: [Int]) {
        self.answer = fixedAnswer
    }

    // 추측 결과 확인
    func checkGuess(_ guess: [Int]) -> (strike: Int, ball: Int, isWin: Bool) {
        var strike = 0, ball = 0

        for (i, g) in guess.enumerated() {
            if g == answer[i] {
                strike += 1
            } else if answer.contains(g) {
                ball += 1
            }
        }

        return (strike, ball, strike == answer.count)
    }

    // 디버깅용
    func debugAnswer() -> String {
        answer.map(String.init).joined()
    }
}
