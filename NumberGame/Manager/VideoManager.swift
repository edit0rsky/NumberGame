//
//  VideoManager.swift
//  NumberGame
//
//  Created by 정민규 on 6/15/25.
//

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let player: AVPlayer

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .onAppear {
                player.play()
                player.actionAtItemEnd = .none
            }
    }
}

