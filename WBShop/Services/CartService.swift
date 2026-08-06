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
    var productsInCart: [CartProduct] { get }
    var cartQuantities: [String: Int] { get }
    func addProductToCart(id: String, productInfo: CartProduct?) async
    func removeProductFromCart(id: String) async
    func deleteProductFromCart(id: String) async
    func createOrder(paymentMethod: String, addressId: String) async
}

extension CartServicing {
    func addProductToCart(id: String) async {
        await addProductToCart(id: id, productInfo: nil)
    }
}

@Observable
final class CartService: CartServicing {
    private let client: APIProtocol
    private var errorMessage: String?
    private var isFetching = false
    
    public private(set) var cartQuantities: [String: Int] = [:]
    private var productDetails: [String: CartProduct] = [:]

    public var productsInCart: [CartProduct] {
        cartQuantities.compactMap { id, quantity in
            guard let details = productDetails[id], quantity > 0 else { return nil }
            return CartProduct(
                id: details.id,
                image: details.image,
                name: details.name,
                weight: details.weight,
                price: details.price,
                quantity: quantity,
                isAvailable: details.isAvailable
            )
        }
        .sorted { $0.id < $1.id }
    }

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

                var newQuantities: [String: Int] = [:]
                var newDetails: [String: CartProduct] = [:]

                for item in body.items {
                    let product = CartProduct(
                        id: item.value1.id,
                        image: item.value1.image,
                        name: item.value1.name,
                        weight: item.value1.weight,
                        price: item.value1.price,
                        quantity: item.value1.quantity,
                        isAvailable: item.value2.available
                    )
                    newQuantities[product.id] = product.quantity
                    newDetails[product.id] = product
                }

                if newQuantities != self.cartQuantities {
                    self.cartQuantities = newQuantities
                }
                self.productDetails = newDetails
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
    
    public func addProductToCart(id: String, productInfo: CartProduct? = nil) async {
        let previousQuantity = cartQuantities[id] ?? 0
        cartQuantities[id, default: 0] += 1

        if productDetails[id] == nil, let productInfo {
            productDetails[id] = productInfo
        }

        do {
            let response = try await client.post_sol_cart_sol_items(query: .init(id: id))

            switch response {
            case .ok:
                if self.errorMessage != nil {
                    self.errorMessage = nil
                }
                if productDetails[id] == nil {
                    await fetchProducts()
                }

            case .unauthorized(let error):
                rollbackAdd(id: id, to: previousQuantity)
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Требуется авторизация"

            case .notFound(let error):
                rollbackAdd(id: id, to: previousQuantity)
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Товар не найден"

            case .default(let statusCode, let error):
                rollbackAdd(id: id, to: previousQuantity)
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
            }
        } catch {
            rollbackAdd(id: id, to: previousQuantity)
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    private func rollbackAdd(id: String, to previousQuantity: Int) {
        if previousQuantity > 0 {
            cartQuantities[id] = previousQuantity
        } else {
            cartQuantities.removeValue(forKey: id)
        }
    }
    
    public func removeProductFromCart(id: String) async {
        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else { return }

        let newQuantity = currentQuantity - 1
        if newQuantity > 0 {
            cartQuantities[id] = newQuantity
        } else {
            cartQuantities.removeValue(forKey: id)
        }

        do {
            let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(
                path: .init(id: id)
            )

            switch response {
            case .ok:
                if self.errorMessage != nil {
                    self.errorMessage = nil
                }

            case .unauthorized(let error):
                cartQuantities[id] = currentQuantity
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Требуется авторизация"

            case .notFound(let error):
                cartQuantities[id] = currentQuantity
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Товар не найден"

            case .default(let statusCode, let error):
                cartQuantities[id] = currentQuantity
                let message = try? error.body.json.error
                self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
            }
        } catch {
            cartQuantities[id] = currentQuantity
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
    
    public func deleteProductFromCart(id: String) async {
        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else { return }
        cartQuantities.removeValue(forKey: id)

        for _ in 0..<currentQuantity {
            do {
                let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(
                    path: .init(id: id)
                )

                switch response {
                case .ok:
                    continue

                case .unauthorized(let error):
                    cartQuantities[id] = currentQuantity
                    let message = try? error.body.json.error
                    self.errorMessage = message ?? "Требуется авторизация"
                    return

                case .notFound:
                    continue

                case .default(let statusCode, let error):
                    cartQuantities[id] = currentQuantity
                    let message = try? error.body.json.error
                    self.errorMessage = message ?? "Ошибка сервера (\(statusCode))"
                    return
                }
            } catch {
                cartQuantities[id] = currentQuantity
                self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                return
            }
        }

        if self.errorMessage != nil {
            self.errorMessage = nil
        }
    }
}

extension CartServicing {
    var totalPrice: Int {
        productsInCart.reduce(0) { $0 + $1.price * $1.quantity }
    }
    
    var cartModel: CartModel {
        CartModel(from: productsInCart)
    }
}
