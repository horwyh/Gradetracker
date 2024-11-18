//
//  StudentModel.swift
//

import Foundation
import SwiftData

enum GenderType: Codable {
    case male
    case female
}

@Model
final class StudentModel {
    @Attribute(.unique) var id = UUID()
    @Attribute var name: String
    @Attribute var admissionDate: Date
    @Attribute var birthday: Date
    @Attribute var idcard: String
    @Attribute var studentId: String
    @Attribute var address: String
    @Attribute var phone: String
    @Attribute var email: String
    @Attribute var gender: GenderType
    @Attribute var theClass: ClassModel
    @Attribute var classNumber: Int

    init(name: String, admissionDate: Date, birthday: Date, idcard: String, studentId: String, address: String, phone: String, email: String, gender: GenderType, theClass: ClassModel, classNumber: Int){
        self.name = name
        self.admissionDate = admissionDate
        self.birthday = birthday
        self.idcard = idcard
        self.studentId = studentId
        self.address = address
        self.phone = phone
        self.email = email
        self.gender = gender
        self.theClass = theClass
        self.classNumber = classNumber
    }
}
