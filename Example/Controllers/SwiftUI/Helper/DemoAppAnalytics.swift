import Foundation
import MiniApp
import RAnalytics

internal enum DemoAppRATEventType: String, CaseIterable {
	case appear = "appear"
	case click = "click"
	case pageLoad = "pv"
}

internal enum DemoAppRATActionType: String, CaseIterable {
	case open
	case close
	case changeStatus
	case initial = "default"
}

internal enum DemoAppAnalyticsParameter: String, CaseIterable {
	case projectId = "project_id"
	case miniAppId = "id"
	case versionId = "version_id"
	case sdkVersion = "sdk_version"

	func name() -> String {
		return "mini_app_\(rawValue)"
	}
}

class DemoAppAnalytics {

	open class var sdkVersion: String? {
		Bundle.miniAppSDKBundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? MiniApp.version
	}

	internal class func sendAnalytics(
		eventType: DemoAppRATEventType? = .click,
		actionType: DemoAppRATActionType? = .open,
		pageName: String? = "",
		siteSection: String? = "",
		componentName: String? = "",
		elementType: String? = "",
		customParameters: (String, String)...
	) {
		let params = getAnalyticsInfo() + customParameters
		RATNotificationCenter.sendAnalytics(
			eventType: eventType ?? .click,
			actionType: actionType ?? .open,
			pageName: pageName ?? "",
			siteSection: siteSection ?? "",
			targetElement: getTargetElementString(
				component: componentName ?? "",
				element: elementType ?? "",
				action: actionType ?? .initial
			),
			parameters: params
		)
	}

	internal class func getAnalyticsInfo() -> [(String, String)] {
		var result = [(String, String)]()
		if let projectId = Config.string(.listI, key: .projectId) {
			result.append((DemoAppAnalyticsParameter.projectId.name(), projectId))
		}
		if let version = sdkVersion {
			result.append((DemoAppAnalyticsParameter.sdkVersion.name(), version))
		}
		return result
	}

	internal class func getTargetElementString(component: String, element: String, action: DemoAppRATActionType) -> String {
		return component + "-" + element + "." + action.rawValue
	}
}

internal class RATNotificationCenter {
	static func sendAnalytics(
		eventType: DemoAppRATEventType,
		actionType: DemoAppRATActionType,
		pageName: String,
		siteSection: String,
		targetElement: String,
		parameters customData: [(String, String)]? = nil
	) {
		RAnalyticsRATTracker.shared().event(
			withEventType: eventType.rawValue,
			parameters: [
				"etype": eventType.rawValue,
				"actype": actionType.rawValue,
				"pgn": pageName,
				"target_ele": targetElement,
				"ssc": siteSection
			]
		)
		.track()
	}
}
