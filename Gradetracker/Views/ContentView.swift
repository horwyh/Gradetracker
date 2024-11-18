//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.userIsLoggedIn {
            DashboardView()
        } else {
            LoginView()
        }
    }
        
}

struct SearchBar: View {
    @Binding var searchQuery: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}
