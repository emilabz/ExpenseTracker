 //
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Emil Abraham Zachariah on 2022-08-31.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    @EnvironmentObject var transactionListVM : TransactionListViewModel
    //BODY
    private var totalExpenses : Double = 0.0
    var body: some View {
        
        //NAVIGATION
        NavigationView {
                //SCROLL
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if(transactionListVM.isListEmpty) {
                            VStack(alignment: .center, spacing: 100){
                                Spacer()
                                Text("No entries")// Placeholder
                                    .font(.title)
                                HStack {
                                    Label("Click", systemImage: "plus")
                                        .labelStyle(.titleOnly)
                                    Label("to add new entry", systemImage: "plus")
                                }
                            }
                        }
                        else{
                            //TITLE
                            Text("Overview")
                                .font(.title2)
                                .bold()
                            
                            //Line chart
                            let data = transactionListVM.cumulativeSum
                            if (!data.isEmpty) {
                                let totalExpenses = data.last?.1 ?? 0
                                let _ = print("Total expenses = \(totalExpenses)")
                                CardView(showShadow: false) {
                                    VStack(alignment: .leading){
                                        ChartLabel(totalExpenses.formatted(.currency(code: "USD")), type: .title, format: "$%.2f")
                                        LineChart()
                                    }
                                    .background(Color.systemBackground)
                                }
                                .data(data)
                                .chartStyle(ChartStyle(backgroundColor: .systemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                                .frame(height: 300)
                                .background(Color.systemBackground)
                            }
                           
                            
                            //Transaction List
                            RecentTransactionList()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                }   //MARK:- SCROLL
                .background(Color.background)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //ADD TRANSACTION
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}, label: {
                            NavigationLink(destination: NewTransactionView()){
                                Image(systemName: "plus")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.icon, .primary)
                            }
                        })
                    }
                }
        }   // MARK :- NAVIGATION
        .navigationViewStyle(.stack)
        .accentColor(.primary)
    }    // MARK :- BODY
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListVM : TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        Group{
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
    }
}
