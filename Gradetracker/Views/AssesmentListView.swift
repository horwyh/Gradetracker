//
//  AssesmentListView.swift
//

import SwiftUI
import SwiftData

struct AssesmentListView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @Query private var assesments: [AssesmentModel]
    @State var addSheetOpened: Bool = false
    @State private var searchQuery = ""

    let course: CourseModel
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(course: CourseModel) {
        self.course = course
        let id = course.persistentModelID
        let predicate = #Predicate<AssesmentModel> { assesment in
            assesment.course.persistentModelID == id
        }
        _assesments = Query(filter: predicate, sort: [SortDescriptor(\.createdAt, order: .reverse)] )
    }

    var body: some View {
        VStack {
            SearchBar(searchQuery: $searchQuery)
            
            List(assesments.filter { assesment in
                searchQuery.isEmpty ||
                assesment.name.localizedCaseInsensitiveContains(searchQuery)
            }, id: \.self) { assesment in
                NavigationLink(destination: GradeView(assesment: assesment)) {
                    VStack(alignment: .leading) {
                        Text(assesment.name)
                        // Display the semester here
                        Text("\(assesment.type.displayString) - \(assesment.semister.displayString) - \(assesment.weight)%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: assesment.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(assesment)
                    }
                }
                .swipeActions {
                    Button("Edit", systemImage: "pencil") {
                        appState.editingAssesment = assesment
                        self.addSheetOpened = true
                    }
                }
            }
        }
        .navigationTitle("Assesments")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New") {
                    appState.editingAssesment = nil
                    self.addSheetOpened = true
                }
            }
        }
        .sheet(isPresented: $addSheetOpened) {
            if let editingAssesment = appState.editingAssesment {
                AssesmentEditSheet(assesmentType: editingAssesment.type, semister: editingAssesment.semister, weight: editingAssesment.weight, name: editingAssesment.name, createdAt: editingAssesment.createdAt, course: self.course)
            }
            else {
                AssesmentEditSheet(assesmentType: nil, semister: nil, weight: nil, name: "", createdAt: Date(), course: self.course)
            }
        }
    }
    
}

struct AssesmentEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State var assesmentType: AssesmentType?
    @State var semister: Semister?
    @State var weight: Int?
    @State var name: String
    @State var createdAt: Date
    
    @State var errorMessage: String?
    @State var showingAlert: Bool = false

    var course: CourseModel?

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Custom Text Fields
                DatePicker("Created Date", selection: $createdAt, displayedComponents: [.date, .hourAndMinute])
                CustomTF(sfIcon: "character", hint: "Name", isPassword: false, value: $name)
                HStack {
                    Text("Type")
                    Picker("Type", selection: $assesmentType) {
                        Text("---").tag(nil as AssesmentType?)
                        Text("Assignment").tag(AssesmentType.assignment as AssesmentType?)
                        Text("Test").tag(AssesmentType.test as AssesmentType?)
                        Text("Exam").tag(AssesmentType.examination as AssesmentType?)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Text("Semister")
                    Picker("Semister", selection: $semister) {
                        Text("---").tag(nil as Semister?)
                        Text("First").tag(Semister.first as Semister?)
                        Text("Second").tag(Semister.second as Semister?)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                
                TextField("Weight", value: $weight, format: .number)
                
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
                        if let assesmentType = self.assesmentType, let semister = self.semister {
                            let weight = self.weight ?? 0
                            if let assesment = appState.editingAssesment {
                                // edit record
                                assesment.name = self.name
                                assesment.createdAt = self.createdAt
                                assesment.type = assesmentType
                                assesment.semister = semister
                                assesment.weight = weight
                                appState.editingAssesment = nil // edit completed
                                do {
                                    try modelContext.save() // Save changes
                                } catch {
                                    print("Failed to save changes: \(error)")
                                }
                            }
                            else {
                                // create record
                                if let course = self.course {
                                    modelContext.insert(AssesmentModel(type: assesmentType, name: self.name, createdAt: self.createdAt, semister: semister, weight: weight, course: course)) // Edit this line
                                    do {
                                        try modelContext.save() // Save changes
                                    } catch {
                                        print("Failed to save changes: \(error)")
                                    }
                                }
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                        else {
                            if self.assesmentType == nil {
                                errorMessage = "Please select Type and Semister"
                            }
                            if errorMessage != nil {
                                self.showingAlert = true
                            }
                        }
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
            .navigationTitle("New Assesment")
            .padding()
        }
        .alert(errorMessage ?? "", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }

    }
}

extension Semister {
    var displayString: String {
        switch self {
        case .first:
            return "First Semester"
        case .second:
            return "Second Semester"
        }
    }
}

extension AssesmentType {
    var displayString: String {
        switch self {
        case .assignment:
            return "Assignment"
        case .test:
            return "Test"
        case .examination:
            return "Examination"
        }
    }
}
