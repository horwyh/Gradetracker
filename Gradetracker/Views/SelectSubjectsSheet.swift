//
//  SelectSubjectsView.swift
//

import SwiftUI
import SwiftData

struct SelectSubjectsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Query(sort: \SubjectModel.name) private var subjects: [SubjectModel]

    var theClass: ClassModel
    
    var body: some View {
        VStack {
            
            List(subjects, id: \.self) { subject in
                let isSelected = modelContext.isCourseSelected(theClass: theClass, subject: subject)
                HStack() {
                    Text(subject.name).frame(maxWidth: .infinity, alignment: .leading)
                    if isSelected {
                        Text("✓")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    modelContext.setCourse(theClass: theClass, subject: subject, isEnabled: !isSelected)
                }
            }
            HStack(spacing: 15) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "multiply")
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                        Text("Cancel")
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
    }
    
}
