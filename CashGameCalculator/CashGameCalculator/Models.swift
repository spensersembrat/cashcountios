//
//  Models.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var date: Date
    var name: String
    @Relationship(deleteRule: .cascade) var players: [Player]
    var isSettled: Bool
    
    init(name: String = "", date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.name = name
        self.players = []
        self.isSettled = false
    }
    
    var totalPot: Int {
        players.reduce(0) { $0 + $1.totalIn }
    }
    
    var totalOut: Int {
        players.reduce(0) { $0 + $1.totalOut }
    }
    
    var isBalanced: Bool {
        totalPot == totalOut
    }
}

@Model
final class Player {
    var id: UUID
    var name: String
    var totalIn: Int
    var totalOut: Int
    
    init(name: String, totalIn: Int = 0, totalOut: Int = 0) {
        self.id = UUID()
        self.name = name
        self.totalIn = totalIn
        self.totalOut = totalOut
    }
    
    var net: Int {
        totalOut - totalIn
    }
}

struct Transaction: Identifiable, Equatable {
    let id = UUID()
    let from: String
    let to: String
    let amount: Int
}

// Settlement Calculator - Optimizes for minimum transactions
struct SettlementCalculator {
    
    static func calculate(players: [Player]) -> [Transaction] {
        // Calculate net for each player
        var balances: [(name: String, net: Int)] = players.map { ($0.name, $0.net) }
        
        // Separate into debtors (negative net) and creditors (positive net)
        var debtors = balances.filter { $0.net < 0 }.map { ($0.name, -$0.net) } // Convert to positive amounts owed
        var creditors = balances.filter { $0.net > 0 }
        
        // Sort by amount (largest first) for greedy optimization
        debtors.sort { $0.1 > $1.1 }
        creditors.sort { $0.1 > $1.1 }
        
        var transactions: [Transaction] = []
        
        // Greedy matching: pair largest debtor with largest creditor
        while !debtors.isEmpty && !creditors.isEmpty {
            let debtor = debtors[0]
            let creditor = creditors[0]
            
            let amount = min(debtor.1, creditor.1)
            
            if amount > 0 {
                transactions.append(Transaction(from: debtor.0, to: creditor.0, amount: amount))
            }
            
            // Update remaining balances
            let newDebtorAmount = debtor.1 - amount
            let newCreditorAmount = creditor.1 - amount
            
            debtors.removeFirst()
            creditors.removeFirst()
            
            if newDebtorAmount > 0 {
                // Insert back in sorted position
                let insertIndex = debtors.firstIndex { $0.1 < newDebtorAmount } ?? debtors.endIndex
                debtors.insert((debtor.0, newDebtorAmount), at: insertIndex)
            }
            
            if newCreditorAmount > 0 {
                let insertIndex = creditors.firstIndex { $0.1 < newCreditorAmount } ?? creditors.endIndex
                creditors.insert((creditor.0, newCreditorAmount), at: insertIndex)
            }
        }
        
        return transactions
    }
}

