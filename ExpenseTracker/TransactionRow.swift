//
//  TransactionRow.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-08-31.
//

import SwiftUI
import SwiftUIFontIcon

struct TransactionRow: View {
    var transaction: Transaction
    var body: some View {
        //HSTACK
        HStack(spacing: 20){
            //CATEGORY-ICON
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.icon.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay {
                    FontIcon.text(.awesome5Solid(code: transaction.icon), fontsize: 24, color: Color.icon)
                }
            //VSTACK
            VStack(alignment: .leading, spacing: 6){
                //MARK:- TRANSMERCHANT
                Text(transaction.title)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                
                //MARK:- TRANSCATEGORY
                Text(transaction.category)
                    .font(.footnote)
                    .opacity(0.7)
                    .lineLimit(1)
                
                //MARK:- TRANSDATE
                Text(transaction.dateParsed, format: .dateTime.year().month().day())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

            }   //MARK:- VSTACK
            Spacer()
            
            //MARK:- TRANSAMOUNT
            Text(transaction.signedAmount, format: .currency(code: "USD"))
                .bold()
                .foregroundColor(transaction.type == TransactionType.credit.rawValue ? Color.text : .primary)
        }   //MARK:- HSTACK
        .padding([.top, .bottom], 8)
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionRow(transaction: transactionPreviewData)
            TransactionRow(transaction: transactionPreviewData)
                .preferredColorScheme(.dark)
        }
    }
}
