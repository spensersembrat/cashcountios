//
//  MainTabView.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SessionsListView()
                .tabItem {
                    Label("Calculator", systemImage: "dollarsign.circle")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}

