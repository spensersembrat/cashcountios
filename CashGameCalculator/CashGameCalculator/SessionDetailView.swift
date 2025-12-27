//
//  SessionDetailView.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddPlayer = false
    @State private var showingSettlement = false
    @State private var playerToEdit: Player?
    
    var body: some View {
        List {
            // Summary Section
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Pot")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(session.totalPot)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Total Out")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(session.totalOut)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(session.isBalanced ? .primary : .red)
                            .monospacedDigit()
                    }
                }
                .listRowBackground(Color.clear)
                
                if !session.isBalanced && !session.players.isEmpty {
                    let diff = session.totalOut - session.totalPot
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(diff > 0 ? "Cash-outs exceed buy-ins by $\(diff)" : "Cash-outs are $\(-diff) short")
                            .font(.subheadline)
                    }
                    .listRowBackground(Color.yellow.opacity(0.15))
                }
            }
            
            // Players Section
            Section {
                ForEach(session.players) { player in
                    PlayerRowView(player: player)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            playerToEdit = player
                        }
                }
                .onDelete(perform: deletePlayers)
                
                Button {
                    showingAddPlayer = true
                } label: {
                    Label("Add Player", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Players")
            }
            
            // Settle Up Section
            if session.players.count >= 2 && session.isBalanced {
                Section {
                    Button {
                        showingSettlement = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Calculate Payouts", systemImage: "arrow.left.arrow.right")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.green.opacity(0.2))
                } footer: {
                    Text("Optimizes for the least number of transactions.")
                }
            }
        }
        .navigationTitle(session.name.isEmpty ? "Session" : session.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "person.badge.plus")
                    }
                    
                    if session.isSettled {
                        Button {
                            session.isSettled = false
                        } label: {
                            Label("Mark Unsettled", systemImage: "arrow.uturn.backward")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerView { name, totalIn in
                let player = Player(name: name, totalIn: totalIn)
                session.players.append(player)
            }
        }
        .sheet(item: $playerToEdit) { player in
            EditPlayerView(player: player)
        }
        .sheet(isPresented: $showingSettlement) {
            SettlementView(session: session)
        }
    }
    
    private func deletePlayers(at offsets: IndexSet) {
        for index in offsets {
            let player = session.players[index]
            session.players.remove(at: index)
            modelContext.delete(player)
        }
    }
}

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Text("In: $\(player.totalIn)")
                    Text("Out: $\(player.totalOut)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(player.net >= 0 ? "+$\(player.net)" : "-$\(-player.net)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(player.net >= 0 ? .green : .red)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var totalIn = ""
    
    let onSave: (String, Int) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First Name", text: $name)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0", text: $totalIn)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Buy-in Amount")
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let amount = Int(totalIn) ?? 0
                        onSave(name.trimmingCharacters(in: .whitespaces), amount)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct EditPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    
    @State private var name: String = ""
    @State private var totalIn: String = ""
    @State private var totalOut: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First Name", text: $name)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0", text: $totalIn)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Total In")
                } footer: {
                    Text("Total amount bought in for the session.")
                }
                
                Section {
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0", text: $totalOut)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Total Out")
                } footer: {
                    Text("Amount cashing out at end of session.")
                }
                
                // Net preview
                Section {
                    HStack {
                        Text("Net")
                        Spacer()
                        let inAmount = Int(totalIn) ?? 0
                        let outAmount = Int(totalOut) ?? 0
                        let net = outAmount - inAmount
                        Text(net >= 0 ? "+$\(net)" : "-$\(-net)")
                            .fontWeight(.semibold)
                            .foregroundColor(net >= 0 ? .green : .red)
                            .monospacedDigit()
                    }
                }
            }
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        player.name = name.trimmingCharacters(in: .whitespaces)
                        player.totalIn = Int(totalIn) ?? 0
                        player.totalOut = Int(totalOut) ?? 0
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                name = player.name
                totalIn = String(player.totalIn)
                totalOut = String(player.totalOut)
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    
    let session = Session(name: "Friday Night Poker")
    session.players = [
        Player(name: "John", totalIn: 200, totalOut: 350),
        Player(name: "Mike", totalIn: 600, totalOut: 450),
        Player(name: "Sarah", totalIn: 600, totalOut: 700),
        Player(name: "Tom", totalIn: 300, totalOut: 200)
    ]
    container.mainContext.insert(session)
    
    return NavigationStack {
        SessionDetailView(session: session)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

