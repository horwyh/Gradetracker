//
//  AllClassesView.swift
//

import SwiftUI
import SwiftData

struct AllClassesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClassModel.name) private var theClasses: [ClassModel]

    @State var addSheetOpened: Bool = false
    @State var selectSubjectsOpened: Bool = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(searchQuery: $searchQuery)
                
                List(theClasses.filter { theClass in
                    searchQuery.isEmpty ||
                    theClass.name.localizedCaseInsensitiveContains(searchQuery)
                }, id: \.id) { theClass in
                    NavigationLink(destination: CourseListView(theClass: theClass)) {
                        VStack(alignment: .leading) {
                            let courses = modelContext.allCourses(theClass: theClass)
                            Text(theClass.name)
                            HStack {
                                ForEach(courses, id: \.self) { course in
                                    Text(course.subject.name) // Display subject name
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                // delete record
                                modelContext.delete(theClass)
                            }
                        }
                        .swipeActions {
                            Button("Edit", systemImage: "pencil") {
                                appState.editingClass = theClass // edit object
                                self.addSheetOpened = true
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("New") {
                            appState.editingClass = nil // new object
                            self.addSheetOpened = true
                        }
                    }
                }
                .sheet(isPresented: $addSheetOpened) {
                    if let editingClass = appState.editingClass {
                        ClassEditSheet(grade: editingClass.grade, index: editingClass.index)
                    }
                    else {
                        ClassEditSheet(grade: "", index: "")
                    }
                }
                .sheet(isPresented: $selectSubjectsOpened) {
                    if let editingClass = appState.editingClass {
                        SelectSubjectsSheet(theClass: editingClass)
                    }
                }
            }
            .navigationTitle("Classes")
        }

    }
}

struct ClassEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State var grade: String
    @State var index: String

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Custom Text Fields
                CustomTF(sfIcon: "number", hint: "Grade", isPassword: false, value: $grade)
                CustomTF(sfIcon: "character", hint: "Class", isPassword: false, value: $index)
                
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
                        if let editingClass = appState.editingClass {
                            // edit record
                            editingClass.grade = self.grade
                            editingClass.index = self.index
                            editingClass.name = self.grade + self.index
                            appState.editingClass = nil // edit completed
                        }
                        else {
                            // create record
                            modelContext.insert(ClassModel(grade: self.grade, index: self.index))
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
            .navigationTitle("New Class")
            .padding()
        }
    }
}
