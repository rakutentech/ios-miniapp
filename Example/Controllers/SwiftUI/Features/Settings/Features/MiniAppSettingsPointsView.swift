import SwiftUI

struct MiniAppSettingsPointsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: MiniAppSettingsViewModel

    @State var pointsStandard: String = "10"
    @State var pointsTerm: String = "20"
    @State var pointsCash: String = "30"
    @State private var alertMessage: MiniAppAlertMessage?

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Points (Standard)")
                    .font(.system(size: 12, weight: .medium))
                TextField("Enter points here", text: $pointsStandard)
            }
            .padding(.vertical, 10)

            VStack(alignment: .leading) {
                Text("Points (Term)")
                    .font(.system(size: 12, weight: .medium))
                TextField("Enter points here", text: $pointsTerm)
            }
            .padding(.vertical, 10)

            VStack(alignment: .leading) {
                Text("Points (Cash)")
                    .font(.system(size: 12, weight: .medium))
                TextField("Enter points here", text: $pointsCash)
            }
            .padding(.vertical, 10)
        }
        .navigationTitle("Points")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    guard
                        let spoints = Int(pointsStandard),
                        let tpoints = Int(pointsTerm),
                        let cpoints = Int(pointsCash)
                    else {
                        alertMessage = MiniAppAlertMessage(title: "Error", message: "Something went wrong")
                        return
                    }
                    viewModel.savePoints(model: UserPointsModel(standardPoints: spoints, termPoints: tpoints, cashPoints: cpoints))
                    dismiss.callAsFunction()
                } label: {
                    Text("Save")
                }
                .alert(item: $alertMessage) { alert in
                    Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("Ok")))
                }
            }
        }
        .onAppear {
            if let points = getUserPoints() {
                pointsStandard = "\(points.standardPoints ?? 0)"
                pointsTerm = "\(points.termPoints ?? 0)"
                pointsCash = "\(points.cashPoints ?? 0)"
            } else {
                pointsStandard = "0"
                pointsTerm = "0"
                pointsCash = "0"
            }
        }
    }
}

struct MiniAppSettingsPointsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsPointsView(viewModel: MiniAppSettingsViewModel())
    }
}
