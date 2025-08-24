//
//  APIKeySheet.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import SwiftUI

struct APIKeySheet: View {
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("Your key is stored locally with AppStorage (UserDefaults).")) {
                    TextField("OMDb API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.body, design: .monospaced))
                }
                Section {
                    Link("Get an API key", destination: URL(string: "https://www.omdbapi.com/apikey.aspx")!)
                }
            }
            .navigationTitle("OMDb API Key")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
