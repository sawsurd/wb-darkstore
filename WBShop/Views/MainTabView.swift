import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Каталог", systemImage: "square.grid.2x2"){
                ContentView()
            }
            Tab("Корзина", systemImage: "cart") {
                CartView() {
                    print()
                }
            }
        }
    }
}
