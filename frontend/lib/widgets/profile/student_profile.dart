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
              backgroundColor: Colors.grey[50],
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppConstants.primaryColor,
                    title: const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    centerTitle: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppConstants.primaryColor,
                              AppConstants.primaryColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                          onPressed: () => showEditStudentDialog(context, provider),
                          tooltip: 'Edit Profile',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_outlined, color: Colors.white),
                          onPressed: () => context.read<AuthProvider>().logout(context),
                          tooltip: 'Logout',
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderSection(provider: provider),
                          const SizedBox(height: 20),
                          _PersonalInfoSection(provider: provider),
                          const SizedBox(height: 20),
                          _UniversityInfoSection(provider: provider),
                          const SizedBox(height: 20),
                          _SocialLinksSection(provider: provider),
                          const SizedBox(height: 20),
                          EducationSection(isOwner: true, education: provider.education),
                          const SizedBox(height: 20),
                          SkillsSection(isOwner: true, skills: provider.skills),
                          const SizedBox(height: 20),
                          ExperienceSection(isOwner: true, experience: provider.experience),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.transparent,
                    backgroundImage: provider.profilePic != null 
                        ? NetworkImage(provider.profilePic!) 
                        : null,
                    child: provider.profilePic == null 
                        ? Text(
                            '${provider.firstName.isNotEmpty ? provider.firstName[0] : ''}${provider.lastName.isNotEmpty ? provider.lastName[0] : ''}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${provider.firstName} ${provider.lastName}',
                        style: AppConstants.headingStyle.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (provider.title != null && provider.title!.isNotEmpty) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            provider.title!,
                            style: AppConstants.subheadingStyle.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (provider.openToWork) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.work_outline, size: 16, color: Colors.green[700]),
                              const SizedBox(width: 6),
                              Text(
                                'Open to Work',
                                style: AppConstants.bodyStyle.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (provider.about != null && provider.about!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'About',
                          style: AppConstants.subheadingStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.about!,
                      style: AppConstants.bodyStyle.copyWith(
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  final StudentProfileProvider provider;
  const _PersonalInfoSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.phone == null || provider.phone!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: AppConstants.headingStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.phone != null && provider.phone!.isNotEmpty)
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: provider.phone!,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}

class _UniversityInfoSection extends StatelessWidget {
  final StudentProfileProvider provider;
  const _UniversityInfoSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasAnyInfo = provider.university != null ||
        provider.degree != null ||
        provider.graduationYear != null ||
        provider.gpa != null;

    if (!hasAnyInfo) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'University Information',
                  style: AppConstants.headingStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.university != null && provider.university!.isNotEmpty)
              _InfoTile(
                icon: Icons.business_outlined,
                label: 'University',
                value: provider.university!,
                color: Colors.purple,
              ),
            if (provider.degree != null && provider.degree!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.school,
                label: 'Degree',
                value: provider.degree!,
                color: Colors.indigo,
              ),
            ],
            if (provider.graduationYear != null) ...[
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Graduation Year',
                value: provider.graduationYear.toString(),
                color: Colors.teal,
              ),
            ],
            if (provider.gpa != null) ...[
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.grade_outlined,
                label: 'GPA',
                value: provider.gpa!.toStringAsFixed(2),
                color: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SocialLinksSection extends StatelessWidget {
  final StudentProfileProvider provider;
  const _SocialLinksSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasAnyLink = provider.portfolioUrl != null ||
        provider.linkedinUrl != null ||
        provider.githubUrl != null;

    if (!hasAnyLink) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link_outlined, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Social Links',
                  style: AppConstants.headingStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.portfolioUrl != null && provider.portfolioUrl!.isNotEmpty)
              _LinkTile(
                icon: Icons.web_outlined,
                label: 'Portfolio',
                url: provider.portfolioUrl!,
                color: Colors.blue,
              ),
            if (provider.linkedinUrl != null && provider.linkedinUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _LinkTile(
                icon: Icons.person_pin_outlined,
                label: 'LinkedIn',
                url: provider.linkedinUrl!,
                color: Colors.blueAccent,
              ),
            ],
            if (provider.githubUrl != null && provider.githubUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _LinkTile(
                icon: Icons.code_outlined,
                label: 'GitHub',
                url: provider.githubUrl!,
                color: Colors.grey[700]!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new, color: color, size: 18),
        ],
      ),
    );
  }
}
