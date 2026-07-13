import SwiftUI
import DSKit
import Core

struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 440, maxHeight: 440)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(product.price)) ₽")
                            .font(DSTypography.price)
                        
                        HStack {
                            Text(product.name)
                                .font(DSTypography.name)
                            
                            Text("\(Int(product.weight))г")
                                .font(DSTypography.name)
                                .foregroundStyle(DSColors.secondary)
                        }
                        Text(product.description)
                            .font(DSTypography.body)
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
            }
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                    .opacity(0.5)
                    .padding(20)
            }
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
