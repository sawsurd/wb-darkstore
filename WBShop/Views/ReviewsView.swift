import SwiftUI
import DSKit

struct RatingStarsView: View {
    let rating: Double 
    let maxRating: Int = 5
    var starSize: Font = .body

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                starImage(for: index)
                    .font(starSize)
                    .foregroundColor(DSColors.black)
            }
        }
    }

    private func starImage(for index: Int) -> Image {
        let difference = rating - Double(index - 1)
        
        if difference >= 1 {
            return Image(systemName: "star.fill")
        } else if difference >= 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}


struct ReviewsView: View {
    let product: Product
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            let count = self.product.reviews?.count ?? 0
            VStack(spacing: 16) {
                HStack {
                    Text("Отзывы")
                        .font(DSTypography.headline)
                        .frame(alignment: .leading)
                    Text("\(count)")
                        .font(DSTypography.headline)
                        .foregroundStyle(DSColors.secondary.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.lg)

                ScrollView {
                    DSButton(title: "Написать отзыв", style: .lightPurple) {
                        print()
                    }
                    
                    ForEach(Array((product.reviews ?? []).enumerated()), id: \.offset) { _, review in
                        ReviewView(review: review)
                            .padding(DSSpacing.md)
                    }
                }
            }
            .padding(.top, DSSpacing.lg)

            HStack {
                Spacer()
                DSCloseButton(action: onDismiss)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.top, DSSpacing.lg)
        }
    }
}

struct ReviewView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                RatingStarsView(rating: Double(review.rating), starSize: DSTypography.body)
                Text(review.author)
                    .font(DSTypography.body)
                Text(", \(review.createdAt.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "ru_RU"))))")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.secondary)
            }

            Text(review.content)
                .font(DSTypography.body)
                .foregroundStyle(DSColors.black)
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}
