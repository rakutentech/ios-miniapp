import SwiftUI

struct MAAnalyticsInfoView: View {
    @State var analyticsData: String = NSLocalizedString("demo.app.analytics.info.noData", comment: "")
    var body: some View {
        ScrollView {
            VStack {
                Text(analyticsData).frame(maxWidth: .infinity)
            }
        }.padding()
            .navigationBarItems(trailing: Button("Clear") {
                if analyticsData != "" {
                    MAAnalyticsInfoLogger.deleteAnalyticsInfoLogs()
                    analyticsData = NSLocalizedString("demo.app.analytics.info.dataCleared", comment: "")
                }
            })
            .navigationBarTitle(NSLocalizedString("demo.app.rat.page.name.viewanalyticsinfo", comment: ""))
            .trackPage(pageName: pageName)
            .onAppear {
                analyticsData = MAAnalyticsInfoLogger.readAnalyticsInfoLogs()
            }
    }
}

extension MAAnalyticsInfoView: ViewTrackable {
    var pageName: String {
        return NSLocalizedString("demo.app.rat.page.name.viewanalyticsinfo", comment: "")
    }
}

struct MAAnalyticsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MAAnalyticsInfoView(analyticsData: "")
    }
}
