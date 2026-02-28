import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.12, blue: 0.2).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) 
                    .padding(.top, 40)
                
                Text("DailyBoost")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Start your day positive.")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button(action: {
                    selectedTab = 2
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(12)
                }
                
                Spacer()
            }
        }
    }
}
