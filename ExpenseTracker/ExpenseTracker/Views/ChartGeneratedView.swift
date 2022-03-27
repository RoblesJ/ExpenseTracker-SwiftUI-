//
//  ChartGeneratedView.swift
//  ExpenseTracker
//
//  Created by JRobles on 27/03/2022.
//

import SwiftUI
import SwiftUICharts

struct ChartGeneratedView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.systemBackground)
                .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 5)
            VStack(alignment: .leading) {
                
                let data = transactionListVM.weekOfData()
                
                //NOTE TO SELF: MOVE THIS LOGIC TO VM
                if data.0 > 0 {
                    Text(data.0.formatted(.currency(code: "USD")))
                        .font(.title)
                        .padding([.leading, .top], 18)
                    FilledLineChart(chartData: data.1)
                        .id(data.1.id)
                        .padding(18)
                }
            }
            
        }
        .frame(height: 300)
        
        
        
    }
}

struct ChartGeneratedView_Previews: PreviewProvider {
    static var previews: some View {
        ChartGeneratedView()
    }
}
