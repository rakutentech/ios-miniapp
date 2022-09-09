//
//  MiniAppSettingsQAView.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/09/06.
//

import SwiftUI
import MiniApp

struct MiniAppSettingsQAView: View {
    
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State private var miniAppWipeAppId = ""
    @State private var miniAppMaxStorageSize = ""
    
    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        Form {

            Section(header: Text("Secure Storage")) {
                VStack(spacing: 10) {
                    Button {
                        viewModel.clearSecureStorages()
                        alertMessage = MiniAppAlertMessage(title: "Success", message: "All stores were wiped successfully!")
                    } label: {
                        Text("Wipe Secure Storages")
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    HStack {
                        TextField("MiniApp ID", text: $miniAppWipeAppId)
                            .frame(height: 50)
                            .textFieldStyle(MiniAppTextFieldStyle())
                            .font(.system(size: 13))
                        Button {
                            viewModel.clearSecureStorage(appId: miniAppWipeAppId)
                            alertMessage = MiniAppAlertMessage(title: "Success", message: "MiniApp Storage cleared!")
                        } label: {
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                        .disabled(miniAppWipeAppId.isEmpty)
                    }
                    
                    HStack {
                        TextField("Max Storage Limit (Bytes)", text: $miniAppMaxStorageSize)
                            .frame(height: 50)
                            .textFieldStyle(MiniAppTextFieldStyle())
                            .font(.system(size: 13))
                        Button {
                            switch viewModel.setSecureStorageLimit(maxSize: miniAppMaxStorageSize) {
                            case let .success(formattedString):
                                miniAppMaxStorageSize = formattedString
                                alertMessage = MiniAppAlertMessage(title: "Success", message: "Saved Max Storage Size Limit to \(formattedString) bytes.")
                            case let .failure(error):
                                alertMessage = MiniAppAlertMessage(title: error.title, message: error.message)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .foregroundColor(.red)
                        .disabled(miniAppMaxStorageSize.isEmpty)
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 15)
            }
        }
        .navigationTitle("QA")
        .alert(item: $alertMessage) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            miniAppMaxStorageSize = viewModel.getSecureStorageMaxSize()
        }
    }
}

struct MiniAppSettingsQAView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsQAView(viewModel: MiniAppSettingsViewModel())
    }
}
