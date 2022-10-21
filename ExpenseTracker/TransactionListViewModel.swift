//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-08-31.
//

import Foundation
import Combine
import OrderedCollections
import Firebase

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionCollection = OrderedDictionary<Int, Transaction>
typealias TransactionPrefixSum = [(String, Double)]
final class TransactionListViewModel : ObservableObject {
    @Published var transactions : [Transaction] = []
    @Published var modified = false
    @Published var transaction = Transaction(id: 0, date: "date", type: "type", categoryId: 0, category: "category", isTransfer: false, isExpense: true, isEdited: false, title: "title", amount: 0)
    @Published var cumulativeSum = TransactionPrefixSum()
    @Published var isListEmpty = false
    
    init(){
        getTransactions()
    }
    
    func getTransactions(){
        //func to populate data model & refetched on updations/deletions
        FirebaseManager().getFireTransactions(completion: { [weak self] transactions in
            if transactions.isEmpty{ self?.isListEmpty = true }
            DispatchQueue.main.async {
                  // always update UI-linked properties on main queue
                self?.cumulativeSum = []
                self!.transactions = transactions.sorted(by: {$0.date.dateParsed() > $1.date.dateParsed()})
                if (!transactions.isEmpty){
                    self?.cumulativeSum = (self?.accumulateTransactions())!
                }
            }
        })
    }

    func groupTransactionsByMonth() -> TransactionGroup {
        //func to group transactions by month
        guard !transactions.isEmpty else { return [:] }
        let groupedTransactions = TransactionGroup(grouping: transactions) { $0.month }
        return groupedTransactions
    }
    
    func createTransactionIdCollection(transactions : [Transaction]) -> TransactionCollection {
        //func to sort transactions by id & return a set with [id, Transaction]
        guard !transactions.isEmpty else { return [:] }
        let sortedTransactions = transactions.sorted(by: {$0.id > $1.id})
        let transactionCollection = TransactionCollection(uniqueKeysWithValues: sortedTransactions.map{ ($0.id, $0) })
        return transactionCollection
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        //func to calculate sum of existant transactions on a day basis, returning a set with [date, sum]
        var count = 0
        guard !transactions.isEmpty else { return [] }
        let today = Date()
        let start = "01/01/2022".dateParsed()
        let calStart = Calendar.current.dateInterval(of: .month, for: start)!
        let calToday = Calendar.current.dateInterval(of: .month, for: today)!
        var sum : Double = 0
        
        for month in stride(from: calStart.start, to: calToday.end, by: 60 * 60 * 24 * 31){
            let monthInterval = Calendar.current.dateInterval(of: .month, for: month)!
            for date in stride(from: monthInterval.start, to: monthInterval.end, by: 60 * 60 * 24) {
                let dailyExpenses = transactions.filter { $0.dateParsed == date && $0.isExpense }
                if(!dailyExpenses.isEmpty){
                    count+=dailyExpenses.count
                    let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount }
                    sum += dailyTotal
                    sum = sum.roundedto2Digits()
                    if(sum != 0){ cumulativeSum.append((date.formatted(), sum)) }
                }
            }
        }
        return cumulativeSum
    }
    
    
    func handleDoneTapped(type: String, category: String, transfer: String, date: String, title : String, amount: String) -> Bool{
        //func to bind the obtained UI values to Transaction object
        var catid : Int {
            if let cat = Category.all.first(where: {$0.name == category}) {
                return cat.id
            }
            return 0
        }
        
        // binding UI values to obj
        let isTransfer = (transfer == "Yes") ? true : false
        let isExpense = (isTransfer && type == "Credit") ? false : true
        if(!isListEmpty){
            let idArray = transactions.map({$0.id})
            let newId = (idArray.max()!)+1
            transaction.id = newId
        }
        else {
            transaction.id = 1
        }
        transaction.isTransfer = isTransfer
        transaction.isExpense = isExpense
        transaction.category = category
        transaction.categoryId = catid
        transaction.type = type
        transaction.date = date
        transaction.title = title
        transaction.amount = Double(amount) ?? 0.0
        
        //transaction check for transfer
        if (type == "debit" && isTransfer) { saveTransfer(debitTransaction: transaction) }
        else{ self.save() }
        self.isListEmpty = false
        //call to save
        return true
      }
    
    func save() {
        //func to push the values to firebase manager
        //call firebase instance to addDocument
        let result = FirebaseManager().addTransaction(transaction: transaction)
        if (result){
            getTransactions()
        }
    }
    
    func saveTransfer(debitTransaction : Transaction){
        //saving a transfer instance (both debit & credit)
        var creditTransaction = debitTransaction
        creditTransaction.id = debitTransaction.id + 1
        creditTransaction.isTransfer = true
        creditTransaction.isExpense = false
        creditTransaction.title = "Payment - \(debitTransaction.title)"
        let result1 = FirebaseManager().addTransaction(transaction: debitTransaction)
        if(result1){
            let result = FirebaseManager().addTransaction(transaction: creditTransaction)
            if (result){
                getTransactions()
            }
        }
    }
    
    func delete(id: Int){
        let result = FirebaseManager().deleteTransactionByID(id: id)
        if (result){
            getTransactions()
        }
    }
}
