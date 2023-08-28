import SwiftUI
import MiniApp

struct MiniAppListRowCell: View {

    @State var iconUrl: URL?
    @State var displayName: String
    @State var miniAppId: String
    @State var versionTag: String
    @State var versionId: String
    @State var listType: ListType
    @State private var showingAlert = false
    @State private var alertDescription = "false"

    var body: some View {
        HStack {
            VStack {
                Spacer()
                if #available(iOS 15.0, *) {
                    AsyncImage(url: iconUrl, content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40, alignment: .center)
                            .contextMenu {
                                menuItems
                            }
                    }, placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray3))
                            .frame(width: 40, height: 40, alignment: .center)
                    })
                } else {
                    RemoteImageView(urlString: iconUrl?.absoluteString ?? "")
                        .frame(width: 60, height: 40, alignment: .center)
                        .contextMenu {
                            menuItems
                        }
                }
                Spacer()
            }

            VStack(spacing: 3) {
                HStack {
                    Text(displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(versionTag)
                        .font(.footnote)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(versionId)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                    Spacer()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Info"),
                    message: Text(alertDescription),
                    dismissButton: .default(Text("OK")))
            }
            .padding(10)
        }
    }

    var menuItems: some View {
        Group {
            Button("Download", action: downloadMiniAppInBackground)
            Button("Available already?", action: isMiniAppDownloadedAlready)
        }
    }

    func downloadMiniAppInBackground() {
        MiniApp.shared(with: ListConfiguration(listType: listType).sdkConfig).downloadMiniApp(appId: miniAppId, versionId: versionId) { result in
            switch result {
            case .success:
                print("Download Completed")
            case .failure(let error):
                print("Error downloading Miniapp:", error)
            }
        }
    }

    func isMiniAppDownloadedAlready() {
        if MiniApp.isMiniAppDownloadedAlready(appId: miniAppId, versionId: versionId) {
            showingAlert = true
            alertDescription = "MiniApp is available"
        } else {
            showingAlert = true
            alertDescription = "MiniApp is not downloaded"
        }
    }
}

struct MiniAppListRowCell_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListRowCell(
            displayName: "MiniApp Sample",
            miniAppId: "123",
            versionTag: "0.7.2",
            versionId: "abcdefgh-12345678-abcdefgh-12345678",
            listType: .listI
        )
    }
}
