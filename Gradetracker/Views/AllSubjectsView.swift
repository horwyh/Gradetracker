//
//  AllSubjectsView.swift
//

import SwiftUI
import SwiftData

struct AllSubjectsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubjectModel.name) private var subjects: [SubjectModel]
    
    @State var addSheetOpened: Bool = false
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            SearchBar(searchQuery: $searchQuery)
            
            List(subjects.filter { subjects in
                searchQuery.isEmpty ||
                subjects.name.localizedCaseInsensitiveContains(searchQuery)
            }) { subjects in
                VStack(alignment: .leading) {
                    Text(subjects.name)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        // delete record
                        modelContext.delete(subjects)
                    }
                }
                .swipeActions {
                    Button("Edit", systemImage: "pencil") {
                        appState.editingSubject = subjects // edit object
                        self.addSheetOpened = true
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New") {
                    appState.editingSubject = nil // new object
                    self.addSheetOpened = true
                }
            }
        }
        .sheet(isPresented: $addSheetOpened) {
            if let editingClass = appState.editingSubject {
                SubjectEditSheet(name: editingClass.name)
            }
            else {
                SubjectEditSheet(name: "")
            }
        }
        .navigationTitle("Subjects")
    }
    
    struct SubjectEditSheet: View {
        @EnvironmentObject var appState: AppState
        @Environment(\.modelContext) private var modelContext
        @Environment(\.presentationMode) var presentationMode
        @State var name: String
        
        var body: some View {
            NavigationView {
                VStack(spacing: 25) {
                    // Custom Text Fields\
                    CustomTF(sfIcon: "character", hint: "Subject", isPassword: false, value: $name)
                    
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
                        
                        Button(action: {
                            if let editingClass = appState.editingSubject {
                                // edit record
                                editingClass.name = self.name
                                appState.editingSubject = nil // edit completed
                            }
                            else {
                                // create record
                                modelContext.insert(SubjectModel(name: self.name))
                            }
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Text("Save")
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
                .navigationTitle("New Subject")
                .padding()
            }
        }
    }
}
