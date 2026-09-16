import Foundation
import OpenAPIURLSession
import SwiftData

actor CartStore {
    struct Snapshot: Sendable {
        let products: [CartProduct]
        let errorMessage: String?
    }

    private enum DeleteItemOutcome: Sendable {
        case success
        case failure(String)
    }

    private let client: APIProtocol
    private let persistence: CartPersistence
    private var isFetching = false
    private var didLoadLocalCache = false

    private var cartQuantities: [String: Int] = [:]
    private var productDetails: [String: CartProduct] = [:]

    private var productsInCart: [CartProduct] {
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

    init(modelContainer: ModelContainer) {
        self.persistence = CartPersistence(modelContainer: modelContainer)

        do {
            client = try Client(
                serverURL: Servers.Server1.url(),
                transport: URLSessionTransport(),
                middlewares: [AuthMiddleware()]
            )
        } catch {
            fatalError("Не удалось создать URL сервера: \(error)")
        }
    }

    private func snapshot(errorMessage: String? = nil) -> Snapshot {
        Snapshot(products: productsInCart, errorMessage: errorMessage)
    }

    private func ensureLocalCacheLoaded() async {
        guard !didLoadLocalCache else { return }
        didLoadLocalCache = true

        let loaded = await persistence.loadCart()
        cartQuantities = loaded.quantities
        productDetails = loaded.details
    }

    private func restoreQuantity(id: String, to quantity: Int) async {
        if quantity > 0 {
            cartQuantities[id] = quantity
        } else {
            cartQuantities.removeValue(forKey: id)
        }
        await persistence.saveCart(productsInCart)
    }

    func currentSnapshot() async -> Snapshot {
        await ensureLocalCacheLoaded()
        return snapshot()
    }

    func fetchProducts() async -> Snapshot {
        await ensureLocalCacheLoaded()

        guard !isFetching else {
            return snapshot()
        }
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

                cartQuantities = newQuantities
                productDetails = newDetails
                await persistence.saveCart(productsInCart)
                return snapshot()

            case .unauthorized(let error):
                return snapshot(errorMessage: error.errorMessage ?? "Требуется авторизация")

            case .default(let statusCode, let error):
                return snapshot(errorMessage: error.errorMessage ?? "Ошибка сервера (\(statusCode))")
            }
        } catch {
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func addProductToCart(id: String, productInfo: CartProduct?) async -> Snapshot {
        await ensureLocalCacheLoaded()

        let previousQuantity = cartQuantities[id] ?? 0
        cartQuantities[id, default: 0] += 1

        if productDetails[id] == nil, let productInfo {
            productDetails[id] = productInfo
        }

        await persistence.saveCart(productsInCart)

        do {
            let response = try await client.post_sol_cart_sol_items(query: .init(id: id))

            switch response {
            case .ok:
                if productDetails[id] == nil {
                    return await fetchProducts()
                }
                return snapshot()

            case .unauthorized(let error):
                await restoreQuantity(id: id, to: previousQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Требуется авторизация")

            case .notFound(let error):
                await restoreQuantity(id: id, to: previousQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Товар не найден")

            case .default(let statusCode, let error):
                await restoreQuantity(id: id, to: previousQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Ошибка сервера (\(statusCode))")
            }
        } catch {
            await restoreQuantity(id: id, to: previousQuantity)
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func removeProductFromCart(id: String) async -> Snapshot {
        await ensureLocalCacheLoaded()

        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else {
            return snapshot()
        }

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
                await persistence.saveCart(productsInCart)
                return snapshot()

            case .unauthorized(let error):
                await restoreQuantity(id: id, to: currentQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Требуется авторизация")

            case .notFound(let error):
                await restoreQuantity(id: id, to: currentQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Товар не найден")

            case .default(let statusCode, let error):
                await restoreQuantity(id: id, to: currentQuantity)
                return snapshot(errorMessage: error.errorMessage ?? "Ошибка сервера (\(statusCode))")
            }
        } catch {
            await restoreQuantity(id: id, to: currentQuantity)
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func deleteProductFromCart(id: String) async -> Snapshot {
        await ensureLocalCacheLoaded()

        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else {
            return snapshot()
        }
        cartQuantities.removeValue(forKey: id)

        let client = self.client

        let outcomes = await withTaskGroup(of: DeleteItemOutcome.self) { group in
            for _ in 0..<currentQuantity {
                group.addTask {
                    do {
                        let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(
                            path: .init(id: id)
                        )

                        switch response {
                        case .ok, .notFound:
                            return .success

                        case .unauthorized(let error):
                            return .failure(error.errorMessage ?? "Требуется авторизация")

                        case .default(let statusCode, let error):
                            return .failure(error.errorMessage ?? "Ошибка сервера (\(statusCode))")
                        }
                    } catch {
                        return .failure("Ошибка сети: \(error.localizedDescription)")
                    }
                }
            }

            var collected: [DeleteItemOutcome] = []
            collected.reserveCapacity(currentQuantity)
            for await outcome in group {
                collected.append(outcome)
            }
            return collected
        }

        let failures = outcomes.compactMap { outcome -> String? in
            if case .failure(let message) = outcome { return message }
            return nil
        }
        let succeededCount = outcomes.count - failures.count
        let remaining = currentQuantity - succeededCount

        if remaining > 0 {
            cartQuantities[id] = remaining
        }
        await persistence.saveCart(productsInCart)

        return snapshot(errorMessage: failures.first)
    }

    func createOrder(paymentMethod: String, addressId: String) async -> Snapshot {
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
            case .ok:
                return await fetchProducts()

            case .default(let statusCode, let error):
                return snapshot(errorMessage: error.errorMessage ?? "Ошибка сервера (\(statusCode))")

            case .badRequest(let error):
                return snapshot(errorMessage: error.errorMessage ?? "Ошибка запроса")

            case .unauthorized(let error):
                return snapshot(errorMessage: error.errorMessage ?? "Требуется авторизация")
            }
        } catch {
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }
}
