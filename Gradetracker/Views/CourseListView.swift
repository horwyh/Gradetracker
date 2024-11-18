//
//  CourseListView.swift
//

import SwiftUI
import SwiftData

 
struct CourseListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var searchQuery: String = ""
    @State private var editMode: EditMode = .inactive

    @Query private var courses: [CourseModel]
    @Query(sort: \SubjectModel.name) private var allSubjects: [SubjectModel]


    var theClass: ClassModel
    
    init(theClass: ClassModel) {
        self.theClass = theClass
        let id = theClass.persistentModelID
        let predicate = #Predicate<CourseModel> { course in
            course.theClass.persistentModelID == id && course.isEnabled
        }
        _courses = Query(filter: predicate, sort: [SortDescriptor(\.subject.name)] )
    }
    
    @ViewBuilder
    private var listView: some View {
        if editMode == .active {
            List(allSubjects.filter { subject in
                searchQuery.isEmpty ||
                subject.name.localizedCaseInsensitiveContains(searchQuery)
            }, id: \.self) { subject in
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
        }
        else {
            List(courses.filter { course in
                searchQuery.isEmpty ||
                course.subject.name.localizedCaseInsensitiveContains(searchQuery)
            }, id: \.subject) { course in
                NavigationLink(destination: AssesmentListView(course: course)) {
                    VStack(alignment: .leading) {
                        let numberOfAssesments = modelContext.allAssesments(course: course).count
                        Text(course.subject.name).frame(maxWidth: .infinity, alignment: .leading)
                        if numberOfAssesments > 0 {
                            if numberOfAssesments == 1 {
                                Text("1 Assesment")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            else {
                                Text("\(numberOfAssesments) Assesments")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            SearchBar(searchQuery: $searchQuery)
            self.listView
        }
        .navigationTitle("Subjects")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                EditButton()
            }
        }
        .environment(\.editMode, self.$editMode)
    }
}

