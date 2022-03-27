//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by JRobles on 26/03/2022.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    //MARK: - Title
                    Text("Overview")
                        .font(.title2)
                        .bold()
                    
                    //MARK: - Chart
                    ChartGeneratedView()
                    
                        
                    //MARK: = Transaction List
                    RecentTransactionList()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //MARK: - Notification Item
                ToolbarItem {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                    
                    
                }
            }
            
        }.navigationViewStyle(.stack)
            .accentColor(.primary)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListVM)
    }
}
