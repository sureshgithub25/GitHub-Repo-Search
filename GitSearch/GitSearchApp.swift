//
//  GitSearchApp.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "darkModeEnabled")
    }
}

@main
struct GitSearchApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            UserSearchView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
