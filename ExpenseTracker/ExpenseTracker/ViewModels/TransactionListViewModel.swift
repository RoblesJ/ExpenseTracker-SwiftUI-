//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by JRobles on 26/03/2022.
//

import Foundation
import Combine
import Collections
import SwiftUICharts
import SwiftUI

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = (Double, [LineChartDataPoint])
typealias TransactionSumLine = (Double, LineChartData)

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
            print("DEBUG: Invalid URL")
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("DEBUG: Error fetching transaction", error.localizedDescription)
                case .finished:
                    print("DEBUG: Finished fetching transaction")
                }
            } receiveValue: { [weak self] result in // use weak self to prevent memory leaks
                guard let self = self else { return }
                self.transactions = result
            }
            .store(in: &cancellables)
    }
    
    func groupTransactionByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupedTransactions = TransactionGroup(grouping: transactions) { $0.month }
        
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        print("DEBUG: Accumulate transactions")
        guard !transactions.isEmpty else { return TransactionPrefixSum(0, []) }
        let today = "02/17/2022".dateParse() // Date()
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        print("DEBUG: date interval \(dateInterval)")
        
        var sum: Double = .zero
        var cumulativeSum = [LineChartDataPoint]()
        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter { $0.dateParsed == date && $0.isExpense }
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmmount }
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            if dailyTotal > 0 {
            cumulativeSum.append(LineChartDataPoint(value: dailyTotal, xAxisLabel: date.formatted(), description: date.formatted()))
            }
            print("DEBUG:", date.formatted(), "DailtyTotal: \(dailyTotal)", sum)
        }
        return TransactionPrefixSum(sum, cumulativeSum)
    }
    
    func weekOfData() -> TransactionSumLine {
        let chartData = self.accumulateTransactions()
        
        
        let data = LineDataSet(dataPoints: chartData.1,
                               pointStyle: PointStyle(),
                               style: LineStyle(lineColour: ColourStyle(colours: [Color.icon, Color.icon.opacity(0.4)], startPoint: .top, endPoint: .bottom),
                                                lineType: .curvedLine,
                                                ignoreZero: false))
        
        return (chartData.0, LineChartData(dataSets : data))
    }
}

