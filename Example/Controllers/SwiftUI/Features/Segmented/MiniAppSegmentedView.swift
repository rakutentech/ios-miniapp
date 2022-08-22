import SwiftUI
import MiniApp

struct MiniAppSegmentedView: View {
    
    @StateObject var viewModel = MiniAppSegmentedViewModel()

    @State var segment: MiniAppSegmentedViewModel.MiniAppSegment = .one
    
    var body: some View {
        VStack {
            Picker("MiniApp", selection: $segment) {
                ForEach(MiniAppSegmentedViewModel.MiniAppSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 20)

            TabView(selection: $segment) {
                ForEach(MiniAppSegmentedViewModel.MiniAppSegment.allCases, id: \.self) { segment in
                    MiniAppWithTermsView(viewModel: viewModel.termsViewModel(segment: segment))
                    .tag(segment)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Spacer()
                .frame(height: 40)
        }
        .navigationTitle("Segmented")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MiniAppSegmentedView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSegmentedView()
    }
}
