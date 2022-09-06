//
//  MiniAppSettingsGeneralView.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/09/05.
//

import SwiftUI

struct MiniAppSettingsGeneralView: View {
    
    @Binding var parameters: String
    
    var body: some View {
        Form {
            NavigationLink {
                QueryParametersView(parameters: $parameters)
            } label: {
                Text("Query Parameters")
            }

            NavigationLink {
                DeepLinkView()
            } label: {
                Text("Deep Links")
            }
        }
        .navigationTitle("General")
    }
}

struct MiniAppSettingsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsGeneralView(parameters: .constant("param1=test1"))
    }
}

extension MiniAppSettingsGeneralView {

    struct QueryParametersView: View {
        
        @Binding var parameters: String
        
        var body: some View {
            List {
                TextField("param1=value1&param2=value2", text: $parameters)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }

    }

    struct DeepLinkView: View {
        
        var body: some View {
            List {
                Text("DeepLink")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }

    }
}

