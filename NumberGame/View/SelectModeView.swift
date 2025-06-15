//
//  SelectModeView.swift
//  NumberGame
//
//  Created by 정민규 on 6/2/25.
//

import SwiftUI

struct SelectModeView: View {
    @Binding var path: [HomeView.Page]
    @EnvironmentObject var settingsVM: SettingsViewModel

    var onSelectMode: ((HomeView.Page) -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("🎮 게임 모드 선택")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.deepNavy)
                .padding(.bottom, 10)

            VStack(spacing: 20) {
                ModeButton(title: "싱글 플레이") {
                    onSelectMode?(.singlePlay)
                }

                ModeButton(title: "멀티 플레이") {
                    onSelectMode?(.multiPlay)
                }

                ModeButton(title: "뒤로 가기") {
                    if !path.isEmpty {
                        path.removeLast()
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    func ModeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            if settingsVM.isSoundOn {
                AudioManager.shared.playEffectSound(named: "click")
            }
            action()
        }) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppColors.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 32)
    }
}


