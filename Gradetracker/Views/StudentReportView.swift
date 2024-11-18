//
//  StudentReportView.swift
//

import SwiftUI
import Charts

struct StudentReportView: View {
    
    @Environment(\.modelContext) private var modelContext
    let student: StudentModel
    @State private var courses: [CourseModel] = []
    @State private var semesterWeightings: [UUID: Double] = [:]
    
    init(student: StudentModel) {
        self.student = student
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Include the AssessmentGradeChartView here
                AssessmentGradeChartView(courses: courses, student: student)
                    .frame(height: 300) // Adjust the frame as needed
                    .padding(.bottom, 20)
                
                ForEach(self.courses, id: \.self) { course in
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 10) {
                            // Slider for selecting semester weighting for each course
                            HStack {
                                let firstSemesterWeighting = Int(semesterWeightings[course.id, default: 40])
                                let secondSemesterWeighting = 100 - firstSemesterWeighting
                                Text("Weighting of First to Second Semester - \(firstSemesterWeighting):\(secondSemesterWeighting)")
                                Slider(value: Binding(
                                    get: { self.semesterWeightings[course.id, default: 40] },
                                    set: { newValue in self.semesterWeightings[course.id] = newValue }
                                ), in: 0...100, step: 1)
                            }
                            .padding()

                            Divider()

                            // Assessments
                            ForEach(course.assesments, id: \.self) { assesment in
                                HStack {
                                    Text("\(assesment.name) (\(assesment.type.displayString) - \(assesment.semister.displayString) - \(assesment.weight)%)")
                                        .frame(width: 500, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Text(gradeString(assesment: assesment, student: student))
                                        .fontWeight(.bold)
                                        .foregroundColor(gradeColor(grade: modelContext.gradeOptional(assesment: assesment, student: student)?.grade))
                                }
                                .padding(.vertical, 2)
                            }

                            // Display calculated semester and final grades
                            let firstSemesterMark = calculateSemesterMark(course: course, semester: .first)
                            let secondSemesterMark = calculateSemesterMark(course: course, semester: .second)
                            let finalMark = calculateFinalMark(firstSemesterMark: firstSemesterMark, secondSemesterMark: secondSemesterMark, course: course)
                            
                            Group {
                                Text("First Semester Grade: ")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) +
                                Text("\(String(format: "%.2f", firstSemesterMark))")
                                    .fontWeight(.bold)
                                    .foregroundColor(gradeColor(grade: Int(firstSemesterMark)))
                                
                                Text("Second Semester Grade: ")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) +
                                Text("\(String(format: "%.2f", secondSemesterMark))")
                                    .fontWeight(.bold)
                                    .foregroundColor(gradeColor(grade: Int(secondSemesterMark)))
                                
                                Text("Final Grade: ")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) +
                                Text("\(String(format: "%.2f", finalMark))")
                                    .fontWeight(.bold)
                                    .foregroundColor(gradeColor(grade: Int(finalMark)))
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    } label: {
                        Text(course.subject.name)
                            .font(.headline)
                            .padding(.bottom, 5)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            self.loadCourses()
        }
    }
    
    func loadCourses() {
        // Assuming `theClass.courses` is an array of `CourseModel`
        // and `subject.name` is a String
        self.courses = self.student.theClass.courses.sorted {
            $0.subject.name.localizedCaseInsensitiveCompare($1.subject.name) == .orderedAscending
        }
    }
    
    func calculateSemesterMark(course: CourseModel, semester: Semister) -> Double {
        var totalWeight = 0
        var totalScore = 0.0
        
        for assessment in course.assesments where assessment.semister == semester {
            if let grade = modelContext.gradeOptional(assesment: assessment, student: student)?.grade {
                totalScore += Double(grade * assessment.weight)
                totalWeight += assessment.weight
            }
        }
        
        return totalWeight > 0 ? totalScore / Double(totalWeight) : 0
    }
    
    func calculateFinalMark(firstSemesterMark: Double, secondSemesterMark: Double, course: CourseModel) -> Double {
        let weighting = semesterWeightings[course.id, default: 50]
        return (firstSemesterMark * (weighting / 100.0)) + (secondSemesterMark * ((100 - weighting) / 100.0))
    }
    
    func gradeString(assesment: AssesmentModel, student: StudentModel) -> String {
        let grade = modelContext.gradeOptional(assesment: assesment, student: student)
        if let score = grade?.grade {
            return String(score)
        }
        return "-"
    }
    
    func gradeColor(grade: Int?) -> Color {
        guard let grade = grade else { return .black }
        switch grade {
        case 0..<40:
            return .red
        case 40..<60:
            return .orange
        case 60..<80:
            return .yellow
        case 80...100:
            return .green
        default:
            return .black // Fallback color
        }
    }
}

struct SubjectAssessmentGrade: Identifiable {
    let id = UUID()
    let subject: String
    let assessmentName: String
    let grade: Int
}

struct AssessmentGradeChartView: View {
    @Environment(\.modelContext) private var modelContext
    let courses: [CourseModel]
    let student: StudentModel
    
    // Placeholder for aggregated data
    private var data: [SubjectAssessmentGrade] {
        var result: [SubjectAssessmentGrade] = []
        
        for course in courses {
            let subjectName = course.subject.name
            let assessments = modelContext.allAssesments(course: course)
            
            for assessment in assessments {
                if let gradeModel = modelContext.gradeOptional(assesment: assessment, student: student) {
                    if let grade = gradeModel.grade {
                        let dataPoint = SubjectAssessmentGrade(subject: subjectName, assessmentName: assessment.name, grade: grade)
                        result.append(dataPoint)
                    }
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Assessment", item.assessmentName),
                y: .value("Grade", item.grade)
            )
            .foregroundStyle(by: .value("Subject", item.subject))
        }
    }
}

