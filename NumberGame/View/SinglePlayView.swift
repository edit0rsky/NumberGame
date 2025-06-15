//
//  SinglePlayView.swift
//  NumberGame
//
//  Created by 정민규 on 6/3/25.
//

import SwiftUI

struct SinglePlayView: View {
    @Binding var path: [HomeView.Page]
    @EnvironmentObject var singleVM: SinglePlayViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel

    @State private var hasAppeared = false
    @State private var guessText: String = ""
    @State private var showForfeitAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // 제목
            Text(singleVM.isGameOver ? "🎉 정답을 맞췄습니다!" : "🔢 숫자 야구 게임")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(singleVM.isGameOver ? .green : .primary)
                .padding(.top)

            // 입력 영역
            if !singleVM.isGameOver {
                VStack(spacing: 12) {
                    TextField("숫자 \(settingsVM.numberCount)개 입력 (예: 123)", text: $guessText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .onChange(of: guessText) { _, newValue in
                            guessText = String(newValue.prefix(settingsVM.numberCount).filter { $0.isNumber })
                        }

                    Button(action: submitGuess) {
                        Text("제출")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppColors.primaryBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }

            // 결과 영역
            VStack(spacing: 8) {
                Text(singleVM.resultMessage)
                    .font(.title3)
                    .foregroundColor(.orange)

                HStack(spacing: 24) {
                    Text("시도: \(singleVM.tryCount)회")
                    Text("시간: \(Int(singleVM.elapsedTime))초")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            // MARK: - 제출 기록 섹션
            VStack(alignment: .leading, spacing: 12) {
                Text("📋 제출 기록")
                    .font(.title3.bold())
                    .padding(.bottom, 4)

                Divider()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(singleVM.guessHistory.enumerated()), id: \.offset) { index, record in
                                HStack {
                                    Text("시도 \(index + 1):")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    Text(record)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .frame(height: 200)
                    .onChange(of: singleVM.guessHistory.count) {
                        withAnimation {
                            proxy.scrollTo(singleVM.guessHistory.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)


            // 게임 종료 시 버튼
            if singleVM.isGameOver {
                VStack(spacing: 16) {
                    Button("다시 시작") {
                        if settingsVM.isSoundOn {
                            AudioManager.shared.playEffectSound(named: "click")
                        }
                        restartGame()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Button("처음으로") {
                        if settingsVM.isSoundOn {
                            AudioManager.shared.playEffectSound(named: "click")
                        }
                        path.removeAll()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top)
            }

            Spacer()

            // 포기하기
            if !singleVM.isGameOver {
                Button("포기하기") {
                    if settingsVM.isSoundOn {
                        AudioManager.shared.playEffectSound(named: "click")
                    }
                    showForfeitAlert = true
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppColors.errorRed)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .padding(.top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !hasAppeared {
                restartGame()
                hasAppeared = true
            }
        }
        .alert("게임을 포기할 경우 패배로 기록됩니다.\n그래도 포기하시겠습니까?", isPresented: $showForfeitAlert) {
            Button("돌아가기", role: .cancel) {
                if settingsVM.isSoundOn {
                    AudioManager.shared.playEffectSound(named: "click")
                }
            }
            Button("포기하기", role: .destructive) {
                if settingsVM.isSoundOn {
                    AudioManager.shared.playEffectSound(named: "click")
                }
                singleVM.forfeitGame()
                path.removeAll()
            }
        }
    }

    private func submitGuess() {
        if settingsVM.isSoundOn {
            AudioManager.shared.playEffectSound(named: "click")
        }
        let guess = guessText.compactMap { Int(String($0)) }
        guard guess.count == settingsVM.numberCount,
              Set(guess).count == guess.count else {
            singleVM.resultMessage = "❌ 올바른 형식이 아닙니다."
            guessText = ""
            return
        }

        singleVM.submitGuess(guess)
        guessText = ""
    }

    private func restartGame() {
        singleVM.startNewGame()
        guessText = ""
    }
}

#Preview {
    SinglePlayView(path: .constant([]))
        .environmentObject(SinglePlayViewModel.previewMockSinglePlay()) // 수정된 이름 사용
        .environmentObject(SettingsViewModel.previewMockSettings())
        .environmentObject(ResultViewModel.previewMockResult()) // 수정된 이름 사용
}




