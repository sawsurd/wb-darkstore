import SwiftUI
import Core

struct AppRootView: View {
    @StateObject private var router: Router = ServiceLocator.shared.resolve()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                        case .login: LoginView()
                        case .content: ContentView()
                    }
                }
        }
    }
}
