import SwiftUI
import OpenAPIRuntime
import DSKit
import Core

extension ProductPreview: Identifiable {
}

struct ContentView: View {
    @Injected var productService: ProductServicing
    @State private var selectedProduct: ProductPreview?

    private let horizontalPadding = DSSpacing.md
    private let cardSpacing = DSSpacing.xs
    private let rowSpacing = 18.0

    var body: some View {
        ProductGridView(
            products: productService.products,
            onSelectProduct: { selectedProduct = $0 },
            isFavorite: { productService.isFavorite(id: $0) },
            onToggleFavorite: { product in
                Task { await productService.toggleFavorite(id: product.id) }
            }
        )
        .navigationTitle("Для тебя")
        .background(DSColors.surface)
        .task {
            await productService.fetchProducts()
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id){
                selectedProduct = nil
            }
                .presentationDetents([.large])
                .presentationCornerRadius(DSRadius.sheet)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
