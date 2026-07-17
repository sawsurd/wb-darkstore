import SwiftUI
import DSKit

struct ProductCardView: View {
    let product: ProductPreview
    var width: CGFloat = 174
    
    private var imageHeight: CGFloat {
        width * (256.0 / 174.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                .cornerRadius(16)
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(width: width, height: imageHeight)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
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
                }
            }
        }
        .frame(width: width)
        .background(DSColors.background)
        .contentShape(Rectangle())
    }
}
