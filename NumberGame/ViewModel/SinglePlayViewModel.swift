//
//  SinglePlayViewModel.swift
//  NumberGame
//
//  Created by 정민규 on 6/9/25.
//

import Foundation

/// 싱글 플레이 모드에서 사용되는 ViewModel 클래스입니다.
/// 사용자의 추측을 처리하고, 정답 여부를 판단하며, 기록과 결과 메시지를 관리합니다.
/// PlayViewModel을 상속받아 공통된 게임 로직(타이머, 결과 저장 등)을 재사용합니다.
class SinglePlayViewModel: PlayViewModel {
    
    /// 사용자가 현재 입력한 숫자 배열
    @Published var userGuess: [Int] = []
    
    /// 지금까지 시도한 모든 추측과 결과 기록
    @Published var guessHistory: [String] = []

    /// 실제 게임 로직 처리 객체 (정답 생성 및 판정)
    private var gameLogic: GameLogic!

    // MARK: - 게임 시작

    /// 새로운 게임을 시작하고 모든 상태를 초기화합니다.
    func startNewGame() {
        gameLogic = GameLogic(numberCount: numberCount) // 새 정답 생성
        userGuess = []         // 사용자 입력 초기화
        guessHistory = []      // 기록 초기화
        tryCount = 0           // 시도 횟수 초기화
        resultMessage = ""     // 결과 메시지 초기화
        isGameOver = false     // 게임 상태 초기화
        startTimer()           // 타이머 시작
    }

    // MARK: - 사용자 추측 처리

    /// 사용자의 숫자 추측을 받아 결과를 계산하고, 기록을 갱신합니다.
    /// - Parameter guess: 사용자가 제출한 숫자 배열
    func submitGuess(_ guess: [Int]) {
        guard !isGameOver else { return } // 게임 종료 후에는 처리하지 않음

        tryCount += 1              // 시도 횟수 증가
        userGuess = guess          // 현재 추측 저장

        let result = gameLogic.checkGuess(guess) // 정답과 비교

        if result.isWin {
            resultMessage = "🎉 정답입니다!" // 정답일 경우
            stopTimer()
            calculateElapsedTime()
            endGame(winner: playerName, didWin: true)
        } else if result.strike == 0 && result.ball == 0 {
            resultMessage = "Out" // 아무것도 맞지 않음
        } else {
            resultMessage = "\(result.strike)S \(result.ball)B" // 힌트 제공
        }

        // 기록 문자열 생성 및 저장 (예: 123 : 1S 2B)
        let formatted = "\(guess.map(String.init).joined()) : \(resultMessage)"
        guessHistory.append(formatted)
    }

    // MARK: - 포기 처리

    /// 사용자가 게임을 포기했을 때 처리
    func forfeitGame() {
        stopTimer()
        calculateElapsedTime()
        resultMessage = "🏳️ 게임을 포기했습니다."
        endGame(winner: "AI", didWin: false)
    }

    // MARK: - 디버깅용

    /// 현재 게임의 정답을 문자열로 반환 (디버깅용)
    func getAnswerForDebug() -> String {
        gameLogic.debugAnswer()
    }
}
