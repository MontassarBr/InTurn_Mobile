import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/student_profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_student_dialog.dart';
import 'sections/education_section.dart';
import 'sections/skills_section.dart';
import 'sections/experience_section.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({Key? key}) : super(key: key);

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StudentProfileProvider>(
      create: (_) => StudentProfileProvider()..fetchProfile(),
      builder: (context, _) {
        return Consumer<StudentProfileProvider>(
          builder: (context, provider, __) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('My Profile'),
                backgroundColor: AppConstants.primaryColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    tooltip: 'Logout',
                    onPressed: () => context.read<AuthProvider>().logout(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showEditStudentDialog(context, provider),
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSection(provider: provider),
                    const SizedBox(height: 16),
                    EducationSection(isOwner: true, education: provider.education),
                    const SizedBox(height: 16),
                    SkillsSection(isOwner: true, skills: provider.skills),
                    const SizedBox(height: 16),
                    ExperienceSection(isOwner: true, experience: provider.experience),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final StudentProfileProvider provider;
  const _HeaderSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.primaryColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.lightPrimaryColor,
                    backgroundImage: provider.profilePic != null 
                        ? NetworkImage(provider.profilePic!) 
                        : null,
                    child: provider.profilePic == null 
                        ? Text(
                            '${provider.firstName.isNotEmpty ? provider.firstName[0] : ''}${provider.lastName.isNotEmpty ? provider.lastName[0] : ''}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${provider.firstName} ${provider.lastName}',
                        style: AppConstants.headingStyle.copyWith(fontSize: 24),
                      ),
                      if (provider.title != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.title!,
                          style: AppConstants.subheadingStyle.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (provider.about != null && provider.about!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('About', style: AppConstants.subheadingStyle.copyWith(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                provider.about!,
                style: AppConstants.bodyStyle.copyWith(height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
