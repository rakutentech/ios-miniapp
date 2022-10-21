import SwiftUI
import MiniApp

struct MiniAppUrlView: View {

    @State var url: String = ""
    @State var currentUrl: String = ""
    @State var isMiniAppLoading: Bool = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                TextField("http://localhost:1337", text: $url)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)).padding(.horizontal, -10)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 13))

                Button(action: {
                    trackButtonTap(pageName: pageName, buttonTitle: "Load")
                    currentUrl = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: {
                        currentUrl = url
                    })
                }, label: {
                    Image(systemName: "goforward")
                })
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 15)

            if currentUrl.isEmpty {
                Spacer()
                Text("No MiniApp Loaded")
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                Spacer()
            } else {
                MiniAppSUIView(urlParams:
                    .init(
                        config: MiniAppConfig(
                            config: Config.current(),
                            messageDelegate: MiniAppViewMessageDelegator()
                        ),
                        type: .miniapp,
                        url: URL(string: url)!
                    )
                )
            }
        }
        .navigationTitle(pageName)
        .trackPage(pageName: pageName)
    }
}

extension MiniAppUrlView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.qa", comment: "")
	}
}

struct MiniAppUrlView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppUrlView()
    }
}
