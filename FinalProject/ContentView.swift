import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
           
            MotivationsView()
                .tabItem {
                    Label("Motivations", systemImage: "heart.fill")
                }
                .tag(1)
            
            TodoView()
                .tabItem {
                    Label("To-Do", systemImage: "list.bullet.rectangle")
                }
                .tag(2)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .preferredColorScheme(.dark)
    }
}
