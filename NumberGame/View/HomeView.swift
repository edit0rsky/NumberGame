//
//  HomeView.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var resultVM: ResultViewModel

    @State private var path: [Page] = []
    @State private var singleVM: SinglePlayViewModel? = nil
    @State private var multiVM: MultiPlayViewModel? = nil
    @State private var shouldNavigateToSinglePlay = false
    @State private var shouldNavigateToMultiPlay = false

    enum Page: Hashable {
        case settings, howToPlay, history, selectMode, singlePlay, multiPlay
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 40) {
                Spacer()

                Text("⚾️ 숫자 야구")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppColors.deepNavy)

                VStack(spacing: 20) {
                    HomeButton(title: "게임 시작") {
                        playClickSound()
                        path.append(.selectMode)
                    }

                    HomeButton(title: "게임 기록") {
                        playClickSound()
                        path.append(.history)
                    }

                    HomeButton(title: "게임 가이드") {
                        playClickSound()
                        path.append(.howToPlay)
                    }

                    HomeButton(title: "환경 설정") {
                        playClickSound()
                        path.append(.settings)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 30)
            .background(Color.white)
            .onChange(of: shouldNavigateToSinglePlay) {
                if shouldNavigateToSinglePlay {
                    path.append(.singlePlay)
                    shouldNavigateToSinglePlay = false
                }
            }
            .onChange(of: shouldNavigateToMultiPlay) {
                if shouldNavigateToMultiPlay {
                    path.append(.multiPlay)
                    shouldNavigateToMultiPlay = false
                }
            }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .selectMode:
                    SelectModeView(path: $path, onSelectMode: { selected in
                        let count = settingsVM.numberCount
                        let playerName = settingsVM.playerName
                        let difficulty = settingsVM.aiDifficulty.rawValue

                        switch selected {
                        case .singlePlay:
                            singleVM = SinglePlayViewModel(
                                numberCount: count,
                                playerName: playerName,
                                difficulty: "싱글플레이"
                            )
                            shouldNavigateToSinglePlay = true
                        case .multiPlay:
                            multiVM = MultiPlayViewModel(
                                numberCount: count,
                                settingsVM: settingsVM
                            )
                            shouldNavigateToMultiPlay = true
                        default:
                            break
                        }
                    })

                case .singlePlay:
                    if let singleVM {
                        SinglePlayView(path: $path)
                            .environmentObject(singleVM)
                            .environmentObject(settingsVM)
                            .environmentObject(resultVM)
                    }

                case .multiPlay:
                    if let multiVM {
                        MultiPlayView(path: $path, settingsVM: settingsVM)
                            .environmentObject(multiVM)
                            .environmentObject(resultVM)
                    }

                case .settings:
                    SettingsView()

                case .howToPlay:
                    HowToPlayView()

                case .history:
                    ResultView()
                }
            }
        }
    }

    private func playClickSound() {
        if settingsVM.isSoundOn {
            AudioManager.shared.playEffectSound(named: "click")
        }
    }
}

struct HomeButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.primaryBlue)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
        }
    }
}

#Preview {
    // SettingsViewModel과 ResultViewModel을 미리 생성하여 EnvironmentObject로 주입
    let settingsViewModel = SettingsViewModel.previewMock()
    let resultViewModel = ResultViewModel.previewMock()
    
    HomeView()
        .environmentObject(settingsViewModel)
        .environmentObject(resultViewModel)
        // MultiPlayViewModel의 미리보기를 위한 초기화는 HomeView 내부의 로직에서 처리되므로,
        // 여기서는 MultiPlayViewModel을 직접 주입할 필요가 없습니다.
        // 다만, 특정 뷰로 바로 이동하는 프리뷰를 만들고 싶다면, 해당 뷰의 프리뷰를 직접 생성하는 것이 더 좋습니다.
}

