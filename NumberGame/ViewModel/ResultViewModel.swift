//
//  ResultViewModel.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import Foundation

class ResultViewModel: ObservableObject {
    @Published var results: [GameResult] = []

    init() {
        loadResults()
    }

    // MARK: - 저장
    func saveResult(_ result: GameResult) {
        RecordManager.shared.save(result)
        results = RecordManager.shared.load()
    }

    // MARK: - 불러오기
    func loadResults() {
        results = RecordManager.shared.load()
    }

    // MARK: - 삭제
    func deleteResult(id: UUID) {
        RecordManager.shared.delete(resultID: id)
        results = RecordManager.shared.load()
    }

    // MARK: - 전체 삭제
    func clearAll() {
        RecordManager.shared.clearAll()
        results = []
    }

    // MARK: - 수정
    func updateResult(_ result: GameResult) {
        RecordManager.shared.update(result: result)
        results = RecordManager.shared.load()
    }
}

