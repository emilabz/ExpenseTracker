//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-08-31.
//

import SwiftUI
import Firebase

@main
struct ExpenseTrackerApp: App {
    init() {
        FirebaseApp.configure()
    }
    @StateObject var transactionListVM = TransactionListViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(transactionListVM)
        }
    }
}
