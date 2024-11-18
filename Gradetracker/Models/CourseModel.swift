//
//  CourseModel.swift
//

import Foundation
import SwiftData

@Model
final class CourseModel {
    @Attribute var id: UUID
    @Attribute var theClass: ClassModel
    @Attribute var subject: SubjectModel
    @Attribute var isEnabled: Bool
    @Relationship(deleteRule: .cascade, inverse: \AssesmentModel.course) var assesments: [AssesmentModel]


    init(id: UUID = UUID(), theClass: ClassModel, subject: SubjectModel, isEnabled: Bool = true, assesments: [AssesmentModel] = []) {
        self.id = id
        self.theClass = theClass
        self.subject = subject
        self.isEnabled = isEnabled
        self.assesments = assesments
    }
    
}

extension ModelContext {
    func isCourseSelected(theClass: ClassModel, subject: SubjectModel) -> Bool {
        let theClassId = theClass.persistentModelID, subjectid = subject.persistentModelID
        let fetchDescriptor = FetchDescriptor<CourseModel>(
            predicate: #Predicate {
                $0.theClass.persistentModelID == theClassId && $0.subject.persistentModelID == subjectid
            }
        )
        let results = try? self.fetch(fetchDescriptor)
        if let result = results?.first {
            return result.isEnabled
        }
        return false
    }
    
    func setCourse(theClass: ClassModel, subject: SubjectModel, isEnabled: Bool) {
        let theClassId = theClass.persistentModelID, subjectid = subject.persistentModelID
        let fetchDescriptor = FetchDescriptor<CourseModel>(
            predicate: #Predicate {
                $0.theClass.persistentModelID == theClassId && $0.subject.persistentModelID == subjectid
            }
        )
        let results = try? self.fetch(fetchDescriptor)
        if let result = results?.first {
            return result.isEnabled = isEnabled
        }
        self.insert(CourseModel(theClass: theClass, subject: subject, isEnabled: isEnabled))
    }
    
    func allAssesments(course: CourseModel) -> [AssesmentModel] {
        let courseId = course.persistentModelID
        let fetchDescriptor = FetchDescriptor<AssesmentModel>(
            predicate: #Predicate {
                $0.course.persistentModelID == courseId
            }
        )
        do {
            let results = try self.fetch(fetchDescriptor)
            return results
        } catch {
            print("Error fetching courses: \(error)")
            return []
        }
    }

}

