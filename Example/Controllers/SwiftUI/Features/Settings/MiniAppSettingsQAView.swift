//
//  MiniAppSettingsQAView.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/09/06.
//

import SwiftUI

struct MiniAppSettingsQAView: View {
    
    @State private var accessTokenErrorBehavior: ErrorBehavior = .normal
    @State private var accessTokenErrorString = ""
    var body: some View {
        Form {
            Section(header: Text("Access Token Error Behavior")) {
                VStack {
                    Picker("Error Behavior", selection: $accessTokenErrorBehavior) {
                        ForEach(ErrorBehavior.allCases, id: \.self) { behavior in
                            Text(behavior.name).tag(behavior)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Custom error message", text: $accessTokenErrorString)
                    .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 15)
            }
            
            Section(header: Text("Secure Storage")) {
                VStack {
                    Button {
                        
                    } label: {
                        Text("Wipe Secure Storages")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    HStack {
                        TextField("MiniApp ID", text: $accessTokenErrorString)
                            .frame(height: 50)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    
                    HStack {
                        TextField("Max Storage Limit (Bytes)", text: $accessTokenErrorString)
                            .frame(height: 50)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 15)
            }
        }
    }
}

struct MiniAppSettingsQAView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsQAView()
    }
}

extension MiniAppSettingsQAView {
    enum ErrorBehavior: CaseIterable {
        case normal
        case authorization
        case unknown
        
        var name: String {
            switch self {
            case .normal:
                return "Normal"
            case .authorization:
                return "Authorization"
            case .unknown:
                return "Unknown"
            }
        }
    }
}
