import SwiftUI

struct MiniAppSharePreviewView: View {

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
        .navigationTitle("Share Preview")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}

struct MiniAppSharePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSharePreviewView(viewModel: MiniAppWithTermsViewModel(miniAppId: "", sdkConfig: Config.current()))
    }
}