//
//  DashboardView.swift
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var showLogoutConfirmation = false
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List {
                Section {
                    HStack {
                        Text(appState.user?.initials ?? "")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.user?.name ?? "Anonymous User")
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            if let email = self.appState.user?.email {
                                Text(email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            } else {
                                Text("No email found")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                Section("Managements") {
                    NavigationLink(destination: AllClassesView()) {
                        Text("All Classes")
                    }
                    
                    NavigationLink(destination: AllStudentsView()) {
                        Text("All Students")
                    }
                    
                    NavigationLink(destination: AllSubjectsView()) {
                        Text("All Subjects")
                    }	
                }
                
                Section("Settings") {
                    HStack {
                        SettingsGear(imageName: "gear",
                                        title: "Version",
                                        tintColor: Color(.white)
                        )
                        Spacer()
                        
                        Text("1.0 Alpha")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showLogoutConfirmation) {
                        Alert(
                            title: Text("Logout"),
                            message: Text("Are you sure you want to logout?"),
                            primaryButton: .destructive(Text("Logout")) {
                                logout()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset Database")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showResetConfirmation) {
                        Alert(
                            title: Text("Reset Database"),
                            message: Text("Are you sure you want to reset the database?"),
                            primaryButton: .destructive(Text("Reset")) {
                                resetDatabase()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Gradetracker")
        } detail: {
            NavigationStack {
                Text("")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    func logout() {
        appState.userIsLoggedIn = false
    }
    
    func resetDatabase() {
//        modelContext.container.deleteAllData()
        do {
            try modelContext.delete(model: ClassModel.self)
            try modelContext.delete(model: GradeModel.self)
            try modelContext.delete(model: StudentModel.self)
            try modelContext.delete(model: SubjectModel.self)
            try modelContext.delete(model: CourseModel.self)
            try modelContext.delete(model: AssesmentModel.self)
            addDummyData(modelContext: modelContext)
        }
        catch {
            fatalError(error.localizedDescription)
        }
        appState.userIsLoggedIn = false
    }
}
