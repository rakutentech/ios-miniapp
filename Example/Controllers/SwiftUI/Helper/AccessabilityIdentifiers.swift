enum AccessibilityIdentifiers: String {
    case tabBarListI = "tabbar.list.i"
    case tabBarListII = "tabbar.list.ii"
    case tabBarFeatures = "tabbar.features"
    case tabBarSettings = "tabbar.settings"
    case settingsRasListI = "settings.ras.list.i"
    case settingsRasListII = "settings.ras.list.ii"
    case settingsRasEnvironment = "settings.ras.environment"
    case settingsRasMode = "settings.ras.mode"
    case settingsHostId = "settings.host.id"
    case settingsSubscriptionKey = "settings.subscription.key"
    case listSearchIcon = "list.search.icon"
    case listSearchTextField = "list.search.textfield"

    var identifier: String {
        return "miniapp.demo." + rawValue
    }
}
