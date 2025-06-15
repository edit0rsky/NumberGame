//
//  HowToPlayView.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import SwiftUI

struct HowToPlayView: View {
    enum Tab {
        case howToPlay, menu, tip
    }

    @State private var selectedTab: Tab = .howToPlay

    var body: some View {
        VStack(spacing: 0) {
            // 탭 버튼 영역
            HStack(spacing: 0) {
                TabButton(title: "게임 방법", isSelected: selectedTab == .howToPlay) {
                    selectedTab = .howToPlay
                }
                TabButton(title: "메뉴 설명", isSelected: selectedTab == .menu) {
                    selectedTab = .menu
                }
                TabButton(title: "꿀팁", isSelected: selectedTab == .tip) {
                    selectedTab = .tip
                }
            }
            .frame(height: 50)
            .background(AppColors.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 0))

            // 콘텐츠 영역
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch selectedTab {
                    case .howToPlay:
                        SectionView(title: "게임 방법", items: [
                            "0~9까지 서로 다른 숫자 3개 또는 4개를 선택합니다.",
                            "숫자와 자리가 맞으면 Strike, 숫자만 맞으면 Ball입니다.",
                            "모두 틀리면 Out입니다.",
                            "정답을 맞출 때까지 반복하며 기록됩니다."
                        ])
                        SectionView(title: "예시", items: [
                            "정답: 1234",
                            "입력: 1283 → 2 Strike 1 Ball",
                            "입력: 5678 → Out",
                            "입력: 1234 → You Win"
                        ])

                    case .menu:
                        SectionView(title: "주요 메뉴 기능", items: [
                            "싱글 플레이: 내가 정한 숫자를 AI가 추측",
                            "멀티 플레이: AI가 출제한 문제를 내가 푸는 모드",
                            "AI 난이도: 하 / 상 설정 가능",
                            "게임 기록: 과거 플레이 결과 확인",
                            "환경 설정: 효과음, 배경음악, 이름 변경 가능"
                        ])

                    case .tip:
                        SectionView(title: "게임 꿀팁", items: [
                            "숫자는 중복되지 않으니 겹치지 않게 입력하세요!",
                            "Strike가 많을수록 자리까지 맞춘 것입니다.",
                            "빠르게 맞추면 기록이 좋아져요!",
                            "AI는 난이도에 따라 전략이 달라요."
                        ])
                    }
                }
                .padding(20)
            }
            .background(Color.white)
        }
        .navigationTitle("게임 가이드")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct TabButton: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            if settingsVM.isSoundOn {
                AudioManager.shared.playEffectSound(named: "click")
            }
            action()
        }) {
            VStack(spacing: 4) {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Rectangle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(2)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

struct SectionView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)

            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.body)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}



#Preview {
    HowToPlayView()
}

