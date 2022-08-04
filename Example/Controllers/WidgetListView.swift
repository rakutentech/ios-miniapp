//
//  WidgetListView.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/08/02.
//

import SwiftUI
import MiniApp
import Combine

struct WidgetListView: View {

    let delegator = MiniAppWidgetsDelegator()
    
    var miniAppIds: [String]
    
    let dismiss = PassthroughSubject<Void, Error>()
    
    var body: some View {
        List {
            ForEach(miniAppIds, id: \.self) { id in
                MiniAppSUView(
                    config: MiniAppNewConfig(
                        config: Config.current(),
                        adsDisplayer: nil,
                        messageInterface: delegator
                    ),
                    type: .widget,
                    appId: id
                )
                .frame(height: 250)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Widgets")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: {
                    dismiss.send(())
                }, label: {
                    Image(systemName: "xmark")
                })
            })
        }
    }
}

struct WidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetListView(miniAppIds: [])
    }
}

class MiniAppWidgetsDelegator: MiniAppMessageDelegate {
    
    var miniAppId: String
    
    init(miniAppId: String = "") {
        self.miniAppId = miniAppId
    }
    
    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success("TestNew"))
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        //
    }

    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        //
    }

    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        //
    }

    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
        //
    }
}
