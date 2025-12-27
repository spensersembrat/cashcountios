//
//  SettlementView.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI

struct SettlementView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var session: Session
    
    private var transactions: [Transaction] {
        SettlementCalculator.calculate(players: session.players)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Summary
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            VStack {
                                Text("\(session.players.count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("Players")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack {
                                Text("$\(session.totalPot)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Text("Total Pot")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack {
                                Text("\(transactions.count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("Payments")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // Player Results
                Section {
                    ForEach(session.players.sorted { $0.net > $1.net }) { player in
                        HStack {
                            Text(player.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            if player.net > 0 {
                                Text("+$\(player.net)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                                    .monospacedDigit()
                            } else if player.net < 0 {
                                Text("-$\(-player.net)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.red)
                                    .monospacedDigit()
                            } else {
                                Text("Even")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Results")
                }
                
                // Transactions
                Section {
                    if transactions.isEmpty {
                        Text("No payments needed")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(transactions) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                } header: {
                    Text("Payments")
                } footer: {
                    if !transactions.isEmpty {
                        Text("Optimized for minimum number of transactions.")
                    }
                }
            }
            .navigationTitle("Settlement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        session.isSettled = true
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // From player
            VStack {
                Text(transaction.from)
                    .font(.headline)
                Text("pays")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            // Arrow with amount
            VStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                Text("$\(transaction.amount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            
            // To player
            VStack {
                Text(transaction.to)
                    .font(.headline)
                Text("receives")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let session = Session(name: "Friday Night Poker")
    session.players = [
        Player(name: "John", totalIn: 200, totalOut: 350),
        Player(name: "Mike", totalIn: 600, totalOut: 450),
        Player(name: "Sarah", totalIn: 600, totalOut: 700),
        Player(name: "Tom", totalIn: 300, totalOut: 200)
    ]
    
    return SettlementView(session: session)
        .preferredColorScheme(.dark)
}

