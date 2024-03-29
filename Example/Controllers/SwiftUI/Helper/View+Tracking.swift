import SwiftUI
import MiniApp

protocol ViewTrackable {
	var pageName: String {get}
}

struct PageTrackingModifier: ViewModifier {

    var pageName: String?
    var siteSection: String?

    func body(content: Content) -> some View {
        let siteSection = !(siteSection?.isEmpty ?? true) ? siteSection : pageName
        content
            .onAppear {
                #if !DEBUG
                DemoAppAnalytics.sendAnalytics(
                    eventType: .pageLoad,
                    pageName: pageName,
                    siteSection: siteSection,
                    componentName: pageName,
                    elementType: "View"
                )
                #else
                print("track page appear: \(pageName ?? "-"), \(siteSection ?? "-"), View")
                #endif
            }
            .onDisappear {
                #if !DEBUG
                DemoAppAnalytics.sendAnalytics(
                    eventType: .click,
                    actionType: .close,
                    pageName: pageName,
                    siteSection: siteSection,
                    componentName: "Back",
                    elementType: "View"
                )
                #else
                print("track page disappear: \(pageName ?? "-"), \(siteSection ?? "-"), View")
                #endif
            }
    }
}

struct CellTrackingModifier: ViewModifier {

    var pageName: String?
    var siteSection: String?
    var cellTitle: String?

    func body(content: Content) -> some View {
        content
            .onAppear {
                #if !DEBUG
                DemoAppAnalytics.sendAnalytics(
                    eventType: .appear,
                    actionType: .initial,
                    pageName: pageName,
                    siteSection: siteSection,
                    componentName: cellTitle,
                    elementType: "Cell"
                )
                #else
                print("track cell appear: \(pageName ?? "-"), \(siteSection ?? "-"), \(cellTitle ?? "-"), Cell")
                #endif
            }
    }
}

struct ButtonTapTrackingModifier: ViewModifier {

    var pageName: String?
    var siteSection: String?
    var buttonTitle: String?

    func body(content: Content) -> some View {
        content
            .onAppear {
                #if !DEBUG
                DemoAppAnalytics.sendAnalytics(
                    eventType: .click,
                    actionType: .open,
                    pageName: pageName,
                    siteSection: siteSection,
                    componentName: buttonTitle,
                    elementType: "Button"
                )
                #else
                print("track button tap: \(pageName ?? "-"), \(siteSection ?? "-"), \(buttonTitle ?? "-"), Button")
                #endif
            }
    }
}

extension View {
    func trackPage(pageName: String? = nil, siteSection: String? = nil) -> some View {
        modifier(PageTrackingModifier(pageName: pageName, siteSection: siteSection))
    }
	func trackPage(localizedPageName: String? = nil, siteSection: String? = nil) -> some View {
		modifier(PageTrackingModifier(pageName: NSLocalizedString(localizedPageName ?? "", comment: ""), siteSection: siteSection))
	}
    func trackCell(pageName: String? = nil, siteSection: String? = nil, cellTitle: String?) -> some View {
        modifier(CellTrackingModifier(pageName: pageName, siteSection: siteSection, cellTitle: cellTitle))
    }
    func trackButtonTap(pageName: String? = nil, siteSection: String? = nil, buttonTitle: String?) {
        #if !DEBUG
        DemoAppAnalytics.sendAnalytics(
            eventType: .click,
            actionType: .open,
            pageName: pageName,
            siteSection: siteSection,
            componentName: buttonTitle,
            elementType: "Button"
        )
        #else
        print("track button tap: \(pageName ?? "-"), \(siteSection ?? "-"), \(buttonTitle ?? "-"), Button")
        #endif
    }
	func trackToggleTap(pageName: String? = nil, siteSection: String? = nil, toggleTitle: String?, isOn: Bool = false) {
		#if !DEBUG
		DemoAppAnalytics.sendAnalytics(
			eventType: .click,
			actionType: .open,
			pageName: pageName,
			siteSection: siteSection,
			componentName: toggleTitle,
			elementType: "Toggle"
		)
		#else
		print("track button tap: \(pageName ?? "-"), \(siteSection ?? "-"), \(toggleTitle ?? "-"), Toggle")
		#endif
	}
    func trackSegmentedTap(pageName: String? = nil, siteSection: String? = nil, segmentTitle: String?) {
        #if !DEBUG
        DemoAppAnalytics.sendAnalytics(
            eventType: .click,
            actionType: .changeStatus,
            pageName: pageName,
            siteSection: siteSection,
            componentName: segmentTitle,
            elementType: "Segmented"
        )
        #else
        print("track segmented tap: \(pageName ?? "-"), \(siteSection ?? "-"), \(segmentTitle ?? "-"), Segmented")
        #endif
    }
}

extension Int: Identifiable {
	public var id: Self { self }
}
