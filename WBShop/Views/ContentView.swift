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
    
    let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if productService.products.isEmpty {
                    ProgressView("Загрузка...")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(productService.products) { product in
                            ProductCardView(product: product)
                        }
                    }
                    .padding(.horizontal, 12)
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
