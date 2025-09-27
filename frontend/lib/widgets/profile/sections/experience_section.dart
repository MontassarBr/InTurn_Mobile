import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_profile_provider.dart';
import '../../../models/experience.dart';

class ExperienceSection extends StatefulWidget {
  final bool isOwner;
  final List<Experience> experience;
  const ExperienceSection({Key? key, required this.isOwner, required this.experience}) : super(key: key);

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  late final TextEditingController titleCtrl;
  late final TextEditingController companyCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController();
    companyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    companyCtrl.dispose();
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
                const Icon(Icons.work_outline, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text('Experience', style: AppConstants.subheadingStyle),
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
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Job Title',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: companyCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Company',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final t = titleCtrl.text.trim();
                          final c = companyCtrl.text.trim();
                          if (t.isNotEmpty && c.isNotEmpty) {
                            provider.addExperience(Experience(title: t, companyName: c, startDate: DateTime.now().toString(), endDate: '', employmentType: 'Full-time', experienceID: 0));
                            titleCtrl.clear();
                            companyCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Experience'),
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
            widget.experience.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        widget.isOwner ? 'Add your experience above' : 'No experience listed',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.experience.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _ExperienceTile(exp: widget.experience[index], isOwner: widget.isOwner, provider: provider),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  final bool isOwner;
  final Experience exp;
  final StudentProfileProvider provider;
  const _ExperienceTile({required this.exp, required this.isOwner, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.work_outline, color: AppConstants.primaryColor),
      title: Text(exp.title),
      subtitle: Text('${exp.startDate} - ${exp.endDate} • ${exp.companyName}'),
      trailing: isOwner ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => provider.deleteExperience(exp.experienceID)) : null,
    );
  }
}
