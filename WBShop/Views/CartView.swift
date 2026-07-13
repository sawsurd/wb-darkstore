import SwiftUI
import Core
import DSKit

struct CartView: View {
    let onDismiss: () -> Void
    @State private var count: Int = 0

    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Корзина")
                            .font(DSTypography.display)
                            
                        Text("4")
                            .font(DSTypography.display)
                            .foregroundStyle(DSColors.secondary)
                        Spacer()
                    }
                    .padding(.top, DSSpacing.sm_md)
                    .padding(.horizontal, DSSpacing.md)
                    
                    LazyVStack(spacing: DSSpacing.lg) {
                        ForEach(0..<20, id: \.self) {_ in
                            CartItemView()
                        }
                    }
                    
                }
                DSCloseButton(action: onDismiss)
            }
        }
    }
}

#Preview {
    CartView() {
        print()
    }
}

struct CartItemView: View {
    @State private var count: Int = 1

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            Image("img1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(DSRadius.md)
            
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSPriceText(Double(count) * 128.99, font: DSTypography.body)
                
                HStack {
                    Text("Бутер с колбасой")
                        .font(DSTypography.caption)
                    Text("400г")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.secondary)
                }
                
                DSCounterView(count: $count)
                    .padding(.top, DSSpacing.md)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
    }
}
