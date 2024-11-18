//
//  CustomTF.swift
//

import SwiftUI

struct CustomTF: View {
    var sfIcon: String
    var iconTint: Color = .gray
    var hint: String
    // Hides TextFields
    var isPassword: Bool = false
    @Binding var value: String
    // View Properties
    @State private var showPassword: Bool = false
    var body: some View {
        if isPassword {
            HStack(alignment: .top, spacing: 8, content: {
                Image(systemName: sfIcon)
                    .foregroundColor(iconTint)
                    .frame(width: 30)
                    // Slighty Bringing Down
                    .offset(y: 2)
                
                VStack(alignment: .leading, spacing: 8, content: {
                    Group {
                        // Revealing Password base on condition
                        if showPassword {
                            TextField(hint, text: $value)
                        } else {
                            SecureField(hint, text: $value)
                        }
                    }
                    
                    Divider()
                })
                .overlay(alignment: .trailing) {
                    // Password Reveal Button
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }, label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(10)
                            .contentShape(.rect)
                    })
                }
            })
        } else {
            HStack(alignment: .top, spacing: 8, content: {
                Image(systemName: sfIcon)
                    .foregroundColor(iconTint)
                    .frame(width: 30)
                // Slighty Bringing Down
                    .offset(y: 2)
                
                VStack(alignment: .leading, spacing: 8, content: {
                    Group {
                        TextField(hint, text: $value)
                            .autocapitalization(.none)
                    }
                    
                    Divider()
                })
            })
        }
    }
}
