//
//  AllStudentView.swift
//

import SwiftUI
import SwiftData

struct AllStudentsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudentModel.name) private var studentObjects: [StudentModel]

    @State var addSheetOpened: Bool = false
    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(searchQuery: $searchQuery)
                
                List(studentObjects.filter { student in
                    searchQuery.isEmpty ||
                    student.name.localizedCaseInsensitiveContains(searchQuery) ||
                    student.theClass.name.localizedCaseInsensitiveContains(searchQuery) ||
                    student.studentId.localizedCaseInsensitiveContains(searchQuery)
                }, id: \.id) { student in
                    NavigationLink(destination: StudentReportView(student: student)) {
                        VStack(alignment: .leading) {
                            Text(student.name)
                            Text(student.studentId) // added this line
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(student.theClass.name) \(student.classNumber)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                // delete record
                                modelContext.delete(student)
                            }
                        }
                        .swipeActions {
                            Button("Edit", systemImage: "pencil") {
                                appState.editingStudent = student // edit object
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
                    if let editingStudent = appState.editingStudent {
                        StudentEditSheet(name: editingStudent.name,
                                         admissionDate: editingStudent.admissionDate,
                                         birthday: editingStudent.birthday,
                                         idcard: editingStudent.idcard,
                                         studentId: editingStudent.studentId,
                                         address: editingStudent.address,
                                         phone: editingStudent.phone,
                                         email: editingStudent.email,
                                         gender: editingStudent.gender,
                                         theClass: editingStudent.theClass,
                                         classNumber: editingStudent.classNumber)
                    }
                    else {
                        StudentEditSheet(name: "",
                                         admissionDate: Date(),
                                         birthday: Date(),
                                         idcard: "",
                                         studentId: "",
                                         address: "",
                                         phone: "",
                                         email: "",
                                         gender: nil,
                                         theClass: nil,
                                         classNumber: nil)
                    }
                }
            }
        }
        .navigationTitle("Students")
    }
}

struct StudentEditSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query(sort: \ClassModel.name) private var classes: [ClassModel]

    @State var errorMessage: String?
    @State var showingAlert: Bool = false

    @State var name: String
    @State var admissionDate: Date
    @State var birthday: Date
    @State var idcard: String
    @State var studentId: String
    @State var address: String
    @State var phone: String
    @State var email: String
    @State var gender: GenderType?
    @State var theClass: ClassModel?
    @State var classNumber: Int?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Custom Text Fields
                    CustomTF(sfIcon: "person", hint: "Name", isPassword: false, value: $name)
                    HStack {
                        Text("Gender")
                        Picker("Gender", selection: $gender) {
                            Text("---").tag(nil as GenderType?)
                            Text("Male").tag(GenderType.male as GenderType?)
                            Text("Female").tag(GenderType.female as GenderType?)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text("Class")
                        Picker("Class", selection: $theClass) {
                            Text("---").tag(nil as ClassModel?)
                            ForEach(classes, id:\.self) { theClass in
                                Text(theClass.name).tag(theClass as ClassModel?)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    TextField("Class Number", value: $classNumber, format: .number)
                    CustomTF(sfIcon: "person.text.rectangle", hint: "Student ID", isPassword: false, value: $studentId)
                    CustomTF(sfIcon: "person.text.rectangle", hint: "ID Card", isPassword: false, value: $idcard)
                    CustomTF(sfIcon: "book.closed", hint: "Address", isPassword: false, value: $address)
                    CustomTF(sfIcon: "phone", hint: "Phone", isPassword: false, value: $phone)
                    CustomTF(sfIcon: "tray", hint: "Email", isPassword: false, value: $email)
                    DatePicker("Admission Date", selection: $admissionDate, displayedComponents: [.date])
                    DatePicker("Birthday", selection: $birthday, displayedComponents: [.date])
                    
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
                            if let gender = self.gender, let theClass = self.theClass, !self.studentId.isEmpty {
                                if let editingStudent = appState.editingStudent {
                                    // edit record
                                    editingStudent.name = self.name
                                    editingStudent.admissionDate = self.admissionDate
                                    editingStudent.birthday = self.birthday
                                    editingStudent.idcard = self.idcard
                                    editingStudent.studentId = self.studentId
                                    editingStudent.address = self.address
                                    editingStudent.phone = self.phone
                                    editingStudent.email = self.email
                                    editingStudent.gender = gender
                                    editingStudent.theClass = theClass
                                    editingStudent.classNumber = self.classNumber ?? 0
                                    appState.editingStudent = nil // edit completed
                                }
                                else {
                                    // create record
                                    modelContext.insert(StudentModel(name: self.name, admissionDate: self.admissionDate, birthday: self.birthday, idcard: self.idcard, studentId: self.studentId, address: self.address, phone: self.phone, email: self.email, gender: gender, theClass: theClass, classNumber: self.classNumber ?? 0))
                                }
                                presentationMode.wrappedValue.dismiss()
                            }
                            else {
                                if self.gender == nil {
                                    errorMessage = "Please select gender"
                                }
                                else if self.theClass == nil {
                                    errorMessage = "Please select class"
                                }
                                else if self.studentId.isEmpty {
                                    errorMessage = "Please enter student ID"
                                }
                                else {
                                    errorMessage = nil
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
                        .padding()
                    }
                }
            }
            .navigationTitle("New Student")
            .padding()
        }
        .alert(errorMessage ?? "", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }

    }
}
