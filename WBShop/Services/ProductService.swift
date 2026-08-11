import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol ProductServicing {
    var products: [ProductPreview] { get }
    var errorMessage: String? { get }
    var favProducts: [ProductPreview] { get }
    var categoryProducts: [ProductPreview] { get }

    func fetchProducts() async
    func fetchFavProducts() async
    func fetchProductDetail(id: String) async -> Product?
    func fetchCategoryProducts(categoryId: String) async
}

@Observable
final class ProductService: ProductServicing {
    var products: [ProductPreview] = []
    var errorMessage: String?
    var favProducts: [ProductPreview] = []
    var categoryProducts: [ProductPreview] = []
    
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
                    if self.errorMessage != nil {
                        self.errorMessage = nil
                    }
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

    func fetchProductDetail(id: String) async -> Product? {
        do {
            let response = try await client.get_sol_products_sol__lcub_id_rcub_(
                path: .init(id: id)
            )
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    if self.errorMessage != nil {
                        self.errorMessage = nil
                    }
                }
                return body
                
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
            case .notFound(let error):
                let message = try? error.body.json.error
                await MainActor.run {
                    self.errorMessage = message ?? "Not found"
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
            }
        }
        return nil
        
    }
    
    func fetchFavProducts() async -> Void {
        await fetchProducts()
        self.favProducts = self.products.filter { product in
            product.isFavorite
        }
    }
    
    func fetchCategoryProducts(categoryId: String) async {
        do {
            let response = try await client.get_sol_products(
                query: .init(category: categoryId)
            )

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    self.categoryProducts = body.data
                    if self.errorMessage != nil {
                        self.errorMessage = nil
                    }
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
