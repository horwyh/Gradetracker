//
//  ClassModel.swift
//

import Foundation
import SwiftData

@Model
final class ClassModel {
    @Attribute(.unique) var id = UUID()
    @Attribute var name: String
    @Attribute var grade: String
    @Attribute var index: String
    @Relationship(deleteRule: .cascade, inverse: \StudentModel.theClass) var students: [StudentModel]
    @Relationship(deleteRule: .cascade, inverse: \CourseModel.theClass) var courses: [CourseModel]

    init(grade: String, index: String, students: [StudentModel] = [], courses: [CourseModel] = []) {
        self.grade = grade
        self.index = index
        self.name = grade + index
        self.students = students
        self.courses = courses
    }
    
}

extension ModelContext {
    func allCourses(theClass: ClassModel) -> [CourseModel] {
        let theClassId = theClass.persistentModelID
        let fetchDescriptor = FetchDescriptor<CourseModel>(
            predicate: #Predicate {
                $0.theClass.persistentModelID == theClassId && $0.isEnabled
            }
        )
        if let results = try? self.fetch(fetchDescriptor) {
            return results
        }
        return []
    }
    
}
