import SwiftUI
import MiniApp

struct MiniAppSettingsContactsView: View {

    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var contacts: [MAContact] = []
    @State var editContact: MAContact?

    var body: some View {
        ZStack {
            List {
                ForEach($contacts, id: \.id) { contact in
                    ContactCellView(
                        name: contact.name ?? "",
                        contactId: contact.id,
                        email: contact.email ?? "",
                        allEmails: contact.allEmailList ?? [""]
                    )
                    .onTapGesture {
                        guard let index = index(for: contact.wrappedValue) else { return }
                        editContact = contacts[index]
                    }
                }
            }
        }
        .sheet(item: $editContact, content: { contact in
            NavigationView {
                ContactFormView(
                    contactData: Binding<MAContact>(get: { contact }, set: {new in editContact = new }),
                    isEditing: Binding<Bool>(get: { index(for: contact) != nil }, set: { _ in }),
                    allEmails: Binding<[String]>(get: { contact.allEmailList ?? [""] }, set: {new in editContact?.allEmailList = new}),
                    onSave: {
                        if let index = index(for: contact) {
                            contacts[index] = removeEmptyEmailStrings(for: contact)
                        } else {
                            contacts.insert(contact, at: 0)
                        }
                        editContact = nil
                        viewModel.saveContactList(contacts: contacts)
                    },
                    onClose: {
                        editContact = nil
                    }
                )
            }
        })
        .listStyle(.plain)
        .navigationTitle(pageName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Add")
                    editContact = viewModel.createRandomContact()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            contacts = viewModel.getContacts()
        }
        .trackPage(pageName: pageName)
    }

    func index(for contact: MAContact) -> Int? {
        return contacts.firstIndex(where: { $0.id == contact.id })
    }

    func removeEmptyEmailStrings(for contact: MAContact) -> MAContact {
        var newContact = contact
        if newContact.allEmailList != nil {
            if newContact.allEmailList?.first ?? "" == "" {
                newContact.allEmailList = nil
            } else {
                newContact.allEmailList = newContact.allEmailList?.filter { $0 != "" }
            }
            return newContact
        } else {
            return newContact
        }
    }
}

extension MiniAppSettingsContactsView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.contactslist", comment: "")
    }
}

struct MiniAppSettingsContactsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsContactsView(viewModel: MiniAppSettingsViewModel())
    }
}

extension MiniAppSettingsContactsView {
    struct ContactCellView: View {

        @Binding var name: String
        @Binding var contactId: String
        @Binding var email: String
        @Binding var allEmails: [String]

        var body: some View {
            HStack {
                Circle()
                    .fill(.red)
                    .frame(width: 60, height: 60, alignment: .center)
                    .overlay(Image("profile").foregroundColor(.white))
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                    Text("Contact ID: \(contactId)")
                        .lineLimit(1)
                    Text("E-Mail address: \(email)")
                    if allEmails.first ?? "" != "" {
                        Text("Email List: \(allEmails.map { String($0) }.joined(separator: ", "))")
                    }
                }
                .font(.system(size: 13))
            }
            .padding(.vertical, 10)
        }
    }

    struct ContactFormView: View, ViewTrackable {

        @Binding var contactData: MAContact
        @Binding var isEditing: Bool
        @State private var isContactInfoInValid: Bool = false
        @Binding var allEmails: [String]

        var onSave: () -> Void

        var onClose: () -> Void

        var body: some View {
            List {
                TextField("Name", text: $contactData.name ?? "")
                TextField("Contact Id", text: $contactData.id)
                TextField("Email", text: $contactData.email ?? "")
                    .keyboardType(.emailAddress)
                ForEach(allEmails.indices, id: \.self) { index in
                    HStack {
                        TextField("E-mail Address (Optional) \(index + 1)", text: $allEmails[index])
                            .keyboardType(.emailAddress)
                        Button {
                            allEmails.remove(at: index)
                        } label: {
                            Image(systemName: "at.badge.minus")
                                .foregroundColor(Color.red)
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        if allEmails.count < 5 {
                            allEmails.append("")
                        }
                    } label: {
                        if allEmails.count < 5 {
                            Image(systemName: "at.badge.plus")
                                .foregroundColor(Color.red)
                        } else {
                            Text("Maximum of 5 E-mails allowed")
                                .foregroundColor(Color.red)
                        }
                    }.disabled(allEmails.count > 5)
                }
            }
            .navigationTitle(pageName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CloseButton {
                        trackButtonTap(pageName: pageName, buttonTitle: "Close")
                        onClose()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Save")
                        if validateContactinfo() {
                            isContactInfoInValid = false
                            onSave()
                        } else {
                            isContactInfoInValid = true
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }
            .alert(isPresented: $isContactInfoInValid) {
                let errorMessage = self.getValidationErrormessage()
                return Alert(
                    title: Text("Invalid Contact Details"),
                    message: Text(errorMessage)
                )
            }
        }

        func getValidationErrormessage() -> String {
            var errorMessage = ""
            if (contactData.name ?? "").isValueEmpty() {
                errorMessage += "Name cannot be empty.\n"
            }
            if contactData.id.isValueEmpty() {
                errorMessage += "Contact Id cannot be empty.\n"
            }
            if let email = contactData.email, !email.isValueEmpty() {
                if !email.isValidEmail() {
                    errorMessage += "E-mail id is invalid.\n"
                }
            } else {
                errorMessage += "E-mail id cannot be empty.\n"
            }
            guard let allEmails = contactData.allEmailList else {
                errorMessage += "Please correct and try again."
                return errorMessage
            }

            for (idx, emailId) in allEmails.enumerated() where (!emailId.isValueEmpty() && !emailId.isValidEmail()) {
                errorMessage += "E-mail \(idx + 1) is invalid.\n"
            }
            errorMessage += "Please correct and try again."
            return errorMessage
        }

        func validateContactinfo() -> Bool {
            var isEmailListValid = true
            for emailStr in allEmails {
                if emailStr == "" {
                    isEmailListValid = true
                } else {
                    isEmailListValid = emailStr.isValidEmail()
                }
            }
            return (!(contactData.name ?? "").isValueEmpty() && !contactData.id.isValueEmpty() && (contactData.email ?? "").isValidEmail() && isEmailListValid)
        }

        var pageName: String {
            return isEditing ? (NSLocalizedString("demo.app.rat.page.name.editcontactsform", comment: "")) : (NSLocalizedString("demo.app.rat.page.name.contactsform", comment: ""))
        }
    }
}
