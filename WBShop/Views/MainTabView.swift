import SwiftUI
import Core
import DSKit

enum MainTab {
    case catalog
    case favorites
    case cart
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .catalog
    @StateObject private var router: Router = ServiceLocator.shared.resolve()


    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Каталог",
                systemImage: "square.grid.2x2",
                value: MainTab.catalog) {
                ContentView()
            }

            Tab("Избранное",
                systemImage: "heart.fill",
                value: MainTab.favorites) {
                FavoritesView()
            }

            Tab("Корзина",
                systemImage: "cart",
                value: MainTab.cart) {
                CartView {
                    print()
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            if selectedTab == .catalog || selectedTab == .favorites {
                SearchBarButton() {
                    router.push(.search)
                }
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, 60)
            }
        }
    }
}
