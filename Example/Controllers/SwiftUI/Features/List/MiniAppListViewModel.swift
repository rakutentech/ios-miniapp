import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppListViewModel: ObservableObject {

	let store = MiniAppStore.shared

	@Published var type: MiniAppSettingsView.ListConfig
	@Published var state: ListState = .none
	@Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

	@Published var searchText: String = ""
	@Published var filteredIndexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

	var bag = Set<AnyCancellable>()

	init(type: MiniAppSettingsView.ListConfig) {
		self.type = type
		setupObservers()
		if store.miniAppSetupCompleted {
			load()
		} else {
			state = .awaitsSetup
		}
	}

	func setupObservers() {
		switch type {
		case .listI:
			store
				.$miniAppInfoList
				.receive(on: DispatchQueue.main)
				.sink { [weak self] list in
					guard let self = self, self.store.miniAppSetupCompleted else {
						self?.state = .awaitsSetup
						return
					}
					let indexedList = self.makeIndexed(infos: list)
					self.indexedMiniAppInfoList = indexedList
					self.filteredIndexedMiniAppInfoList = self.applyCurrentFilter(indexedList)
					self.state = .success
				}
				.store(in: &bag)
		case .listII:
			store
				.$miniAppInfoList2
				.receive(on: DispatchQueue.main)
				.sink { [weak self] list in
					guard let self = self, self.store.miniAppSetupCompleted else {
						self?.state = .awaitsSetup
						return
					}
					let indexedList = self.makeIndexed(infos: list)
					self.indexedMiniAppInfoList = self.makeIndexed(infos: list)
					self.filteredIndexedMiniAppInfoList = self.applyCurrentFilter(indexedList)
					self.state = .success
				}
				.store(in: &bag)
		}

		$searchText
			.receive(on: DispatchQueue.main)
			.sink { [weak self] text in
				guard let self = self else {
					return
				}
				self.updateFilter(text: text)
			}
			.store(in: &bag)
	}

	func makeIndexed(infos: [MiniAppInfo]) -> [String: [MiniAppInfo]] {
		let ids = Set<String>(infos.map({ $0.id }))
		var newList: [String: [MiniAppInfo]] = [:]
		for id in ids {
			newList[id] = infos.filter({ $0.id == id })
		}
		return newList
	}

	func checkSetup() {
		if !store.miniAppSetupCompleted {
			state = .awaitsSetup
		}
	}

	private func load() {
		state = .loading
		store.load(type: type)
	}

	var config: MiniAppSdkConfig {
		store.config.sdkConfig(list: type)
	}

	func applyCurrentFilter(_ targetList: [String: [MiniAppInfo]]) -> [String: [MiniAppInfo]] {
		guard !searchText.isEmpty else {
			return targetList
		}
		return targetList.filter({ $0.0.lowercased().contains(searchText) })
	}

	func updateFilter(text: String) {
		var searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !searchText.isEmpty else {
			filteredIndexedMiniAppInfoList = indexedMiniAppInfoList
			return
		}

		if searchText.starts(with: "miniappdemo://miniapp/dl/"), let searchTextUrl = URL(string: searchText) {
			let miniAppId = searchTextUrl.pathComponents[2]
			searchText = miniAppId
		}

		if isUUID(searchText), let identifierFound = indexedMiniAppInfoList[searchText] {
			filteredIndexedMiniAppInfoList = [searchText: identifierFound]
			return
		}

		if isUUID(searchText), let versionFound = indexedMiniAppInfoList.map({ $0.1 }).reduce([], +).first(where: { $0.version.versionId == searchText }) {
			filteredIndexedMiniAppInfoList = [versionFound.id: [versionFound]]
			return
		}

		filteredIndexedMiniAppInfoList = Dictionary(uniqueKeysWithValues: indexedMiniAppInfoList.map({ (key, value) in
			(key, value.filter({ $0.displayName?.lowercased().contains(searchText.lowercased()) ?? false }))
		}))
		.filter({ !$0.value.isEmpty })
	}

	func isUUID(_ text: String) -> Bool {
		let uuidRegex = #"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"#
		return text.range(of: uuidRegex, options: .regularExpression) != nil
	}
}

enum ListState {
	case none
	case awaitsSetup
	case loading
	case success
}
