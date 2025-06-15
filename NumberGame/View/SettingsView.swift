//
//  SettingsView.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var showResetAlert = false // 게임 초기화 Alert 표시 여부

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 사용자 이름
                SettingsCard(title: "사용자 이름") {
                    TextField("이름을 입력하세요", text: $settingsVM.playerName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                // 숫자 개수
                SettingsCard(title: "숫자 개수") {
                    Picker("", selection: Binding(
                        get: { settingsVM.numberCount },
                        set: { newValue in
                            playClick()
                            settingsVM.numberCount = newValue
                        }
                    )) {
                        Text("3개").tag(3)
                        Text("4개").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                // AI 난이도
                SettingsCard(title: "COM 난이도") {
                    Picker("", selection: Binding(
                        get: { settingsVM.aiDifficulty },
                        set: { newValue in
                            playClick()
                            settingsVM.aiDifficulty = newValue
                        }
                    )) {
                        ForEach(AIDifficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                // 사운드 설정
                SettingsCard(title: "사운드 설정") {
                    Toggle("효과음", isOn: Binding(
                        get: { settingsVM.isSoundOn },
                        set: { newValue in
                            playClick()
                            settingsVM.isSoundOn = newValue
                        }
                    ))
                    .padding(.horizontal)

                    Toggle("배경음악", isOn: Binding(
                        get: { settingsVM.isMusicOn },
                        set: { newValue in
                            playClick()
                            settingsVM.isMusicOn = newValue
                        }
                    ))
                    .padding(.horizontal)
                }

                // 설정 초기화 버튼
                Button(action: {
                    playClick()
                    settingsVM.resetSettings()
                }) {
                    Text("설정 초기화")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.errorRed)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // 게임 초기화 버튼
                Button(action: {
                    playClick()
                    showResetAlert = true // Alert 표시
                }) {
                    Text("게임 초기화")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("환경설정")
        .background(AppColors.background.ignoresSafeArea())
        .alert("⚠️ 모든 설정과 게임 기록이 초기화됩니다", isPresented: $showResetAlert) {
            Button("취소", role: .cancel) {
                playClick()
            }
            Button("초기화", role: .destructive) {
                playClick()
                settingsVM.resetSettings()
                RecordManager.shared.clearAll()
            }
        } message: {
            Text("되돌릴 수 없습니다. 계속하시겠습니까?")
        }
    }

    private func playClick() {
        if settingsVM.isSoundOn {
            AudioManager.shared.playEffectSound(named: "click")
        }
    }
}

// 카드형 설정 UI 재사용 뷰
struct SettingsCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.deepNavy)
                .padding(.horizontal)

            content
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
