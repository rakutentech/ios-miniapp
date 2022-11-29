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
                        email: contact.email ?? ""
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
                    onSave: {
                        if let index = index(for: contact) {
                            contacts[index] = contact
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
                }
                .font(.system(size: 13))
            }
            .padding(.vertical, 10)
        }
    }

    struct ContactFormView: View, ViewTrackable {

        @Binding var contactData: MAContact
        @Binding var isEditing: Bool
        @State private var isContactInfoValid: Bool = false

        var onSave: () -> Void

        var onClose: () -> Void

        var body: some View {
            List {
                TextField("Name", text: $contactData.name ?? "")
                TextField("Contact Id", text: $contactData.id)
                TextField("Email", text: $contactData.email ?? "")
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
                            onSave()
                        } else {
                            isContactInfoValid = true
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }
            .alert(isPresented: $isContactInfoValid) {
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
                    errorMessage += "Email id is invalid.\n"
                }
            } else {
                errorMessage += "Email id cannot be empty.\n"
            }

            errorMessage += "Please correct and try again."
            return errorMessage
        }

        func validateContactinfo() -> Bool {
            return (!(contactData.name ?? "").isValueEmpty() && !contactData.id.isValueEmpty() && (contactData.email ?? "").isValidEmail())
        }

        var pageName: String {
            return isEditing ? (NSLocalizedString("demo.app.rat.page.name.editcontactsform", comment: "")) : (NSLocalizedString("demo.app.rat.page.name.contactsform", comment: ""))
        }
    }
}
