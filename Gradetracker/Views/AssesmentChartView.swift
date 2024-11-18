//
//  AssesmentChartView.swift
//

import SwiftUI
import Charts

struct AssesmentChartView: View {
 
    @Environment(\.modelContext) private var modelContext

    var assesment: AssesmentModel

    struct GradeInfo: Identifiable {
        var id: UUID { return student.id }
        let student: StudentModel
        let grade: Int
    }
    
    struct GradeGroup: Hashable {
        var id: Int { return index }
        var index: Int
        var count: Int = 0
    }
    
    @State var grades: [GradeInfo] = []
    @State var groups: [Int: GradeGroup] = [:]

    
    init(assesment: AssesmentModel) {
        self.assesment = assesment
    }

    var body: some View {
        ScrollView {
            VStack {
                Chart {
                    // Map groups to an array of values
                    let values = groups.map { $0.value }
                    // Loop over each group
                    ForEach(values, id: \.self) { group in
                        // Bar mark for each group with score and count
                        BarMark(
                            x: .value("Score", group.index),
                            y: .value("Count", group.count)
                        )
                        .accessibilityLabel(group.count == 1 ? "1 student scored \(group.index * 10)%" : "\(group.count) students scored \(group.index * 10)%")
                        
                    }
                }
                // Add horizontal padding to the chart
                .padding(.horizontal)
                .aspectRatio(3, contentMode: .fit)
                
                VStack(alignment: .leading, spacing: 5) {
                    let stats = calculateStatistics()
                    Text("Mean: \(String(format: "%.2f", stats.mean))")
                    Text("Median: \(String(format: "%.2f", stats.median))")
                    Text("Mode: \(stats.mode.map(String.init).joined(separator: ", "))")
                    Text("25th Percentile: \(String(format: "%.2f", stats.percentiles.p25))")
                    Text("50th Percentile: \(String(format: "%.2f", stats.percentiles.p50))")
                    Text("75th Percentile: \(String(format: "%.2f", stats.percentiles.p75))")
                    Text("Range: \(stats.range)")
                    Text("Variance: \(String(format: "%.2f", stats.variance))")
                    Text("Standard Deviation: \(String(format: "%.2f", stats.standardDeviation))")
                }
                .padding(.horizontal)

                // Vertical stack for grades with leading alignment and 10 points of spacing
                VStack(alignment: .leading, spacing: 10) {
                    // Loop over each grade
                    ForEach(grades) { gradeInfo in
                        // Horizontal stack for each grade
                        HStack {
                            // Display student name
                            Text(gradeInfo.student.name)
                            // Push the next text view to the right
                            Spacer()
                            // Display grade
                            Text(String(gradeInfo.grade))
                        }
                    }
                }
                .padding(.horizontal)

                Table(grades) {
                    TableColumn("Name") { gradeInfo in
                        Text(gradeInfo.student.name)
                    }
                    TableColumn("Score") { gradeInfo in
                        Text(String(gradeInfo.grade))
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Report")
        .onAppear {
            self.processData()
        }
    }
    
    func processData() {
        groups.removeAll(keepingCapacity: true)
        for i in 0..<10 {
            groups[i] = GradeGroup(index: i)
        }
        for student in assesment.course.theClass.students {
            if let gradeOjbect = modelContext.gradeOptional(assesment: assesment, student: student), let grade = gradeOjbect.grade {
                grades.append(GradeInfo(student: student, grade: grade))
                let group = max(0, min(9, grade / 10))
                var a = groups[group]!
                a.count += 1
                groups[group] = a
            }
            else {
                
            }
        }
    }
    
    func calculateStatistics() -> (mean: Double, median: Double, mode: [Int], percentiles: (p25: Double, p50: Double, p75: Double), range: Int, variance: Double, standardDeviation: Double) {
        let sortedGrades = grades.map { $0.grade }.sorted()
        let count = Double(sortedGrades.count)
        
        // Mean
        let mean = sortedGrades.reduce(0.0) { $0 + Double($1) } / Double(count)
        
        // Median
        let middleIndex = sortedGrades.count / 2
        let median: Double
        if sortedGrades.isEmpty {
            median = 0.0
        } else if sortedGrades.count % 2 == 0 {
            let middleIndex = sortedGrades.count / 2
            median = Double(sortedGrades[middleIndex - 1] + sortedGrades[middleIndex]) / 2.0
        } else {
            let middleIndex = sortedGrades.count / 2
            median = Double(sortedGrades[middleIndex])
        }
        
        // Mode
        let mode: [Int] = {
            var frequency: [Int: Int] = [:]
            sortedGrades.forEach { frequency[$0, default: 0] += 1 }
            let maxFrequency = frequency.values.max() ?? 0
            return frequency.filter { $0.value == maxFrequency }.keys.sorted()
        }()
        
        // Percentiles
        func percentile(_ sortedGrades: [Int], percentile: Double) -> Double {
            guard !sortedGrades.isEmpty else {
                // Handle the empty array case
                return 0.0
            }
            
            let rank = percentile * Double(sortedGrades.count - 1)
            let lowerIndex = max(0, Int(floor(rank)))
            let upperIndex = min(sortedGrades.count - 1, Int(ceil(rank)))
            
            if lowerIndex == upperIndex {
                return Double(sortedGrades[lowerIndex])
            }
            
            // Calculate the interpolated value between lower and upper values
            let lowerValue = Double(sortedGrades[lowerIndex])
            let upperValue = Double(sortedGrades[upperIndex])
            let interpolation = (rank - Double(lowerIndex)) / Double(upperIndex - lowerIndex)
            
            return lowerValue + (upperValue - lowerValue) * interpolation
        }
        let p25 = percentile(sortedGrades, percentile: 0.25)
        let p50 = percentile(sortedGrades, percentile: 0.50)
        let p75 = percentile(sortedGrades, percentile: 0.75)
        
        // Range
        let range: Int
        if let firstGrade = sortedGrades.first, let lastGrade = sortedGrades.last {
            range = lastGrade - firstGrade
        } else {
            range = 0
        }
        
        // Variance and Standard Deviation
        let variance = sortedGrades.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / count
        let standardDeviation = sqrt(variance)
        
        return (mean, median, mode, (p25, p50, p75), range, variance, standardDeviation)
    }
}
