import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/application_provider.dart';
import '../../providers/internship_provider.dart';
import '../../providers/student_profile_provider.dart';
import '../../providers/saved_internship_provider.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../internships/internship_detail_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchMyApplications();
      context.read<InternshipProvider>().fetchInternships();
      context.read<StudentProfileProvider>().fetchProfile();
      context.read<SavedInternshipProvider>().fetchSavedInternships();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Consumer4<ApplicationProvider, InternshipProvider, StudentProfileProvider, SavedInternshipProvider>(
        builder: (context, appProvider, internshipProvider, profileProvider, savedProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                appProvider.fetchMyApplications(),
                internshipProvider.fetchInternships(),
                savedProvider.fetchSavedInternships(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeSection(profileProvider: profileProvider),
                  const SizedBox(height: 24),
                  _StatsSection(appProvider: appProvider, savedProvider: savedProvider),
                  const SizedBox(height: 24),
                  _RecentApplicationsSection(appProvider: appProvider),
                  const SizedBox(height: 24),
                  _RecommendedInternshipsSection(internshipProvider: internshipProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final StudentProfileProvider profileProvider;
  
  const _WelcomeSection({required this.profileProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profileProvider.firstName.isNotEmpty 
                ? '${profileProvider.firstName}!'
                : 'Student!',
            style: AppConstants.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to find your next internship opportunity?',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final ApplicationProvider appProvider;
  final SavedInternshipProvider savedProvider;
  
  const _StatsSection({required this.appProvider, required this.savedProvider});

  @override
  Widget build(BuildContext context) {
    final applications = appProvider.applications;
    final savedInternships = savedProvider.savedInternships;
    final pendingCount = applications.where((app) => app.status.toLowerCase() == 'pending').length;
    final acceptedCount = applications.where((app) => app.status.toLowerCase() == 'accepted').length;
    final rejectedCount = applications.where((app) => app.status.toLowerCase() == 'rejected').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Application Stats',
          style: AppConstants.headingStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        // Total Applications - Full Width
        _StatCard(
          title: 'Total Applications',
          value: applications.length.toString(),
          icon: Icons.assignment_outlined,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(height: 12),
        // Other stats in 2x2 grid
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Saved Internships',
                value: savedInternships.length.toString(),
                icon: Icons.bookmark_outlined,
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Pending',
                value: pendingCount.toString(),
                icon: Icons.schedule_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Accepted',
                value: acceptedCount.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Rejected',
                value: rejectedCount.toString(),
                icon: Icons.cancel_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppConstants.headingStyle.copyWith(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentApplicationsSection extends StatelessWidget {
  final ApplicationProvider appProvider;
  
  const _RecentApplicationsSection({required this.appProvider});

  @override
  Widget build(BuildContext context) {
    final recentApplications = appProvider.applications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Applications',
              style: AppConstants.headingStyle.copyWith(fontSize: 20),
            ),
            if (appProvider.applications.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to applications screen
                  DefaultTabController.of(context)?.animateTo(2);
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentApplications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No applications yet',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start applying to internships to see them here',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentApplications.map((application) => Consumer<InternshipProvider>(
            builder: (context, internshipProvider, _) => _ApplicationCard(
              application: application,
              internshipProvider: internshipProvider,
            ),
          )),
      ],
    );
  }
}


class _ApplicationCard extends StatelessWidget {
  final Application application;
  final InternshipProvider internshipProvider;

  const _ApplicationCard({
    required this.application,
    required this.internshipProvider,
  });

  @override
@override
Widget build(BuildContext context) {
  Color statusColor;
  IconData statusIcon;

  switch (application.status.toLowerCase()) {
    case 'accepted':
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      break;
    case 'rejected':
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      break;
    default:
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
  }

  // Find the internship by ID to get the title
  final internship = internshipProvider.internships.firstWhere(
    (internship) => internship.internshipID == application.internshipID,
    orElse: () => Internship(
      internshipID: application.internshipID,
      title: 'Unknown Internship',
      description: '',
      location: '',
      status: '',
      companyID: 0,
      startDate: '',
      endDate: '',
    ),
  );

  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InternshipDetailScreen(internship: internship),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Internship details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  internship.title,
                  style: AppConstants.subheadingStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied on ${_formatDate(application.applicationDate)}',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (internship.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          internship.location,
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              application.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _RecommendedInternshipsSection extends StatelessWidget {
  final InternshipProvider internshipProvider;
  
  const _RecommendedInternshipsSection({required this.internshipProvider});

  @override
  Widget build(BuildContext context) {
    final internships = internshipProvider.internships.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended Internships',
              style: AppConstants.headingStyle.copyWith(fontSize: 20),
            ),
            if (internshipProvider.internships.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to internships screen
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (internships.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No internships available',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check back later for new opportunities',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...internships.map((internship) => _InternshipCard(internship: internship)),
      ],
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final Internship internship;

  const _InternshipCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to internship detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InternshipDetailScreen(internship: internship),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company Logo Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor.withOpacity(0.8),
                        AppConstants.primaryColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (internship.companyName != null && internship.companyName!.isNotEmpty)
                          ? internship.companyName![0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.title,
                        style: AppConstants.subheadingStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (internship.companyName != null && internship.companyName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          internship.companyName!,
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    internship.status.toUpperCase(),
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    internship.location,
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (internship.workArrangement != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    internship.workArrangement!,
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (internship.minSalary != null && internship.maxSalary != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '\$${internship.minSalary!.toInt()} - \$${internship.maxSalary!.toInt()}',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
