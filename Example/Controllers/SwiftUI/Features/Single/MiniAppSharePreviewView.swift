import SwiftUI

struct MiniAppSharePreviewView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: MiniAppWithTermsViewModel

    @State var text: String = ""
    @State var url: URL?

    var body: some View {
        VStack {
            if let url = url {
                VStack(spacing: 20) {
                    Text(text)
                        .multilineTextAlignment(.center)
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: url, content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                        }, placeholder: {
                            Color.gray
                        })
                    } else {
                        RemoteImageView(urlString: url.absoluteString)
                            .frame(width: 60, height: 40, alignment: .center)
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .navigationTitle(pageName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                CloseButton {
                    trackButtonTap(pageName: pageName, buttonTitle: "Back")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        })
        .onAppear {
            viewModel.getInfo { result in
                switch result {
                case let .success(info):
                    text = info.promotionalText ?? ""
                    if let imageUrlString = info.promotionalImageUrl, let imageUrl = URL(string: imageUrlString) {
                        url = imageUrl
                    }
                case let .failure(error):
                    text = error.localizedDescription
                }
            }
        }
        .trackPage(pageName: pageName)
    }
}

extension MiniAppSharePreviewView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.share.preview", comment: "")
	}
}

struct MiniAppSharePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSharePreviewView(viewModel: MiniAppWithTermsViewModel(miniAppId: "", sdkConfig: Config.current()))
    }
}
