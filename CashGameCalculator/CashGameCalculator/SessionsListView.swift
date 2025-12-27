//
//  SessionsListView.swift
//  CashGameCalculator
//
//  Created by Spenser Sembrat on 12/26/25.
//

import SwiftUI
import SwiftData

struct SessionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    @State private var showingNewSession = false
    
    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationTitle("Cash Games")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewSession()
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Sessions", systemImage: "suit.spade.fill")
        } description: {
            Text("Start a new cash game session to track buy-ins and calculate payouts.")
        } actions: {
            Button("New Session") {
                createNewSession()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var sessionsList: some View {
        List {
            ForEach(sessions) { session in
                NavigationLink(value: session) {
                    SessionRowView(session: session)
                }
            }
            .onDelete(perform: deleteSessions)
        }
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
    }
    
    private func createNewSession() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let session = Session(name: formatter.string(from: .now))
        modelContext.insert(session)
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.name.isEmpty ? "Untitled Session" : session.name)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                        Text("\(session.players.count)")
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                        Text("$\(session.totalPot)")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if session.isSettled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SessionsListView()
        .modelContainer(for: Session.self, inMemory: true)
        .preferredColorScheme(.dark)
}

