//
//  UserModel.swift
//

import Foundation
import SwiftData

@Model
final class UserModel {
    
    static let salt = "l9kWppMQMP"
    
    @Attribute(.unique) var email: String
    var name: String
    var passwordHashed: Data    // stored password must not stored in plain text
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.passwordHashed = password.sha256(salt: UserModel.salt)
    }
    
    func checkPassword(_ password: String) -> Bool {
        // compare the hash to check the password is correct
        return password.sha256(salt: UserModel.salt) == self.passwordHashed
    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: self.name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }

}
