import SwiftUI

@main
struct NeumorphicToggleApp: App {
    @State var isOn = true
    
    var body: some Scene {
        WindowGroup {
            NeumorphicToggle(isOn: $isOn)
                .frame(width: 320)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.33))
                .ignoresSafeArea()
        }
    }
}
