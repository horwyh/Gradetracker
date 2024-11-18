//
//  AssesmentModel.swift
//

import Foundation
import SwiftData

enum AssesmentType: Codable {
    case assignment
    case test
    case examination
}

enum Semister: Codable {
    case first
    case second
}

@Model
final class AssesmentModel {
    @Attribute var type: AssesmentType
    @Attribute var name: String
    @Attribute var createdAt: Date
    @Attribute var semister: Semister
    @Attribute var weight: Int
    @Attribute var course: CourseModel

    init(type: AssesmentType, name: String, createdAt: Date, semister: Semister, weight: Int, course: CourseModel) {
        self.type = type
        self.name = name
        self.createdAt = createdAt
        self.semister = semister
        self.weight = weight
        self.course = course
    }
}
