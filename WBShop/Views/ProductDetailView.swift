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
                    if let imageUrl = URL(string: product.image) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                                    .background(Color(.systemGray6))
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                                
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                                    .background(Color(.systemGray5))
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipped()
                        .cornerRadius(16)
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                            .background(Color(.systemGray5))
                            .cornerRadius(16)
                    }

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
