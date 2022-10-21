//
//  FirebaseManager.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-09-17.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class FirebaseManager {
    private var db = Firestore.firestore()
    
    func getFireTransactions(completion: @escaping ([Transaction]) -> ()){
        db.collection("transactions").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
            print("No documents")
            return
        }
        print("Documents fetched)")
        var transactions = [Transaction]()
            for document in documents {
                let data = document.data()
                let id = data["id"] as? Int ?? 0
                let date = data["date"] as? String ?? ""
                let type = data["type"] as? String ?? ""
                let categoryId = data["categoryid"] as? Int ?? 0
                let category = data["category"] as? String ?? ""
                let isTransfer = data["isTransfer"] as? Bool ?? false
                let isExpense = data["isExpense"] as? Bool ?? false
                let isEdited = data["isEdited"] as? Bool ?? false
                let title = data["title"] as? String ?? ""
                let amount = data["amount"] as? Double ?? 0
                transactions.append(Transaction(id: id, date: date, type: type, categoryId: categoryId, category: category, isTransfer: isTransfer, isExpense: isExpense, isEdited: isEdited, title: title, amount: amount))
            }
            completion(transactions)
        }
    }
    
    func addTransaction(transaction: Transaction) -> Bool{
        var confirm = false
        let transactionData : [String : Any] = [
            "amount" : transaction.amount,
            "category" : transaction.category,
            "categoryid" : transaction.categoryId,
            "date" : transaction.date,
            "id" : transaction.id,
            "isEdited" : transaction.isEdited,
            "isExpense" : transaction.isExpense,
            "isTransfer" : transaction.isTransfer,
            "title" : transaction.title,
            "type" : transaction.type
        ]
            db.collection("transactions").addDocument(data: transactionData, completion: { error in
                if error != nil {
                    print("Error writing document:\(String(describing: error))")
                } else {
                    print("Document successfully written!")
                    confirm=true
                }
            })
        return confirm
    }
    
    func deleteTransactionByID(id: Int) -> Bool{
        var success = false
        db.collection("transactions").whereField("id", isEqualTo: id).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            for doc in documents{
                self.db.collection("transactions").document(doc.documentID).delete(){err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                        success = true
                    }
                }
            }
        }
        return success
    }
}
