import 'package:flutter/material.dart';
import 'package:frontend/screens/internships/internship_detail_screen.dart';
import 'package:frontend/screens/internships/create_internship_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';
import '../../../providers/internship_provider.dart';
import '../../../models/internship.dart';


class InternshipSection extends StatefulWidget {
  final bool isOwner;
  const InternshipSection({Key? key, required this.isOwner}) : super(key: key);

  @override
  State<InternshipSection> createState() => _InternshipSectionState();
}

class _InternshipSectionState extends State<InternshipSection> {
  int? _companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idStr = prefs.getString(AppConstants.userIdKey);
    final userType = prefs.getString(AppConstants.userTypeKey);
    if (idStr != null && userType == AppConstants.companyType) {
      setState(() => _companyId = int.parse(idStr));
    }
    await context.read<InternshipProvider>().fetchInternships();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InternshipProvider>(
      builder: (context, provider, _) {
        final all = provider.internships;
        final companyInternships = _companyId == null
            ? all
            : all.where((i) => i.companyID == _companyId).toList();

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
                    if (widget.isOwner)
                      IconButton(
                        icon: const Icon(Icons.add_outlined),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateInternshipScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const Divider(),
                if (provider.loading)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                else if (companyInternships.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No internships yet', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                    ),
                  )
                else
                  ListView.separated(
                    itemCount: companyInternships.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final Internship i = companyInternships[index];
                      return ListTile(
                        leading: const Icon(Icons.work_outline, color: AppConstants.primaryColor),
                        title: Text(i.title),
                        subtitle: Text(i.location),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InternshipDetailScreen(internship: i),
                            ),
                          );
                        },
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (i.status.toLowerCase() == 'published' ? Colors.green : Colors.orange).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            i.status,
                            style: TextStyle(
                              color: i.status.toLowerCase() == 'published' ? Colors.green : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
