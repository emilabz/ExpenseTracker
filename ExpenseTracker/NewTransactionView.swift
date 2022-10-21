//
//  NewTransactionView.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-09-23.
//

import SwiftUI

struct NewTransactionView: View {
    @EnvironmentObject var transactionListVM : TransactionListViewModel
    @Environment(\.presentationMode) private var presentationMode
    var categories = Category.all
    @State var title = ""
    @State var amount = ""
    @State var category = ""
    @State private var selectedChoice = "No"
    @State private var selectedType = "Debit"
    @State private var selectedCategory = "Auto & Transport"
    @State private var defaultDate = Date.now
    let types = ["Debit", "Credit"]
    let choices = ["Yes", "No"]
    
    var body: some View {
        NavigationView {
              Form {
                Section(header: Text("Main Details:")) {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Additional info")) {
                    let catlist = categories.map { category in
                        return category.name
                    }
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(catlist, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Is it a transfer?", selection: $selectedChoice) {
                        ForEach(choices, id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(selectedType == "Credit")
                    DatePicker("Select date", selection: $defaultDate, displayedComponents: .date)
                }
              }
              .navigationTitle("New Transaction")
              .navigationBarBackButtonHidden(true)
              .navigationBarItems(
                leading:
                  Button(action: {
                      self.handleCancelTapped()
                      
                  }) {
                    Text("Cancel")
                  },
                trailing:
                  Button(action: {
                      self.handleDoneTapped(type: self.selectedType, category: self.selectedCategory, transfer: self.selectedChoice, title: title, amount: amount)
                      
                  }) {
                    Text("Done")
                  }
                )
            }
    }
    func handleCancelTapped() {
        restoreDefaults()
        dismiss()
    }
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
    func handleDoneTapped(type : String, category : String, transfer : String, title: String, amount: String) {
        let formattedDate = defaultDate.formatted(date: .numeric, time: .omitted)
        print("Date : \(formattedDate)")
        print("Amount : \(amount)")
        if(title.isEmpty){
            print("Empty string")
        }
        else{
            let res=self.transactionListVM.handleDoneTapped(type: type, category: category, transfer: transfer, date: formattedDate,title : title, amount: amount)
            restoreDefaults()
            if res{
                dismiss()}
        }
    }
    
    func restoreDefaults(){
        title=""
        amount=""
        selectedChoice = "No"
        selectedType = "Debit"
        selectedCategory = "Auto & Transport"
        defaultDate = Date.now
    }
}

struct NewTransactionView_Previews: PreviewProvider {
    static let transactionListVM : TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        Group{
            NewTransactionView()
            NewTransactionView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
    }
}
