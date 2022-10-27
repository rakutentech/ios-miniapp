enum AccessibilityIdentifiers: String {
    case tabBarListI = "tabbar.list.i"
    case tabBarListII = "tabbar.list.ii"
    case tabBarFeatures = "tabbar.features"
    case tabBarSettings = "tabbar.settings"
    

  var identifier: String {
    return "miniapp.demo." + rawValue
  }
}
