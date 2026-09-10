import SwiftUI
import DSKit

struct OrderSuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DSSuccessScreen(
            title: "Заказ\nоформлен",
            subtitle: "Товары уже в процессе сборки,\nскоро привезём!",
            buttonTitle: "Закрыть",
            onClose: {
                dismiss()
            },
            onAction: {
                dismiss()
            }
        )
    }
}
