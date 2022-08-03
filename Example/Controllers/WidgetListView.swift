//
//  WidgetListView.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/08/02.
//

import SwiftUI
import MiniApp

struct WidgetListView: View {
    
    let delegator = MiniAppMessageDelegator(miniAppId: "404e46b4-263d-4768-b2ec-8a423224bead")
    
    var miniAppIds: [String]
    
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
                Button(action: {}, label: {
                    Image(systemName: "xmark")
                })
            })
        }
    }
}

struct WidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetListView(miniAppIds: ["404e46b4-263d-4768-b2ec-8a423224bead"])
    }
}
