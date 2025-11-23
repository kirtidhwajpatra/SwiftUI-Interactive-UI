//
//  Animation_01App.swift
//  Animation 01
//
//  Created by Uday on 23/11/25.
//

import SwiftUI

@main
struct Animation_01App: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
        }
    }
}
