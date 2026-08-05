import SwiftUI
import Core
import DSKit

struct CartView: View {
    let onDismiss: () -> Void
    @State private var count: Int = 0
    @Injected var cart: CartServicing

    private var hasUnavailableProducts: Bool {
        cart.productsInCart.contains { !$0.isAvailable }
    }

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
                    
                    HStack {
                        Text("Итого")
                            .font(DSTypography.priceBold)
                        Spacer()
                        DSPriceText(Double(cart.totalPrice), font: DSTypography.priceBold)
                    }
                    .padding(DSSpacing.md)
                    
                    DSButton(
                        title: "Заказать",
                        style: .gradient,
                        size: .medium,
                        fillWidth: true
                    ) {
                        Task {
                            await cart.createOrder(paymentMethod: "CASH", addressId: "e07a92b8-4f62-4074-93b8-132283f62fce")
                        }
                    }
                    .disabled(cart.productsInCart.isEmpty || hasUnavailableProducts)
                    .opacity(hasUnavailableProducts ? 0.5 : 1)
                    .padding(12)
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
            ZStack {
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

                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(DSColors.secondary)
                                .frame(width: 100, height: 100)
                                .background(DSColors.disabled)

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
                }

                if !product.isAvailable {
                    Color.black.opacity(0.3)
                        .cornerRadius(DSRadius.md)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                if product.isAvailable {
                    DSPriceText(Double(product.quantity) * Double(product.price), font: DSTypography.body)
                } else {
                    Text("Нет в наличии")
                        .font(DSTypography.caption)
                        .foregroundColor(.red)
                        .padding(.vertical, 2)
                }

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
                .disabled(!product.isAvailable)
                .padding(.top, DSSpacing.md)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
        .opacity(product.isAvailable ? 1.0 : 0.5)
    }
}
