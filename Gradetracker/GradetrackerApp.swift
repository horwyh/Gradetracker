//
//  GradetrackerApp.swift
//

import SwiftUI
import SwiftData

class AppState: ObservableObject {
    @Published var userIsLoggedIn: Bool = false
    @Published var user: UserModel?
    var editingClass: ClassModel?
    var editingSubject: SubjectModel?
    var editingStudent: StudentModel?
    var editingAssesment: AssesmentModel?
}
    
@main
struct Grade_TrackerApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClassModel.self,
            UserModel.self,
            StudentModel.self,
            SubjectModel.self,
            CourseModel.self,
            AssesmentModel.self,
            GradeModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var appState: AppState = AppState()
    

    init() {
        createDummyData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(appState)
    }

    @MainActor
    func createDummyData() {
        let modelContext = self.sharedModelContainer.mainContext
        addDummyData(modelContext: modelContext)
    }
}


func addDummyData(modelContext: ModelContext) {
    
    if (try? modelContext.fetchCount(FetchDescriptor<UserModel>())) == 0 {
        modelContext.insert(UserModel(name: "Horace Wong", email: "test@xcode.com", password: "abc123"))
    }
    if (try? modelContext.fetchCount(FetchDescriptor<ClassModel>())) == 0 {
        let data = [
            ["1", "A"],
            ["1", "B"],
            ["1", "C"],
            ["1", "D"],
            ["2", "A"],
            ["2", "B"],
            ["2", "C"],
            ["2", "D"],
            ["3", "A"],
            ["3", "B"],
            ["3", "C"],
            ["3", "D"],
        ]
        data.forEach { c in
            let course = ClassModel(grade: c[0], index: c[1])
            course.id = UUID()
            modelContext.insert(course)
        }
        // create subject sample data
        let subjectSampleData = [ "Chinese", "English", "Mathematics", "Physics", "Chemistry", "Biology", "Intergrated Science", "History", "Chinese History", "Geography", "Art", "Music", "ICT"]
        subjectSampleData.forEach { c in
            let subject = SubjectModel(name: c)
            modelContext.insert(subject)
        }
    }
}
