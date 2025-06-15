//
//  RecordManager.swift
//  NumberGame
//
//  Created by 정민규 on 5/3/25.
//

import Foundation

/// 게임 결과 저장 및 불러오기 기능을 담당하는 싱글톤 매니저
class RecordManager {
    
    /// 전역에서 하나의 인스턴스로 접근 가능한 공유 객체
    static let shared = RecordManager()

    /// 외부에서 인스턴스를 생성하지 못하도록 private 생성자 선언
    private init() {}

    /// 저장할 JSON 파일 이름
    private let fileName = "results.json"

    /// 도큐먼트 디렉토리 경로 + 파일명 → 결과 파일의 전체 경로 URL
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // MARK: - Save

    /// 게임 결과를 JSON 파일에 저장합니다.
    /// 기존 데이터에 새 결과를 추가한 후 덮어씌웁니다.
    /// - Parameter result: 저장할 GameResult 객체
    func save(_ result: GameResult) {
        var records = load() // 기존 기록 불러오기
        records.append(result) // 새 결과 추가
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: fileURL) // JSON 파일로 저장
        }
    }

    // MARK: - Load

    /// 저장된 모든 게임 결과를 불러옵니다.
    /// - Returns: GameResult 배열 (파일이 없거나 파싱 실패 시 빈 배열 반환)
    func load() -> [GameResult] {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let records = try? JSONDecoder().decode([GameResult].self, from: data)
        else {
            return []
        }
        return records
    }

    // MARK: - Clear All

    /// 저장된 모든 게임 결과를 삭제합니다.
    /// 파일 자체를 제거하여 초기화합니다.
    func clearAll() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Update

    /// 기존 결과 중 동일한 ID를 가진 항목을 찾아 수정합니다.
    /// - Parameter result: 수정할 GameResult 객체
    func update(result: GameResult) {
        var records = load()
        if let index = records.firstIndex(where: { $0.id == result.id }) {
            records[index] = result // 해당 항목 수정
            if let data = try? JSONEncoder().encode(records) {
                try? data.write(to: fileURL)
            }
        }
    }

    // MARK: - Delete (by ID)

    /// 특정 ID(UUID)를 가진 결과 항목을 삭제합니다.
    /// - Parameter resultID: 삭제할 GameResult의 고유 식별자
    func delete(resultID: UUID) {
        var records = load()
        records.removeAll { $0.id == resultID } // 해당 ID 삭제
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: fileURL)
        }
    }
}
