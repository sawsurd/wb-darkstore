import SwiftUI
import DSKit

struct ProductCardView: View {
    let product: ProductPreview
    var width: CGFloat = 174
    
    private var imageHeight: CGFloat {
        width * (256.0 / 174.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Image(product.image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: imageHeight)
                .cornerRadius(DSRadius.xl)
            
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
            Spacer()

        }
        .frame(width: width)
        .background(DSColors.background)
    }
}
