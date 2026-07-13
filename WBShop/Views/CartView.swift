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
                            .font(DSTypography.price)
                            
                        Text("4")
                            .font(DSTypography.price)
                            .foregroundStyle(DSColors.secondary)
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 12)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(0..<20, id: \.self) {_ in
                            CartItemView()
                        }
                    }
                    
                }
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.black)
                        .opacity(0.5)
                        .padding(20)
                }
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
        HStack(alignment: .top, spacing: 12) {
            Image("img1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Double(count) * 128.99, specifier: "%.2f") ₽")
                    .font(DSTypography.body)
                
                HStack {
                    Text("Бутер с колбасой")
                        .font(DSTypography.nameCart)
                    Text("400г")
                        .font(DSTypography.nameCart)
                        .foregroundStyle(DSColors.secondary)
                }
                
                DSCounterView(count: $count)
                    .padding(.top, 12)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}
