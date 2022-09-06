import SwiftUI

struct MiniAppSettingsProfileView: View {
    
    @State var name: String = ""
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Spacer()
                    Image("Rakuten")
                        .frame(width: 150, height: 150, alignment: .center)
                        .background(Circle().fill(.white))
                        .background(Circle().stroke(.gray, lineWidth: 1))
                    Spacer()
                }

                Button {
                    
                } label: {
                    Text("Edit")
                }
                .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 15)
            
            VStack {
//                HStack {
//                    Text("Name")
//                    Spacer()
//                }
                TextField("Name", text: $name)
            }
            
        }
        .navigationTitle("Profile")
        .listStyle(.plain)
    }
}

struct MiniAppSettingsProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSettingsProfileView()
    }
}
