//
//  MultiPlayView.swift
//  NumberGame
//
//  Created by 정민규 on 6/3/25.
//

import SwiftUI

struct MultiPlayView: View {
    @Binding var path: [HomeView.Page]
    let settingsVM: SettingsViewModel

    @EnvironmentObject var multiVM: MultiPlayViewModel
    @EnvironmentObject var resultVM: ResultViewModel

    @State private var showForfeitAlert = false
    @State private var showAnswerInputSheet = true
    @State private var userAnswerText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // 제목
            Text(multiVM.isGameOver ? multiVM.resultMessage : "멀티 플레이 (COM)")
                .font(.largeTitle.bold())
                .padding(.top, 20)

            // AI
            Group {
                Text("COM")
                    .font(.title2.bold())
                Text(multiVM.aiGuessText.isEmpty ? "COM의 예측" : multiVM.aiGuessText)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)

                historySection(title: "COM 기록", history: multiVM.aiHistory, fixedHeight: true)
            }

            // 나
            Group {
                Text(multiVM.playerName)
                    .font(.title2.bold())

                historySection(title: "나의 기록", history: multiVM.userHistory, fixedHeight: true)

                if !multiVM.isGameOver {
                    TextField("숫자 \(multiVM.numberCount)개 입력", text: $multiVM.userGuessText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }

            // 제출 버튼
            if !multiVM.isGameOver {
                Button {
                    playClick()
                    multiVM.submitUserGuess()
                } label: {
                    Text("제출하기")
                }
                .primaryButtonStyle(
                    disabled:
                        multiVM.currentTurn != .user ||
                        multiVM.userGuessText.count != multiVM.numberCount ||
                        Set(multiVM.userGuessText).count != multiVM.numberCount
                )
            }

            // 포기 버튼
            if !multiVM.isGameOver {
                Button {
                    playClick()
                    showForfeitAlert = true
                } label: {
                    Text("포기하기")
                }
                .primaryButtonStyle(color: .red)
            }

            // 게임 종료 시 버튼
            if multiVM.isGameOver {
                Button("🔄 다시하기") {
                    playClick()
                    multiVM.resetGame(numberCount: settingsVM.numberCount, settingsVM: settingsVM)
                    showAnswerInputSheet = true
                    userAnswerText = ""
                }
                .primaryButtonStyle()

                Button("🏠 처음으로") {
                    playClick()
                    path.removeAll()
                }
                .primaryButtonStyle(color: .orange)
            }
        }
        .padding()
        .alert("게임을 포기하시겠습니까?", isPresented: $showForfeitAlert) {
            Button("취소", role: .cancel) { playClick() }
            Button("포기", role: .destructive) {
                playClick()
                multiVM.forfeit()
            }
        }
        .blur(radius: showAnswerInputSheet ? 5 : 0)

        // 정답 입력 팝업
        .overlay {
            if showAnswerInputSheet {
                answerInputPopup
            }
        }
    }

    func historySection(title: String, history: [String], fixedHeight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("📜 \(title)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(history.reversed(), id: \.self) { record in
                        Text(record)
                            .font(.body)
                            .foregroundColor(record.contains("0S 0B") ? .red : .primary)
                    }
                }
                .padding(8)
            }
            .frame(height: fixedHeight ? 100 : nil)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.85))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        }
    }

    var answerInputPopup: some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 25) {
                    Text("COM이 맞출 **정답 번호**를 입력하세요")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)

                    TextField("예: \(Array(repeating: "X", count: multiVM.numberCount).joined())", text: $userAnswerText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding()
                        .font(.title)
                        .background(Color.white.opacity(0.98))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2))
                        .frame(width: 220)

                    HStack(spacing: 20) {
                        Button {
                            playClick()
                            showAnswerInputSheet = false
                            multiVM.setUserAnswer(from: userAnswerText)
                        } label: {
                            Text("시작하기")
                        }
                        .primaryButtonStyle(
                            color: .green,
                            disabled:
                                userAnswerText.count != multiVM.numberCount ||
                                Set(userAnswerText).count != userAnswerText.count
                        )

                        Button {
                            playClick()
                            showAnswerInputSheet = false
                            userAnswerText = ""
                            path.removeAll()
                        } label: {
                            Text("돌아가기")
                        }
                        .primaryButtonStyle(color: .red)
                    }
                }
                .padding(35)
                .background(.ultraThinMaterial)
                .cornerRadius(30)
                .frame(maxWidth: 380)
                .shadow(radius: 25)
                .transition(.scale)
            }
    }

    func playClick() {
        if settingsVM.isSoundOn {
            AudioManager.shared.playEffectSound(named: "click")
        }
    }
}

// 버튼 스타일 확장
extension View {
    func primaryButtonStyle(color: Color = .accentColor, disabled: Bool = false) -> some View {
        self
            .font(.title2.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(disabled ? Color.gray.opacity(0.5) : color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 3)
            .disabled(disabled)
    }
}



// MARK: - Preview Mock
extension SettingsViewModel {
    static func previewMock() -> SettingsViewModel {
        let vm = SettingsViewModel()
        vm.numberCount = 3
        vm.aiDifficulty = .hard
        vm.playerName = "테스트플레이어"
        return vm
    }
}

extension ResultViewModel {
    static func previewMock() -> ResultViewModel {
        return ResultViewModel()
    }
}

#Preview {
    let settingsVM = SettingsViewModel.previewMock()
    return MultiPlayView(path: .constant([]), settingsVM: settingsVM)
        .environmentObject(
            MultiPlayViewModel(
                numberCount: settingsVM.numberCount,
                settingsVM: settingsVM
            )
        )
        .environmentObject(ResultViewModel.previewMock())
}
