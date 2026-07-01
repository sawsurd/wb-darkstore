import Foundation
import OpenAPIRuntime

@Observable
final class ProductService {
    var products: [ProductPreview] = []
    
    func fetchProducts() async {
        await MainActor.run {
            self.products = [
                ProductPreview(
                    id: "1",
                    image: "img1", name: "Пицца",
                    weight: 450,
                    price: 599,
                    rating: 4.8,
                    reviewCount: 120,
                    isFavorite: false,
                    discount: nil
                ),
                ProductPreview(
                    id: "2",
                    image: "img2", name: "Сметана",
                    weight: 180,
                    price: 119,
                    rating: 4.5,
                    reviewCount: 85,
                    isFavorite: true,
                    discount: 50
                ),
                ProductPreview(
                    id: "3",
                    image: "img3", name: "Суши Сет",
                    weight: 800,
                    price: 1299,
                    rating: 4.9,
                    reviewCount: 240,
                    isFavorite: false,
                    discount: nil
                ),
                ProductPreview(
                    id: "5",
                    image: "img4", name: "Яблоко",
                    weight: 120,
                    price: 20,
                    rating: 4.5,
                    reviewCount: 240,
                    isFavorite: false,
                    discount: nil
                ),
                ProductPreview(
                    id: "6",
                    image: "img5", name: "Тыблоко",
                    weight: 120,
                    price: 120,
                    rating: 2.5,
                    reviewCount: 240,
                    isFavorite: false,
                    discount: nil
                ),
            ]
        }
    }
}
