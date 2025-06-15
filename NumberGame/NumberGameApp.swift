//
//  NumberGameApp.swift
//  NumberGame
//
//  Created by 정민규 on 5/1/25.
//

import SwiftUI

@main
struct NumberGameApp: App {
    @StateObject private var settingsVM = SettingsViewModel()
    @StateObject private var resultVM = ResultViewModel()

    var body: some Scene {
        WindowGroup {
            LoadingView()
                .environmentObject(settingsVM)
                .environmentObject(resultVM)
                .onAppear {
                        if settingsVM.isMusicOn {
                            AudioManager.shared.playBackgroundMusic()
                        }
                }
        }
    }
}
