//
//  SubjectModel.swift
//

import Foundation
import SwiftData

@Model
final class SubjectModel {
    @Attribute(.unique) var id = UUID()
    @Attribute var name: String
    @Relationship(deleteRule: .cascade, inverse: \CourseModel.subject) var courses: [CourseModel]

    init(name: String, courses: [CourseModel] = []) {
        self.name = name
        self.courses = courses
    }
}
