//
//  ResultView.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var resultVM: ResultViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if resultVM.results.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("저장된 게임 기록이 없습니다.")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                    Spacer()
                } else {
                    ForEach(resultVM.results.reversed(), id: \.id) { result in
                        ResultCard(result: result)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("게임 기록")
        .onAppear {
            resultVM.loadResults()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct ResultCard: View {
    let result: GameResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(result.playerName)
                    .font(.headline)
                Spacer()
                Text(result.didWin ? "승리" : "패배")
                    .foregroundColor(result.didWin ? .green : .red)
                    .bold()
            }

            HStack(spacing: 16) {
                Label("\(result.tryCount)회", systemImage: "repeat")
                Label("\(Int(result.elapsedTime))초", systemImage: "timer")
                Label(result.difficulty, systemImage: "chart.bar")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Text("📅 \(formattedDate(result.date))")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

