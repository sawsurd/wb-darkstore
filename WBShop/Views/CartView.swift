import SwiftUI
import Core
import DSKit

struct CartView: View {
    let onDismiss: () -> Void
    @State private var count: Int = 0
    @Injected var cart: CartServicing

    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Корзина")
                            .font(DSTypography.display)
                            
                        Text("\(cart.productsInCart.count)")
                            .font(DSTypography.display)
                            .foregroundStyle(DSColors.secondary)
                        Spacer()
                    }
                    .padding(.top, DSSpacing.sm_md)
                    .padding(.horizontal, DSSpacing.md)
                    
                    LazyVStack(spacing: DSSpacing.lg) {
                        ForEach(cart.productsInCart) { product in
                            CartItemView(
                                product: product,
                                onIncrement: {
                                    Task { await cart.addProductToCart(id: product.id) }
                                },
                                onDecrement: {
                                    Task { await cart.removeProductFromCart(id: product.id) }
                                }
                            )
                        }
                    }
                }
                DSCloseButton(action: onDismiss)
            }
        }
        .task {
            await cart.fetchProducts()
        }
    }
}

#Preview {
    CartView() {
        print()
    }
}

struct CartItemView: View {
    let product: CartProduct
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            if let imageUrl = URL(string: product.image) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .background(DSColors.secondary)

                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()

                    case .failure(let error):
                        Image(systemName: "photo")
                            .foregroundColor(DSColors.secondary)
                            .frame(width: 100, height: 100)
                            .background(DSColors.disabled)
                            .onAppear {
                                print("Ошибка загрузки картинки:", product.name, imageUrl, error)
                            }

                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(DSRadius.md)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(DSColors.secondary)
                    .frame(width: 100, height: 100)
                    .background(DSColors.disabled)
                    .cornerRadius(DSRadius.md)
                    .onAppear {
                        print("Невалидный URL картинки:", product.name, product.image)
                    }
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSPriceText(Double(product.quantity) * Double(product.price), font: DSTypography.body)

                HStack {
                    Text(product.name)
                        .font(DSTypography.caption)
                    Text("\(product.weight)г")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.secondary)
                }

                DSCounterView(
                    count: product.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement
                )
                .padding(.top, DSSpacing.md)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
    }
}
