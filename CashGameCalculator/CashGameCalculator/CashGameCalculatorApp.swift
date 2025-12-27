//
//  CashGameCalculatorApp.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI
import SwiftData

@main
struct CashGameCalculatorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Session.self,
            Player.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .onAppear {
                    seedExampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func seedExampleDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        
        // Check if any sessions exist
        let descriptor = FetchDescriptor<Session>()
        let existingSessions = (try? context.fetch(descriptor)) ?? []
        
        // Only seed if no sessions exist
        guard existingSessions.isEmpty else { return }
        
        // Create example session
        let exampleSession = Session(name: "Example Game")
        
        // 8 players, pot = $2000, balanced cash-outs
        let players = [
            Player(name: "Alex", totalIn: 200, totalOut: 350),      // +150
            Player(name: "Jordan", totalIn: 300, totalOut: 200),    // -100
            Player(name: "Casey", totalIn: 250, totalOut: 400),     // +150
            Player(name: "Morgan", totalIn: 400, totalOut: 250),    // -150
            Player(name: "Riley", totalIn: 150, totalOut: 300),     // +150
            Player(name: "Taylor", totalIn: 350, totalOut: 150),    // -200
            Player(name: "Drew", totalIn: 200, totalOut: 100),      // -100
            Player(name: "Sam", totalIn: 150, totalOut: 250),       // +100
        ]
        // Total In: $2000, Total Out: $2000 ✓
        
        exampleSession.players = players
        context.insert(exampleSession)
        
        try? context.save()
    }
}
