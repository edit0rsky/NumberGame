//
//  PreviewModel.swift
//  NumberGame
//
//  Created by 정민규 on 6/5/25.
//

#if DEBUG
import Foundation

// MARK: - SinglePlayViewModel Preview
/// 싱글 플레이 뷰 모델의 미리보기용 인스턴스를 생성합니다.
/// SwiftUI 프리뷰에서 사용자가 게임을 시작한 것처럼 보이게 설정할 수 있습니다.
extension SinglePlayViewModel {
    static func previewMockSinglePlay() -> SinglePlayViewModel {
        let vm = SinglePlayViewModel(
            numberCount: 3,                // 정답 숫자 개수: 3자리
            playerName: "미리보기",         // 프리뷰용 사용자 이름
            difficulty: "싱글플레이"         // 난이도 표시용 텍스트 (싱글 전용)
        )
        vm.startNewGame() // 새 게임 시작 (랜덤 정답 생성됨)
        // vm.submitGuess([1, 2, 3]) // 테스트용 입력 (프리뷰에서 자동 실행 원할 경우만 사용)
        return vm
    }
}

// MARK: - MultiPlayViewModel Preview
/// 멀티 플레이 (AI 대전) 뷰 모델의 프리뷰 인스턴스를 생성합니다.
/// 실제 사용자의 정답을 "123"으로 설정하여 AI 예측 흐름 테스트 가능.
extension MultiPlayViewModel {
    static func previewMockMultiPlay(using settingsVM: SettingsViewModel) -> MultiPlayViewModel {
        let vm = MultiPlayViewModel(
            numberCount: settingsVM.numberCount, // 설정된 자리 수 사용
            settingsVM: settingsVM              // 프리뷰용 설정 뷰모델 주입
        )
        vm.setUserAnswer(from: "123")           // 사용자가 입력한 정답을 고정 (AI는 이걸 맞춰야 함)
        return vm
    }
}

// MARK: - SettingsViewModel Preview
/// 전체 프리뷰에서 공통으로 사용할 수 있는 SettingsViewModel 생성
/// 사운드, 음악, 난이도, 사용자명 등의 기본 값 설정 포함
extension SettingsViewModel {
    static func previewMockSettings() -> SettingsViewModel {
        let vm = SettingsViewModel()
        vm.playerName = "미리보기"        // 기본 이름
        vm.numberCount = 3              // 숫자 3개 맞추기
        vm.aiDifficulty = .hard         // '상' 난이도 설정 (프리뷰용)
        vm.isSoundOn = true             // 효과음 켜짐
        vm.isMusicOn = true             // 배경음악 켜짐
        return vm
    }
}

// MARK: - ResultViewModel Preview
/// 결과 화면 프리뷰용 데이터 모델을 구성
/// 실제 게임 결과처럼 보이도록 2개의 샘플 게임 결과 삽입
extension ResultViewModel {
    static func previewMockResult() -> ResultViewModel {
        let vm = ResultViewModel()
        vm.results = [
            GameResult(
                playerName: "미리보기",      // 사용자 이름
                didWin: true,              // 승리 여부
                tryCount: 5,               // 시도 횟수
                elapsedTime: 27.5,         // 소요 시간 (초)
                difficulty: "싱글플레이",    // 난이도 정보
                date: Date()               // 현재 시간 기준
            ),
            GameResult(
                playerName: "미리보기",
                didWin: false,
                tryCount: 8,
                elapsedTime: 40,
                difficulty: AIDifficulty.easy.rawValue, // '하' 난이도 (열거형에서 문자열 반환)
                date: Date().addingTimeInterval(-3600)  // 1시간 전 게임 기록
            )
        ]
        return vm
    }
}
#endif
