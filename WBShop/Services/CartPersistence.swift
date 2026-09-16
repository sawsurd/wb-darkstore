import Foundation
import SwiftData

@ModelActor
actor CartPersistence {
    func loadCart() -> (quantities: [String: Int], details: [String: CartProduct]) {
        var quantities: [String: Int] = [:]
        var details: [String: CartProduct] = [:]

        do {
            let items = try modelContext.fetch(FetchDescriptor<CartItemModel>())

            for item in items {
                guard item.quantity > 0 else { continue }
                quantities[item.id] = item.quantity
                details[item.id] = CartProduct(
                    id: item.id,
                    image: item.image,
                    name: item.name,
                    weight: item.weight,
                    price: item.price,
                    quantity: item.quantity,
                    isAvailable: item.isAvailable
                )
            }
        } catch {
            print("Ошибка загрузки локальной корзины: \(error)")
        }

        return (quantities, details)
    }

    func saveCart(_ products: [CartProduct]) {
        do {
            let existingItems = try modelContext.fetch(FetchDescriptor<CartItemModel>())
            for item in existingItems {
                modelContext.delete(item)
            }

            for product in products {
                let item = CartItemModel(
                    id: product.id,
                    image: product.image,
                    name: product.name,
                    weight: product.weight,
                    price: product.price,
                    quantity: product.quantity,
                    isAvailable: product.isAvailable
                )
                modelContext.insert(item)
            }
            try modelContext.save()
        } catch {
            print("Ошибка сохранения корзины: \(error)")
        }
    }
}
