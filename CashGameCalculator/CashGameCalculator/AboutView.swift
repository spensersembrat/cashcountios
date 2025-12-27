//
//  AboutView.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Image("SplashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        Text("SettleUpCash")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Cash Game Settlement")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // What is this app?
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What is SettleUpCash?", systemImage: "questionmark.circle")
                            .font(.headline)
                        
                        Text("SettleUpCash helps you settle up after a poker cash game. Enter each player's buy-in and cash-out amounts, and the app calculates the optimal way to transfer money between players.")
                            .foregroundStyle(.secondary)
                    }
                    
                    // Cash Games Only
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Cash Games Only", systemImage: "dollarsign.circle")
                            .font(.headline)
                        
                        Text("This app is designed specifically for cash games where players can buy in and cash out at any time. It is not intended for tournaments, which have fixed buy-ins and prize pool structures.")
                            .foregroundStyle(.secondary)
                    }
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How It Works", systemImage: "gearshape")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(number: 1, text: "Create a new session for your game night")
                            BulletPoint(number: 2, text: "Add each player with their buy-in amount")
                            BulletPoint(number: 3, text: "At the end, enter each player's cash-out amount")
                            BulletPoint(number: 4, text: "Tap \"Calculate Payouts\" to see who owes whom")
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Smart Settlement
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Smart Settlement", systemImage: "arrow.left.arrow.right")
                            .font(.headline)
                        
                        Text("The app optimizes payments to minimize the number of transactions. Instead of everyone paying everyone, it finds the most efficient way to settle all debts.")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BulletPoint: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .fontWeight(.semibold)
                .frame(width: 20, alignment: .leading)
            Text(text)
        }
    }
}

#Preview {
    AboutView()
        .preferredColorScheme(.dark)
}

