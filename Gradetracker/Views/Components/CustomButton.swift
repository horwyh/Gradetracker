//
//  CustomButton.swift
//

import SwiftUI

struct CustomButton: View {
    var title: String
    var icon: String
    var onClick: () -> ()
    var body: some View {
        Button(action: onClick, label: {
            HStack(spacing: 15) {
                Text(title)
                Image(systemName: icon)
            }
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .background(.linearGradient(.init(colors: [.black, .gray]), startPoint: .leading, endPoint: .trailing), in: .capsule)
        })
    }
}
