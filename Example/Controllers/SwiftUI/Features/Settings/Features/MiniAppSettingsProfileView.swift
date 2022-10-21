import SwiftUI
import PhotosUI

struct MiniAppSettingsProfileView: View {

    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State private var name: String = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        List {
            VStack {

                HStack {
                    Spacer()
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .cornerRadius(75)
                            .frame(width: 150, height: 150, alignment: .center)
                            .background(Circle().stroke(.gray, lineWidth: 1))
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                    } else {
                        Image("Rakuten")
                            .resizable()
                            .cornerRadius(75)
                            .frame(width: 150, height: 150, alignment: .center)
                            .background(Circle().stroke(.gray, lineWidth: 1))
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                    }
                    Spacer()
                }

                HStack {
                    Spacer()
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Edit")
                        showImagePicker = true
                    } label: {
                        Text("Edit")
                    }
                    .foregroundColor(.red)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
                    }

                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Clear")
                        image = nil
                    } label: {
                        Text("Clear")
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 15)

            VStack {
                TextField("Name", text: $name)
            }
        }
        .navigationTitle(pageName)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Save")
                    if viewModel.setUserDetails(name: name, imageUrl: image?.dataURI()) {
                        alertMessage = MiniAppAlertMessage(title: "Success", message: "Profile saved successfully")
                    } else {
                        alertMessage = MiniAppAlertMessage(title: "Error", message: "Profile failed to save")
                    }
                } label: {
                    Text("Save")
                }
                .alert(item: $alertMessage) { message in
                    Alert(
                        title: Text(message.title),
                        message: Text(message.message),
                        dismissButton: .default(Text("Ok"))
                    )
                }
            }
        }
        .onAppear {
            if let userDetails = viewModel.getUserDetails() {
                name = userDetails.displayName ?? ""
                image = userDetails.profileImageURI?.convertBase64ToImage()
            }
        }
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSettingsProfileView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.profile", comment: "")
	}
}

struct MiniAppSettingsProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsProfileView(viewModel: MiniAppSettingsViewModel())
    }
}
