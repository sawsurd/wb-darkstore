import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class ProductService {
    var products: [ProductPreview] = []
    var errorMessage: String?
    
    private let client: APIProtocol
    
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
    
    func fetchProducts() async {
        do {
            let response = try await client.get_sol_products()
            
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    self.products = body.data
                    self.errorMessage = nil
                }
                
            case .badRequest(let error):
                let message = try? error.body.json.error
                await MainActor.run {
                    self.errorMessage = message ?? "Некорректный запрос"
                }
                
            case .unauthorized(let error):
                let message = try? error.body.json.error
                await MainActor.run {
                    self.errorMessage = message ?? "Требуется авторизация"
                }
                
            case .default(let statusCode, let error):
                let message = try? error.body.json.error
                await MainActor.run {
                    self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
            }
        }
    }
}
