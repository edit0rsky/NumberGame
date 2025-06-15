//
//  PlayViewModel.swift
//  NumberGame
//
//  Created by 정민규 on 6/9/25.
//

import Foundation
import Combine

// MARK: - 공통 부모 클래스
/// 게임 로직 전반을 관리하는 ViewModel의 기반 클래스.
/// 숫자 야구 게임의 기본적인 진행 상태(시도 횟수, 시간, 결과 등)를 관리한다.
/// MultiPlayViewModel 등에서 상속하여 확장 사용.
class PlayViewModel: ObservableObject {
    // MARK: - 게임 설정 속성
    var numberCount: Int            // 정답 숫자의 자릿수
    var playerName: String          // 플레이어 이름
    var difficulty: String          // 난이도 (예: "easy", "hard")

    // MARK: - 게임 상태 Published 변수
    @Published var tryCount: Int = 0            // 시도 횟수
    @Published var elapsedTime: TimeInterval = 0 // 경과 시간 (초 단위)
    @Published var resultMessage: String = ""   // 게임 결과 메시지
    @Published var isGameOver: Bool = false     // 게임 종료 여부
    @Published var winner: String? = nil        // 승자 정보 (사용자명 or "AI")

    // MARK: - 타이머 관련 속성
    private var timer: Timer?                   // 경과 시간을 측정할 타이머
    var startTime: Date                         // 게임 시작 시간
    var endTime: Date? = nil                    // 게임 종료 시간

    // MARK: - 초기화
    /// 게임 설정을 초기화하며, 타이머는 startGame에서 시작됨
    init(numberCount: Int, playerName: String, difficulty: String) {
        self.numberCount = numberCount
        self.playerName = playerName
        self.difficulty = difficulty
        self.startTime = Date()
    }

    // MARK: - 게임 시작
    /// 게임 진행 상태 초기화 및 타이머 시작
    func startGame() {
        tryCount = 0
        elapsedTime = 0
        isGameOver = false
        winner = nil
        resultMessage = ""
        startTime = Date()
        endTime = nil
        startTimer()
    }

    // MARK: - 게임 종료
    /// 게임을 종료하고 결과 저장
    func endGame(winner: String, didWin: Bool) {
        self.isGameOver = true
        self.winner = winner
        stopTimer()             // 타이머 정지 및 시간 계산
        saveResult(didWin: didWin) // 기록 저장
    }

    // MARK: - 타이머 제어

    /// 타이머 시작 (1초 간격으로 경과 시간 업데이트)
    func startTimer() {
        stopTimer() // 중복 타이머 방지
        startTime = Date() // 시작 시간 재설정

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if !self.isGameOver {
                self.elapsedTime = Date().timeIntervalSince(self.startTime)
            }
        }
    }

    /// 타이머 중지 및 종료 시간 기록
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        endTime = Date()
        calculateElapsedTime() // 최종 경과 시간 계산
    }

    /// 경과 시간 계산: endTime이 있다면 그것 기준, 아니면 현재 시간 기준
    func calculateElapsedTime() {
        elapsedTime = (endTime ?? Date()).timeIntervalSince(startTime)
    }

    // MARK: - 결과 저장

    /// 게임 결과를 RecordManager에 저장
    func saveResult(didWin: Bool) {
        let result = GameResult(
            playerName: playerName,
            didWin: didWin,
            tryCount: tryCount,
            elapsedTime: elapsedTime,
            difficulty: difficulty,
            date: Date()
        )
        RecordManager.shared.save(result)
    }
}
