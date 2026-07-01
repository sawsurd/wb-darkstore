//
//  ProductCardView.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI

struct ProductCardView: View {
    let product: ProductPreview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.2))
                .frame(height: 256)
            
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
                Text("\(product.price) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()

        }
        .background(Color(.systemBackground))
    }
}
