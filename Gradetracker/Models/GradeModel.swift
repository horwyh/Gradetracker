//
//  GradeModel.swift
//

import Foundation
import SwiftData

@Model
class GradeModel: Identifiable, Hashable {
    @Attribute var assesment: AssesmentModel
    @Attribute var student: StudentModel
    @Attribute var grade: Int?

    init(assesment: AssesmentModel, student: StudentModel, grade: Int? = nil) {
        self.assesment = assesment
        self.student = student
        self.grade = grade
    }
}


extension ModelContext {

    func gradeOptional(assesment: AssesmentModel, student: StudentModel) -> GradeModel? {
        let assesmentId = assesment.persistentModelID, studentId = student.persistentModelID
        let fetchDescriptor = FetchDescriptor<GradeModel>(
            predicate: #Predicate {
                $0.assesment.persistentModelID == assesmentId && $0.student.persistentModelID == studentId
            }
        )
        let results = try? self.fetch(fetchDescriptor)
        if let result = results?.first {
            return result
        }
        return nil
    }
    
    func grade(assesment: AssesmentModel, student: StudentModel) -> GradeModel {
        let assesmentId = assesment.persistentModelID, studentId = student.persistentModelID
        let fetchDescriptor = FetchDescriptor<GradeModel>(
            predicate: #Predicate {
                $0.assesment.persistentModelID == assesmentId && $0.student.persistentModelID == studentId
            }
        )
        let results = try? self.fetch(fetchDescriptor)
        if let result = results?.first {
            return result
        }
        let newObject = GradeModel(assesment: assesment, student: student, grade: nil)
        self.insert(newObject)
        return newObject
    }
}
