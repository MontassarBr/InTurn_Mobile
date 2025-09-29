import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock reviews in English
    final mockReviews = const [
      _Review(author: 'Amira Ben Salah', comment: 'Welcoming team and supportive environment. Great internship experience.', rating: 5),
      _Review(author: 'Yassine Trabelsi', comment: 'Learned a lot during my internship. Mentors were very helpful.', rating: 4),
      _Review(author: 'Nour Dkhili', comment: 'Good culture, interesting projects, and serious guidance.', rating: 5),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.reviews_outlined, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text('Intern Reviews', style: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                _RatingBadge(rating: 4.7),
              ],
            ),
            const Divider(),
            ListView.separated(
              itemCount: mockReviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = mockReviews[index];
                return _ReviewTile(review: r);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final _Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.15),
            child: Text(review.author[0], style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.author,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: AppConstants.bodyStyle.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Review {
  final String author;
  final String comment;
  final int rating;

  const _Review({required this.author, required this.comment, required this.rating});
}
