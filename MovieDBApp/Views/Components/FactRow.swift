//
//  FactRow.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import SwiftUI

struct FactRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
