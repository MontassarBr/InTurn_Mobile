import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/education.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_profile_provider.dart';

class EducationSection extends StatefulWidget {
  final bool isOwner;
  final List<Education> education;
  const EducationSection({Key? key, required this.isOwner, required this.education}) : super(key: key);

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  late final TextEditingController institutionCtrl;
  late final TextEditingController diplomaCtrl;
  late final TextEditingController locationCtrl;

  @override
  void initState() {
    super.initState();
    institutionCtrl = TextEditingController();
    diplomaCtrl = TextEditingController();
    locationCtrl = TextEditingController();
  }

  @override
  void dispose() {
    institutionCtrl.dispose();
    diplomaCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentProfileProvider>();
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
                const Icon(Icons.school_outlined, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text('Education', style: AppConstants.subheadingStyle),
              ],
            ),
            const Divider(),
            if (widget.isOwner) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: institutionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Institution',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: diplomaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Diploma/Degree',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final inst = institutionCtrl.text.trim();
                          final dip = diplomaCtrl.text.trim();
                          final loc = locationCtrl.text.trim();
                          if (inst.isNotEmpty && dip.isNotEmpty) {
                            provider.addEducation(Education(
                              institution: inst, 
                              diploma: dip, 
                              location: loc.isEmpty ? null : loc,
                              startDate: DateTime.now().toString()
                            ));
                            institutionCtrl.clear();
                            diplomaCtrl.clear();
                            locationCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Education'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            widget.education.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        widget.isOwner ? 'Add your education above' : 'No education listed',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.education.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _EducationTile(edu: widget.education[index], isOwner: widget.isOwner, provider: provider),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EducationTile extends StatelessWidget {
  final bool isOwner;
  final Education edu;
  final StudentProfileProvider provider;
  const _EducationTile({required this.edu, required this.isOwner, required this.provider});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.school_outlined, color: AppConstants.primaryColor),
      title: Text(edu.institution),
      subtitle: Text('${edu.diploma}${edu.location != null ? ' • ${edu.location}' : ''}\n${edu.startDate} - ${edu.endDate ?? 'Present'}'),
      trailing: isOwner
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteEducation(edu.institution, edu.diploma),
            )
          : null,
    );
  }
}
