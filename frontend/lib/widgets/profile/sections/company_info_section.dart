import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class CompanyInfoSection extends StatelessWidget {
  final bool isOwner;
  const CompanyInfoSection({Key? key, required this.isOwner}) : super(key: key);

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
                const Text('Company Info', style: AppConstants.subheadingStyle),
                if (isOwner) IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
              ],
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.business_outlined, color: AppConstants.primaryColor),
              title: Text('Example Corp'),
              subtitle: Text('example.com'),
            ),
            const ListTile(
              leading: Icon(Icons.work_outline, color: AppConstants.primaryColor),
              title: Text('Industry'),
              subtitle: Text('Software Development'),
            ),
            const ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: AppConstants.primaryColor),
              title: Text('Workdays'),
              subtitle: Text('Mon - Fri'),
            ),
          ],
        ),
      ),
    );
  }
}
