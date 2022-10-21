//
//  TransactionList.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-09-07.
//

import SwiftUI

struct TransactionList: View {
    @EnvironmentObject var transactionListVM : TransactionListViewModel
    @State var idArray:[Int] = []
    @State var isDelete = false
    var body: some View {
        VStack {
            List {
                ForEach(Array(transactionListVM.groupTransactionsByMonth()), id: \.key) { month, transactions in
                    Section {
                        ForEach(Array(transactionListVM.createTransactionIdCollection(transactions: transactions)), id: \.key) { transid, transaction in
                            TransactionRow(transaction: transaction)
                                .onDisappear {
                                    if(isDelete){
                                        getId(id: transid)
                                    }
                                }
                        }
                        .onDelete(perform: deletes)
                    } header: {
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)

                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
    func deletes(offsets : IndexSet) {
        isDelete = true
    }
    func getId(id : Int) {
        print("Delete disappear at \(id)")
        self.transactionListVM.delete(id: id)
        isDelete=false
    }
}

struct TransactionList_Previews: PreviewProvider {
    static let transactionListVM : TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        Group {
            NavigationView {
                TransactionList()
            }
            NavigationView {
                TransactionList()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(transactionListVM)
    }
}
