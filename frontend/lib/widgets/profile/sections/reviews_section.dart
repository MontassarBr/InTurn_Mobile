import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reviews', style: AppConstants.subheadingStyle),
            const Divider(),
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => const ListTile(
                leading: CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/default_avatar.png')),
                title: Text('John Doe'),
                subtitle: Text('Great place to work and learn!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
