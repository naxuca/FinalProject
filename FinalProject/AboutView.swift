import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.12, blue: 0.2).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("About").font(.largeTitle).bold()
                Text("Welcome to DailyBoost! What is the purpose of that app? Our goal is to help ypu achive little goals day by day. This way your life would be easier and more productive. beside of that, you will not forget anything. So enjoy the process! ")
                Text("Created by Demetre Nakhutsrishvili in 2026.").font(.headline)
                Spacer()
            }
            .padding()
        }
    }
}
