//
//  ContentView.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI
import OpenAPIRuntime

extension ProductPreview: Identifiable {
}

struct ContentView: View {
    @State private var productService = ProductService()
    
    private let horizontalPadding: CGFloat = 12
    private let cardSpacing: CGFloat = 3
    private let rowSpacing: CGFloat = 18
    
    var body: some View {
        NavigationStack {
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
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                }
            }
            .navigationTitle("Для тебя")
            .background(Color(.white))
            .task {
                await productService.fetchProducts()
            }
        }
    }
}

#Preview {
    ContentView()
}
