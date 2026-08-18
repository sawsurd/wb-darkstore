import SwiftUI
import Core
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
    @State private var product: Product
    let onDismiss: () -> Void
    @State private var showAddReview = false
    private var averageRating: Double {
        let count = product.reviews?.count ?? 0

        guard count > 0 else {
            return 0
        }

        let totalRating = product.reviews?
            .compactMap(\.rating)
            .reduce(0, +) ?? 0

        return Double(totalRating) / Double(count)
    }

    init(product: Product, onDismiss: @escaping () -> Void) {
        self._product = State(initialValue: product)
        self.onDismiss = onDismiss
    }

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
                    VStack(spacing: DSSpacing.md) {
                        HStack {
                            Text(String(format: "%.1f", averageRating))
                                .font(DSTypography.reviewAvgRating)
                            Spacer()
                        }
                        
                        DSButton(title: "Написать отзыв", style: .lightPurple, fillWidth: true) {
                            showAddReview = true
                        }

                        ForEach(Array((product.reviews ?? []).enumerated()), id: \.offset) { _, review in
                            ReviewView(review: review)
                        }
                    }
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, DSSpacing.lg)
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
        .sheet(isPresented: $showAddReview) {
            AddReviewView(
                product: product,
                onReviewAdded: { updated in
                    product = updated
                },
                onDismiss: {
                    showAddReview = false
                }
            )
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

struct AddReviewView: View {
    @Injected private var productService: ProductServicing
    let product: Product
    let onReviewAdded: (Product) -> Void
    let onDismiss: () -> Void


    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var images: [String] = []
    @State private var isSubmitting = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text("Отзыв о товаре")
                    .font(DSTypography.title)
                    .foregroundStyle(DSColors.black)
                    .padding(.top, DSSpacing.lg)

                HStack(spacing: DSSpacing.md) {
                    AsyncImage(url: URL(string: product.image)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipped()
                    .cornerRadius(8)
                    .background(Color(.systemGray6))

                    VStack (alignment: .leading) {
                        HStack {
                            Text(product.name)
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.black)
                            
                            Text("\(product.weight, specifier: "%.f")г")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.secondary)
                        }
                        Text(product.description)
                            .font(DSTypography.body)
                            .foregroundStyle(DSColors.black)
                    }
                    
                    
                }

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Оценка")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.black)

                    HStack(spacing: DSSpacing.xs) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(DSTypography.title)
                                .foregroundColor(DSColors.black.opacity(0.1))
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Комментарий")
                        .font(DSTypography.body)
                        .foregroundStyle(DSColors.black)

                    TextEditor(text: $comment)
                        .frame(minHeight: 12)
                        .padding(DSSpacing.sm)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                Spacer()

                DSButton(
                    title: isSubmitting ? "Отправка..." : "Оставить отзыв",
                    style: .gradient,
                    size: DSButtonSize.medium,
                    fillWidth: true
                ) {
                    Task { await submitReview() }
                }
            }
            .padding(.horizontal, DSSpacing.lg)

            HStack {
                Spacer()
                DSCloseButton(action: onDismiss)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.top, DSSpacing.lg)
        }
    }

    private func submitReview() async {
        isSubmitting = true
        defer { isSubmitting = false }

        if let updated = await productService.addReviewToProduct(
            productId: product.id,
            rating: rating,
            comment: comment,
            images: images
        ) {
            onReviewAdded(updated)
        }
        onDismiss()
    }
}
