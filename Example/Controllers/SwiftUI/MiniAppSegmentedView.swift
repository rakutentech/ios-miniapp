import SwiftUI
import MiniApp

struct MiniAppSegmentedView: View {

    @EnvironmentObject var store: MiniAppWidgetStore

    enum MiniAppSegment: String, CaseIterable {
        case one
        case two
        case three
    }

    @State var segment: MiniAppSegment = .one

    var body: some View {
        VStack {
            Picker("MiniApp", selection: $segment) {
                ForEach(MiniAppSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 20)

            TabView(selection: $segment) {
                ForEach(MiniAppSegment.allCases, id: \.self) { segment in
                    let miniAppId = getMiniAppId(segment: segment)
                    MiniAppSUView(params: MiniAppViewDefaultParams(
                        config: MiniAppNewConfig(
                            config: Config.current(),
                            messageInterface: MiniAppViewDelegator(miniAppId: miniAppId)
                        ),
                        type: .miniapp,
                        appId: miniAppId)
                    )
                    .tag(segment)
                }
            }
            .tabViewStyle(PageTabViewStyle())

            Spacer()
                .frame(height: 40)
        }
        .navigationTitle("Segmented")
        .navigationBarTitleDisplayMode(.inline)
    }

    func getMiniAppId(segment: MiniAppSegment) -> String {
        var miniAppId: String = ""
        switch segment {
        case .one:
            miniAppId = store.miniAppIdentifierTrippleFirst
        case .two:
            miniAppId = store.miniAppIdentifierTrippleSecond
        case .three:
            miniAppId = store.miniAppIdentifierTrippleThird
        }
        return miniAppId
    }
}

struct MiniAppSegmentedView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSegmentedView()
    }
}
