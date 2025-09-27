import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_profile_provider.dart';

class SkillsSection extends StatelessWidget {
  final bool isOwner;
  final List<String> skills;
  const SkillsSection({Key? key, required this.isOwner, required this.skills}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentProfileProvider>();
    final addController = TextEditingController();
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
                const Icon(Icons.psychology_outlined, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text('Skills', style: AppConstants.subheadingStyle),
              ],
            ),
            const Divider(),
            if (isOwner) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addController,
                        decoration: const InputDecoration(
                          hintText: 'Add a new skill...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final text = addController.text.trim();
                        if (text.isNotEmpty) {
                          provider.addSkill(text);
                          addController.clear();
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            skills.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        isOwner ? 'Add your skills above' : 'No skills listed',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills
                        .map((skill) => Chip(
                              label: Text(skill, style: const TextStyle(fontWeight: FontWeight.w500)),
                              deleteIcon: isOwner ? const Icon(Icons.close, size: 18) : null,
                              onDeleted: isOwner ? () => provider.deleteSkill(skill) : null,
                              backgroundColor: AppConstants.lightPrimaryColor,
                              side: BorderSide(color: AppConstants.primaryColor.withOpacity(0.3)),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
