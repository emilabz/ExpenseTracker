//
//  PreviewData.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-08-31.
//

import Foundation
import SwiftUI

var transactionPreviewData = Transaction(id: 1, date: "01/24/2022", type: "debit", categoryId: 801, category: "Software", isTransfer: false, isExpense: true, isEdited: false, title: "Apple", amount: 11.49)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 10)
