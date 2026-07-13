import SwiftUI

public enum Route: Hashable {
    case content
    case login
}

public protocol RouterProtocol: AnyObject {
    func push(_ route: Route)
    func pop()
    func popToRoot()
}

@available(iOS 16.0, *)
public final class Router: ObservableObject, RouterProtocol {
    @Published public var path = NavigationPath()

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    public func replace(with route: Route) {
        path = NavigationPath([route])
    }
}
