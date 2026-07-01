//
//  ProductCardView.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI

struct ProductCardView: View {
    let product: ProductPreview
    var width: CGFloat = 174
    
    private var imageHeight: CGFloat {
        width * (256.0 / 174.0)
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: product.price)) ?? "\(product.price)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(product.image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: imageHeight)
                .cornerRadius(16)
            
            HStack {
                Text(product.name)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 37, alignment: .topLeading)
                
                Text("\(product.weight, specifier: "%.0f") г")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 37, alignment: .topLeading)
                
            }
                Text("\(formattedPrice) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()

        }
        .frame(width: width)
        .background(Color(.systemBackground))
    }
}
