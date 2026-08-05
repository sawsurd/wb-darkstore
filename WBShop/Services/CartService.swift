import Foundation
import OpenAPIURLSession

struct CartProduct: Identifiable, Hashable {
    let id: String
    let image: String
    let name: String
    let weight: Int
    let price: Int
    let quantity: Int
    let isAvailable: Bool
}

protocol CartServicing {
    func fetchProducts() async
    var productsInCart: [CartProduct] { get set }
    func addProductToCart(id: String) async
    func removeProductFromCart(id: String) async
    func createOrder(paymentMethod: String, addressId: String) async
}

@Observable
final class CartService: CartServicing {
    private let client: APIProtocol
    private var errorMessage: String?
    public var productsInCart: [CartProduct] = []
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
    
    public func fetchProducts() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }
        
        do {
            let response = try await client.get_sol_cart()

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json

                let products = body.items.map { item -> CartProduct in
                    CartProduct(
                        id: item.value1.id,
                        image: item.value1.image,
                        name: item.value1.name,
                        weight: item.value1.weight,
                        price: item.value1.price,
                        quantity: item.value1.quantity,
                        isAvailable: item.value2.available
                    )
                }.sorted { $0.id < $1.id }
                
                if products != self.productsInCart {
                    self.productsInCart = products
                }
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
    
    public func addProductToCart(id: String) async {
        do {
            let response = try await client.post_sol_cart_sol_items(
                query: .init(id: id)
            )
            
            switch response {
                case .ok(let okResponse):
                    _ = try okResponse.body.json
                    if self.errorMessage != nil {
                        self.errorMessage = nil
                    }
                    await fetchProducts()

                case .unauthorized(let error):
                    let message = try? error.body.json.error
                    self.errorMessage = message ?? "Требуется авторизация"

                case .notFound(let error):
                    let message = try? error.body.json.error
                    self.errorMessage = message ?? "Товар не найден"

                case .default(let statusCode, let error):
                    let message = try? error.body.json.error
                    self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                }
            } catch {
                self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
            }
    }
    
    public func removeProductFromCart(id: String) async {
        do {
            let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(
                path: .init(id: id)
            )

            switch response {
            case .ok(let okResponse):
                _ = try okResponse.body.json
                if self.errorMessage != nil {
                    self.errorMessage = nil
                }
                await fetchProducts()

            case .unauthorized(let error):
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Требуется авторизация"

            case .notFound(let error):
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Товар не найден"

            case .default(let statusCode, let error):
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
            }
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }
    
    public func createOrder(paymentMethod: String, addressId: String) async {
        do {
            let response = try await client.post_sol_orders(
                body: .json(
                    .init(
                        paymentMethod: paymentMethod,
                        addressID: addressId
                    )
                )
            )
            switch response {
            case .ok(_):
                if self.errorMessage != nil {
                    self.errorMessage = nil
                }
                print("ok")
                await fetchProducts()
                
            case .default(let statusCode, let error):
                let message = try? error.body.json.error
                print("default")
                self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                
            case .badRequest(let error):
                let message = try? error.body.json.error
                print("bad req")
                self.errorMessage = message ?? "Ошибка запроса"
                
            case .unauthorized(let error):
                print("401")
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Требуется авторизация"
            }
        } catch {
            print(error.localizedDescription)
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }
}

extension CartServicing {
    var totalPrice: Int {
        productsInCart.reduce(0) { $0 + $1.price * $1.quantity }
    }
}
