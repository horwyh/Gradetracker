//
//  GradeView.swift
//

import SwiftUI
import SwiftData

struct GradeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var assesment: AssesmentModel
    @State var dummyString: String = ""
    
    // Add these state variables
    @State private var sortColumn: String? = nil
    @State private var sortAscending: Bool = true

    var body: some View {
        let sortedStudents = sortColumn.map { sortStudentsByColumn($0) } ?? assesment.course.theClass.students
        Table(sortedStudents) {
            // Add sorting functionality to each column
            TableColumn("Name") { (student: StudentModel) in
                Button(action: {
                    if sortColumn == "name" {
                        sortAscending.toggle()
                    } else {
                        sortColumn = "name"
                        sortAscending = true
                    }
                }) {
                    HStack {
                        Text("Name")
                        if sortColumn == "name" {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                Text(student.name)
            }
            TableColumn("Student ID") { (student: StudentModel) in
                Button(action: {
                    if sortColumn == "studentId" {
                        sortAscending.toggle()
                    } else {
                        sortColumn = "studentId"
                        sortAscending = true
                    }
                }) {
                    HStack {
                        Text("Student ID")
                        if sortColumn == "studentId" {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                Text(student.studentId)
            }

            TableColumn("Class") { (student: StudentModel) in
                Button(action: {
                    if sortColumn == "theClass.name" {
                        sortAscending.toggle()
                    } else {
                        sortColumn = "theClass.name"
                        sortAscending = true
                    }
                }) {
                    HStack {
                        Text("Class")
                        if sortColumn == "theClass.name" {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                Text(student.theClass.name)
            }

            TableColumn("Class Number") { (student: StudentModel) in
                Button(action: {
                    if sortColumn == "classNumber" {
                        sortAscending.toggle()
                    } else {
                        sortColumn = "classNumber"
                        sortAscending = true
                    }
                }) {
                    HStack {
                        Text("Class Number")
                        if sortColumn == "classNumber" {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                Text("\(student.classNumber)")
            }

            TableColumn("Score") { (student: StudentModel) in
                Button(action: {
                    if sortColumn == "grade" {
                        sortAscending.toggle()
                    } else {
                        sortColumn = "grade"
                        sortAscending = true
                    }
                }) {
                    HStack {
                        Text("Score")
                        if sortColumn == "grade" {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                let gradeObject = modelContext.grade(assesment: self.assesment, student: student)
                ScoreColumn(gradeModel: gradeObject)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AssesmentChartView(assesment: self.assesment)) {
                    Text("Report")
                }
            }
        }
    }
    
    // Add this function to sort students by column
    private func sortStudentsByColumn(_ column: String) -> [StudentModel] {
        switch column {
        case "name":
            return sortAscending ? assesment.course.theClass.students.sorted(by: { $0.name < $1.name }) : assesment.course.theClass.students.sorted(by: { $0.name > $1.name })
        case "studentId":
            return sortAscending ? assesment.course.theClass.students.sorted(by: { $0.studentId < $1.studentId }) : assesment.course.theClass.students.sorted(by: { $0.studentId > $1.studentId })
        case "theClass.name":
            return sortAscending ? assesment.course.theClass.students.sorted(by: { $0.theClass.name < $1.theClass.name }) : assesment.course.theClass.students.sorted(by: { $0.theClass.name > $1.theClass.name })
        case "classNumber":
            return sortAscending ? assesment.course.theClass.students.sorted(by: { $0.classNumber < $1.classNumber }) : assesment.course.theClass.students.sorted(by: { $0.classNumber > $1.classNumber })
        case "grade":
            return sortAscending ? assesment.course.theClass.students.sorted(by: { modelContext.grade(assesment: self.assesment, student: $0).grade ?? 0 < modelContext.grade(assesment: self.assesment, student: $1).grade ?? 0 }) : assesment.course.theClass.students.sorted(by: { modelContext.grade(assesment: self.assesment, student: $0).grade ?? 0 > modelContext.grade(assesment: self.assesment, student: $1).grade ?? 0 })
        default:
            return assesment.course.theClass.students
        }
    }
    
    struct ScoreColumn: View {
        @Bindable var gradeModel: GradeModel
       
        var body: some View {
            TextField("Score", value: $gradeModel.grade, format: .number)
        }
    }
}
