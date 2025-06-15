//
//  GameResult.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import Foundation

struct GameResult: Codable, Identifiable {
    var id = UUID()
    let playerName: String        // 이름
    let didWin: Bool              // 우승 여부
    let tryCount: Int             // 시도 횟수
    let elapsedTime: TimeInterval // 걸린 시간
    let difficulty: String        // 난이도
    let date: Date                // 날짜
}

