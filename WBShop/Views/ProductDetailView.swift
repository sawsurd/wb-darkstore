import SwiftUI
import DSKit
import Core

struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 440, maxHeight: 440)
                        .clipped()

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSPriceText(Double(product.price))
                            .font(DSTypography.display)
                        
                        HStack {
                            Text(product.name)
                                .font(DSTypography.title)
                            
                            Text("\(Int(product.weight))г")
                                .font(DSTypography.title)
                                .foregroundStyle(DSColors.secondary)
                        }
                        Text(product.description)
                            .font(DSTypography.body)
                            .padding(.top, DSSpacing.lg)
                    }
                    .padding(.horizontal, DSSpacing.lg)

                    Spacer()
                }
            }
            DSCloseButton(action: onDismiss)
        }
    }
}

struct ProductDetailContainerView: View {
    let previewID: String
    let productService: ProductService
    let onDismiss: () -> Void

    @State private var product: Product?

    var body: some View {
        Group {
            if let product {
                ProductDetailView(product: product, onDismiss: onDismiss)
            } else {
                ProgressView("Загрузка...")
            }
        }
        .task {
            product = await productService.fetchProductDetail(id: previewID)
        }
    }
}
