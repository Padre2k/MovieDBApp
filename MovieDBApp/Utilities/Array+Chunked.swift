//
//  Array Extension.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        var chunks: [[Element]] = []
        var idx = 0
        while idx < count {
            let end = Swift.min(idx + size, count)
            chunks.append(Array(self[idx..<end]))
            idx = end
        }
        return chunks
    }
}
