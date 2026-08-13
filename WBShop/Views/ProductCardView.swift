import SwiftUI
import DSKit
import Core

struct ProductCardView: View {
    let product: ProductPreview
    var width: CGFloat = 174
    @Injected var cart: CartServicing
    
    private var imageHeight: CGFloat {
        width * (256.0 / /*174*/ 256.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            if let imageUrl = URL(string: product.image) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: width, height: imageHeight)
                            .background(Color(.systemGray6))
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: imageHeight)
                        
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(width: width, height: imageHeight)
                            .background(Color(.systemGray5))
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipped()
                .cornerRadius(DSRadius.xl)
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(width: width, height: imageHeight)
                    .background(Color(.systemGray5))
                    .cornerRadius(DSRadius.xl)
            }
            
            HStack {
                Text(product.name)
                    .font(DSTypography.caption)
                    .lineLimit(2)
                    .frame(height: 37, alignment: .topLeading)
                
                Text("\(product.weight, specifier: "%.0f") г")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.secondary)
                    .frame(height: 37, alignment: .topLeading)
                
            }
            
            HStack {
                DSButton(title: "\(Int(product.price)) ₽",
                    style: .lightPurple,
                    size: .compact,
                    icon: Image("plus")) {
                    Task {
                        await cart.addProductToCart(id: product.id)
                    }
                }
            }
        }
        .frame(width: width)
        .background(DSColors.background)
        .contentShape(Rectangle())
    }
}
