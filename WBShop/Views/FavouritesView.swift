import SwiftUI
import Core
import DSKit

struct FavoritesView: View {
    @Injected var productService: ProductServicing
    @State private var selectedProduct: ProductPreview?

    var body: some View {
        HStack {
            Text("Избранное")
                .font(DSTypography.display)
            Spacer()
        }
        .padding(.top, DSSpacing.sm_md)
        .padding(.horizontal, DSSpacing.md)

        ProductGridView(
            products: productService.favProducts,
            onSelectProduct: { selectedProduct = $0 }
        )
        .navigationTitle("Избранное")
        .background(DSColors.surface)
        .task {
            await productService.fetchFavProducts()
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id) {
                selectedProduct = nil
            }
            .presentationDetents([.large])
            .presentationCornerRadius(DSRadius.sheet)
            .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    FavoritesView()
}
