//
//  SettingsGearSymbol.swift
//

import SwiftUI

struct SettingsGear: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(tintColor)
        }
    }
}

struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsGear(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    }
}
