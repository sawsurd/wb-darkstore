import Foundation
import OpenAPIURLSession

protocol CategoryServicing {
    func fetchCategories() async
    var categories: [Category] { get }
}

@Observable
final class CategoryService: CategoryServicing {
    private let client: APIProtocol
    private var errorMessage: String?
    public private(set) var categories: [Category] = []
    private var isFetching = false

    init() {
        do {
            client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport(),
                middlewares: [AuthMiddleware()]
            )
        } catch {
            fatalError("Не удалось создать URL сервера: \(error)")
        }
    }

    public func fetchCategories() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        do {
            let response = try await client.get_sol_categories()

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                self.categories = body
                if self.errorMessage != nil {
                    self.errorMessage = nil
                }

            case .unauthorized(let error):
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Требуется авторизация"

            case .default(let statusCode, let error):
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
            }
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }
}
