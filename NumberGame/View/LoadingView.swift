//
//  LoadingView.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import SwiftUI
import AVKit

struct LoadingView: View {
    @State private var isLoaded = false
    private let player = AVPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)

    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var resultVM: ResultViewModel

    var body: some View {
        Group {
            if isLoaded {
                HomeView()
                    .environmentObject(settingsVM)
                    .environmentObject(resultVM)
            } else {
                ZStack {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .onAppear {
                            player.play()
                            player.actionAtItemEnd = .none
                            simulateLoading()
                        }

                    Text("숫자 야구 게임")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                }
            }
        }
    }

    private func simulateLoading() {
        // 실제 로딩이 끝나면 이 값을 true로 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isLoaded = true
        }
    }
}

#Preview {
    LoadingView()
}
