//
//  MultiPlayViewModel.swift
//  NumberGame
//
//  Created by 정민규 on 6/9/25.
//

import Foundation

/// COM과 사용자의 멀티 플레이 게임을 관리하는 뷰 모델
class MultiPlayViewModel: PlayViewModel {
    // MARK: - Published Properties

    /// 사용자 입력 텍스트
    @Published var userGuessText: String = ""
    /// COM이 마지막으로 예측한 숫자 문자열
    @Published var aiGuessText: String = ""
    /// 사용자 기록 목록 (ex. "123 : 1S 1B")
    @Published var userHistory: [String] = []
    /// COM 기록 목록
    @Published var aiHistory: [String] = []
    /// 현재 차례 (사용자 or COM)
    @Published var currentTurn: Turn = .user

    /// 턴 종류를 정의하는 열거형
    enum Turn { case user, ai }

    // MARK: - Private Properties

    /// 사용자 정답 로직 객체 (사용자가 설정한 정답을 기준으로 판단)
    private var userLogic: GameLogic?
    /// COM의 추측 판단 로직 객체
    private let aiLogic: GameLogic

    /// 상 난이도 COM: 가능한 모든 후보 조합 리스트
    private var aiCandidates: [[Int]] = []

    /// 하 난이도 COM 전용 상태 관리
    private var aiEasyPhase: EasyAIPhase = .identifyingNumbers
    private var aiEasyNumberPool: Set<Int> = Set(0...9)       // 아직 확인되지 않은 숫자 목록
    private var aiGuessedNumbers: Set<Int> = []               // COM이 예측에 사용한 숫자
    private var aiEliminatedNumbers: Set<Int> = []            // 정답에 포함되지 않는 것으로 확인된 숫자
    private var aiConfirmedNumbers: Set<Int> = []             // 정답에 포함되는 것으로 확정된 숫자

    /// 하 난이도 COM의 현재 단계를 나타내는 열거형
    private enum EasyAIPhase {
        case identifyingNumbers    // 정답에 포함된 숫자 식별 단계
        case determiningPositions  // 정답 숫자의 위치를 찾는 단계
    }

    var eliminatedNumbers: Set<Int> { aiEliminatedNumbers }

    // MARK: - Initializer

    init(numberCount: Int, settingsVM: SettingsViewModel) {
        self.aiLogic = GameLogic(numberCount: numberCount)
        super.init(
            numberCount: numberCount,
            playerName: settingsVM.playerName,
            difficulty: settingsVM.aiDifficulty.rawValue
        )

        // 상 난이도는 가능한 모든 숫자 조합을 초기 후보로 설정
        if self.difficulty == AIDifficulty.hard.rawValue {
            self.aiCandidates = generatePermutations(from: Array(0...9), count: numberCount)
        }
    }

    // MARK: - 게임 시작

    /// 사용자가 입력한 정답 텍스트를 GameLogic에 설정
    func setUserAnswer(from text: String) {
        let numbers = Array(text).compactMap { Int(String($0)) }
        guard numbers.count == numberCount, Set(numbers).count == numberCount else { return }

        self.userLogic = GameLogic(fixedAnswer: numbers)
        self.startGame()
    }

    // MARK: - 사용자 턴

    /// 사용자의 추측을 처리하는 함수
    func submitUserGuess() {
        guard let _ = userLogic else { return }

        let guess = Array(userGuessText.prefix(numberCount)).compactMap { Int(String($0)) }
        guard guess.count == numberCount, Set(guess).count == numberCount else {
            resultMessage = "❌ 유효한 숫자를 입력하세요"
            return
        }

        let (strike, ball, isWin) = aiLogic.checkGuess(guess)
        let formatted = "\(guess.map(String.init).joined()) : \(strike)S \(ball)B"
        userHistory.append(formatted)

        if isWin {
            resultMessage = "🎉 \(playerName)님 승리!"
            endGame(winner: playerName, didWin: true)
        } else {
            currentTurn = .ai
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.aiTurn()
            }
        }

        userGuessText = ""
    }

    // MARK: - AI 턴

    /// COM의 턴을 처리하는 함수
    private func aiTurn() {
        guard let userLogic = userLogic else { return }

        tryCount += 1

        // 하 난이도 COM 전환 조건 확인
        if difficulty == AIDifficulty.easy.rawValue && aiEasyPhase == .identifyingNumbers {
            if aiEasyNumberPool.count == numberCount {
                aiConfirmedNumbers.formUnion(aiEasyNumberPool)
                transitionToDeterminingPositions()
            }
        }

        guard let guess = selectGuess() else {
            resultMessage = "🤖 COM이 항복했습니다."
            endGame(winner: playerName, didWin: true)
            return
        }

        let (strike, ball, isWin) = userLogic.checkGuess(guess)
        aiGuessText = guess.map(String.init).joined()
        aiHistory.append("\(aiGuessText) : \(strike)S \(ball)B")

        if isWin {
            resultMessage = "🤖 COM 승리!"
            endGame(winner: "COM", didWin: false)
        } else {
            if difficulty == AIDifficulty.hard.rawValue {
                filterCandidates(basedOn: guess, strike: strike, ball: ball)
            } else {
                updateEasyAIData(guess: guess, strike: strike, ball: ball)
            }
            currentTurn = .user
        }
    }

    /// COM이 다음으로 제시할 숫자를 선택
    private func selectGuess() -> [Int]? {
        switch difficulty {
        case AIDifficulty.hard.rawValue:
            return aiCandidates.first
        case AIDifficulty.easy.rawValue:
            return generateEasyAIGuess()
        default:
            var guess: [Int]
            repeat {
                guess = Array((0...9).shuffled().prefix(numberCount))
            } while aiHistory.contains(where: { $0.hasPrefix(guess.map(String.init).joined()) })
            return guess
        }
    }

    /// 후보군 필터링 (상 난이도 전용)
    private func filterCandidates(basedOn guess: [Int], strike: Int, ball: Int) {
        aiCandidates.removeAll { candidate in
            let (s, b) = check(guess: guess, against: candidate)
            return s != strike || b != ball
        }
    }

    // MARK: - 하 난이도 COM 관련 함수

    private func generateEasyAIGuess() -> [Int]? {
        return aiEasyPhase == .identifyingNumbers ? generateIdentifyingNumbersGuess() : generateDeterminingPositionsGuess()
    }

    /// 하 난이도 - 숫자 식별 단계 추측 생성
    private func generateIdentifyingNumbersGuess() -> [Int]? {
        let available = aiEasyNumberPool.subtracting(aiEliminatedNumbers).sorted()
        guard available.count >= numberCount else { return nil }

        for _ in 0..<500 {
            let guess = Array(available.shuffled().prefix(numberCount))
            let formatted = guess.map(String.init).joined()
            if !aiHistory.contains(where: { $0.hasPrefix(formatted) }) {
                guess.forEach { aiGuessedNumbers.insert($0) }
                return guess
            }
        }
        return nil
    }

    /// 하 난이도 - 위치 확정 단계 추측 생성
    private func generateDeterminingPositionsGuess() -> [Int]? {
        aiCandidates.first
    }

    /// 하 난이도 - 예측 결과로 COM 상태 업데이트
    private func updateEasyAIData(guess: [Int], strike: Int, ball: Int) {
        if aiEasyPhase == .identifyingNumbers {
            if strike + ball == 0 {
                guess.forEach {
                    aiEliminatedNumbers.insert($0)
                    aiEasyNumberPool.remove($0)
                }
            } else if strike + ball == numberCount {
                guess.forEach { aiConfirmedNumbers.insert($0) }
                for i in 0...9 where !aiConfirmedNumbers.contains(i) {
                    aiEliminatedNumbers.insert(i)
                    aiEasyNumberPool.remove(i)
                }
                transitionToDeterminingPositions()
            }
        } else {
            filterCandidates(basedOn: guess, strike: strike, ball: ball)
        }
    }

    /// 숫자 식별 단계 → 위치 확정 단계 전환
    private func transitionToDeterminingPositions() {
        guard aiEasyPhase == .identifyingNumbers else { return }
        aiEasyPhase = .determiningPositions
        aiCandidates = generatePermutations(from: Array(aiConfirmedNumbers), count: numberCount)
        aiCandidates.removeAll { candidate in
            aiHistory.contains(where: { $0.hasPrefix(candidate.map(String.init).joined()) })
        }
    }

    // MARK: - 게임 종료 / 초기화

    /// 사용자가 포기했을 경우 처리
    func forfeit() {
        resultMessage = "🏳️ 사용자가 포기했습니다."
        endGame(winner: "COM", didWin: false)
    }

    override func endGame(winner: String, didWin: Bool) {
        self.winner = winner
        isGameOver = true
        calculateElapsedTime()
        super.saveResult(didWin: didWin)
    }

    /// 게임 재시작을 위한 상태 초기화
    func resetGame(numberCount: Int, settingsVM: SettingsViewModel) {
        // 상태 초기화
        userGuessText = ""
        aiGuessText = ""
        userHistory = []
        aiHistory = []
        currentTurn = .user
        isGameOver = false
        resultMessage = ""

        // 상위 클래스 초기화
        self.numberCount = numberCount
        self.playerName = settingsVM.playerName
        self.difficulty = settingsVM.aiDifficulty.rawValue
        self.tryCount = 0
        self.startTime = Date()
        self.endTime = nil
        self.winner = ""

        // AI 상태 초기화
        self.userLogic = nil
        self.aiEasyPhase = .identifyingNumbers
        self.aiEasyNumberPool = Set(0...9)
        self.aiGuessedNumbers = []
        self.aiEliminatedNumbers = []
        self.aiConfirmedNumbers = []

        // 상 난이도 후보 리스트 재설정
        if self.difficulty == AIDifficulty.hard.rawValue {
            self.aiCandidates = generatePermutations(from: Array(0...9), count: numberCount)
        }
    }

    // MARK: - 유틸리티

    /// 두 숫자 배열을 비교하여 스트라이크와 볼을 반환
    private func check(guess: [Int], against answer: [Int]) -> (strike: Int, ball: Int) {
        var strike = 0, ball = 0
        for (i, g) in guess.enumerated() {
            if g == answer[i] {
                strike += 1
            } else if answer.contains(g) {
                ball += 1
            }
        }
        return (strike, ball)
    }

    /// 가능한 숫자 조합을 생성 (중복 없는 순열)
    private func generatePermutations(from elements: [Int], count: Int) -> [[Int]] {
        guard count > 0 else { return [[]] }
        return elements.flatMap { element in
            let remaining = elements.filter { $0 != element }
            return generatePermutations(from: remaining, count: count - 1).map { [element] + $0 }
        }
    }
}
