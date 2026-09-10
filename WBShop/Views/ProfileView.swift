import SwiftUI
import Core
import DSKit

struct ProfileView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("История заказов")
                .font(DSTypography.order.weight(.regular))
                .padding(DSSpacing.lg)
            OrderHistoryView()
        }
        .background(DSColors.background)
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserProfileView: View {

    var body: some View {
    }
}
