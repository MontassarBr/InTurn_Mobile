import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class InternshipSection extends StatelessWidget {
  final bool isOwner;
  const InternshipSection({Key? key, required this.isOwner}) : super(key: key);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Internships', style: AppConstants.subheadingStyle),
                if (isOwner) IconButton(icon: const Icon(Icons.add_outlined), onPressed: () {}),
              ],
            ),
            const Divider(),
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => const ListTile(
                leading: Icon(Icons.work_outline, color: AppConstants.primaryColor),
                title: Text('Software Engineering Intern'),
                subtitle: Text('San Francisco, CA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
