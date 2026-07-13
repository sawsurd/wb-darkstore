import SwiftUI
import OpenAPIRuntime
import DSKit
import Core

extension ProductPreview: Identifiable {
}

struct ContentView: View {
    @State private var productService = ProductService()
    @State private var selectedProduct: ProductPreview?

    private let horizontalPadding = DSSpacing.md
    private let cardSpacing = DSSpacing.xs
    private let rowSpacing = 18.0

    var body: some View {
        GeometryReader { geo in
            let cardWidth = (geo.size.width - horizontalPadding * 2 - cardSpacing) / 2
            let columns = [
                GridItem(.flexible(), spacing: cardSpacing),
                GridItem(.flexible(), spacing: cardSpacing)
            ]

            ScrollView {
                if productService.products.isEmpty {
                    ProgressView("Загрузка...")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: rowSpacing) {
                        ForEach(productService.products) { product in
                            ProductCardView(product: product, width: cardWidth)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                            
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
            }
        }
        .navigationTitle("Для тебя")
        .background(DSColors.surface)
        .task {
            await productService.fetchProducts()
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id, productService: productService){
                selectedProduct = nil
            }
                .presentationDetents([.large])
                .presentationCornerRadius(DSRadius.sheet)
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
