import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol ProductServicing {
    var products: [ProductPreview] { get }
    var errorMessage: String? { get }
    var favProducts: [ProductPreview] { get }
    var categoryProducts: [ProductPreview] { get }
    var favoriteIds: Set<String> { get }

    func fetchProducts() async
    func fetchFavProducts() async
    func fetchProductDetail(id: String) async -> Product?
    func fetchCategoryProducts(categoryId: String) async
    func toggleFavorite(id: String) async
    func isFavorite(id: String) -> Bool
}

@Observable
final class ProductService: ProductServicing {
    var products: [ProductPreview] = []
    var errorMessage: String?
    var favProducts: [ProductPreview] = []
    var categoryProducts: [ProductPreview] = []
    var favoriteIds: Set<String> = []
    
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
    
    func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    func fetchProducts() async {
        do {
            let response = try await client.get_sol_products()
            
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    self.products = body.data
                    
                    self.favoriteIds = Set(
                        body.data
                            .filter(\.isFavorite)
                            .map(\.id)
                    )
                    
                    self.favProducts = body.data.filter {
                        self.favoriteIds.contains($0.id)
                    }
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
    
    func toggleFavorite(id: String) async {
        let wasFavorite = favoriteIds.contains(id)
        let newValue = !wasFavorite
        
        await MainActor.run {
            applyFavoriteChange(id: id, isFavorite: newValue)
        }
        
        do {
            if newValue {
                let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: id))
                
                switch response {
                case .ok:
                    break
                case .unauthorized(let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Требуется авторизация"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                case .notFound(let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Товар не найден"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                case .default(let statusCode, let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                }
            } else {
                let response = try await client.delete_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: id))
                
                switch response {
                case .ok:
                    break
                case .unauthorized(let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Требуется авторизация"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                case .notFound(let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Товар не найден"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                case .default(let statusCode, let error):
                    let message = try? error.body.json.error
                    await MainActor.run {
                        self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                        self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                self.applyFavoriteChange(id: id, isFavorite: wasFavorite)
            }
        }
    }
    
    private func applyFavoriteChange(id: String, isFavorite: Bool) {
        if isFavorite {
            favoriteIds.insert(id)
        } else {
            favoriteIds.remove(id)
        }
        
        if isFavorite {
            if let preview = (products.first { $0.id == id } ?? categoryProducts.first { $0.id == id }),
               !favProducts.contains(where: { $0.id == id }) {
                favProducts.append(preview)
            }
        } else {
            favProducts.removeAll { $0.id == id }
        }
    }
}
