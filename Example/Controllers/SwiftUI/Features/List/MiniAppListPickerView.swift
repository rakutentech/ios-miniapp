import SwiftUI

struct MiniAppListPickerView: View {

    @ObservedObject var store: MiniAppStore

    @Binding var isPresented: Bool
    @Binding var miniAppId: String
    @Binding var version: String

    var body: some View {
        NavigationView {
            List {
                ForEach(store.indexedMiniAppInfoList.keys.sorted(), id: \.self) { (key) in
                    Section(header: Text(key)) {
                        ForEach(store.indexedMiniAppInfoList[key]!, id: \.version) { (info) in
                            HStack {
                                VStack {
                                    Spacer()
                                    if #available(iOS 15.0, *) {
                                        AsyncImage(url: info.icon, content: { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40, alignment: .center)
                                        }, placeholder: {
                                            Circle()
                                                .frame(width: 40, height: 40, alignment: .center)
                                        })
                                    } else {
                                        RemoteImageView(urlString: info.icon.absoluteString)
                                            .frame(width: 60, height: 40, alignment: .center)
                                    }
                                    Spacer()
                                }

                                VStack(spacing: 3) {
                                    HStack {
                                        Text((info.displayName ?? ""))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(info.version.versionTag)
                                            .font(.footnote)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(info.version.versionId)
                                            .font(.footnote)
                                            .foregroundColor(Color(.secondaryLabel))
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                                .padding(10)
                                .onTapGesture {
                                    miniAppId = info.id
                                    version = info.version.versionId
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("MiniApp List")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: {
            self.store.load()
        })
    }
}

struct MiniAppListPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppListPickerView(
            store: MiniAppStore.empty(),
            isPresented: .constant(false),
            miniAppId: .constant(""),
            version: .constant("")
        )
    }
}
