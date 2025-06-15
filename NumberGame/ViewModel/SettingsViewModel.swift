//
//  SettingsViewModel.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import Foundation

// MARK: - AI 난이도 열거형
/// 게임 내 AI 난이도를 나타내는 열거형입니다.
/// '하'(easy), '상'(hard) 두 가지 난이도로 구성됩니다.
enum AIDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "하"   // 쉬운 난이도
    case hard = "상"   // 어려운 난이도

    /// SwiftUI Picker에서 식별자로 사용하기 위한 id
    var id: String { rawValue }
}

// MARK: - 설정 뷰 모델
/// 사용자의 게임 설정 정보를 저장하고 관리하는 ObservableObject 클래스입니다.
/// SwiftUI에서 @EnvironmentObject로 주입되어 전체 화면에서 공유됩니다.
class SettingsViewModel: ObservableObject {
    // MARK: - 게임 설정 값

    /// 사용자가 선택한 숫자 개수 (예: 3자리 숫자 맞추기)
    @Published var numberCount: Int = 3

    /// 선택된 AI 난이도 (기본값은 '상')
    @Published var aiDifficulty: AIDifficulty = .hard

    /// 효과음 설정 여부
    @Published var isSoundOn: Bool = false

    /// 배경음악 설정 여부 (on/off 시 음악 컨트롤)
    @Published var isMusicOn: Bool = false {
        didSet {
            if isMusicOn {
                // 음악 켜짐 → 배경 음악 재생
                AudioManager.shared.playBackgroundMusic()
            } else {
                // 음악 꺼짐 → 배경 음악 정지
                AudioManager.shared.stopBackgroundMusic()
            }
        }
    }

    /// 사용자 닉네임 (기본값: "Player")
    @Published var playerName: String = "Player"

    // MARK: - 설정 초기화 메서드
    /// 설정값을 기본값으로 되돌립니다.
    func resetSettings() {
        numberCount = 3
        aiDifficulty = .hard
        isSoundOn = false
        isMusicOn = false
        playerName = "Player"
    }
}
