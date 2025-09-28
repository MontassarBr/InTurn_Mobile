import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../providers/application_provider.dart';
import '../../providers/internship_provider.dart';
import '../../providers/company_profile_provider.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../internships/create_internship_screen.dart';
import '../applications/company_applications_screen.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({Key? key}) : super(key: key);

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyData();
    });
  }

  Future<void> _loadCompanyData() async {
    // Load company internships
    await context.read<InternshipProvider>().fetchInternships();
    
    // Load company profile
    await context.read<CompanyProfileProvider>().fetchProfile();
    
    // Load company applications data
    await _loadCompanyApplications();
  }

  Future<void> _loadCompanyApplications() async {
    try {
      // Get authenticated company ID (same logic as applications screen)
      final prefs = await SharedPreferences.getInstance();
      final companyIdStr = prefs.getString(AppConstants.userIdKey);
      final userType = prefs.getString(AppConstants.userTypeKey);
      
      if (companyIdStr != null && userType == AppConstants.companyType) {
        final companyId = int.parse(companyIdStr);
        await context.read<ApplicationProvider>().fetchApplicationsForCompany(companyId);
      }
    } catch (e) {
      print('Error loading company applications for dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateInternshipDialog(context),
            tooltip: 'Create Internship',
          ),
        ],
      ),
      body: Consumer3<InternshipProvider, CompanyProfileProvider, ApplicationProvider>(
        builder: (context, internshipProvider, profileProvider, applicationProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await _loadCompanyData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeSection(profileProvider: profileProvider),
                  const SizedBox(height: 24),
                  _StatsSection(
                    internshipProvider: internshipProvider,
                    applicationProvider: applicationProvider,
                  ),
                  const SizedBox(height: 24),
                  _RecentInternshipsSection(
                    internshipProvider: internshipProvider,
                    onCreateInternship: () => _showCreateInternshipDialog(context),
                  ),
                  const SizedBox(height: 24),
                  _QuickActionsSection(
                    onCreateInternship: () => _showCreateInternshipDialog(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateInternshipDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateInternshipScreen(),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final CompanyProfileProvider profileProvider;
  
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
            profileProvider.companyName.isNotEmpty 
                ? '${profileProvider.companyName}!'
                : 'Company!',
            style: AppConstants.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your internships and find the best talent',
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
  final InternshipProvider internshipProvider;
  final ApplicationProvider applicationProvider;
  
  const _StatsSection({
    required this.internshipProvider,
    required this.applicationProvider,
  });

  @override
  Widget build(BuildContext context) {
    final internships = internshipProvider.internships;
    final publishedInternships = internships.where((internship) => 
        internship.status == 'Published' || internship.status == 'published').length;
    
    final applications = applicationProvider.applications;
    final totalApplications = applications.length;
    final pendingApplications = applications.where((app) => app.status == 'Pending').length;
    
    // Show loading indicator if data is still being fetched
    final isLoading = internshipProvider.loading || applicationProvider.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Overview',
          style: AppConstants.headingStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            ),
          )
        else ...[
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Internships',
                value: internships.length.toString(),
                icon: Icons.work_outline,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Published Internships',
                value: publishedInternships.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Applications',
                value: totalApplications.toString(),
                icon: Icons.assignment_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Pending Reviews',
                value: pendingApplications.toString(),
                icon: Icons.schedule_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        ], // Close else block
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

class _RecentInternshipsSection extends StatelessWidget {
  final InternshipProvider internshipProvider;
  final VoidCallback onCreateInternship;
  
  const _RecentInternshipsSection({
    required this.internshipProvider,
    required this.onCreateInternship,
  });

  @override
  Widget build(BuildContext context) {
    final recentInternships = internshipProvider.internships.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Internships',
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
        if (recentInternships.isEmpty)
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
                  'No internships posted yet',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first internship to get started',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onCreateInternship,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Internship'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentInternships.map((internship) => _InternshipCard(internship: internship)),
      ],
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final Internship internship;

  const _InternshipCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (internship.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'closed':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
    }

    return Container(
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
              Expanded(
                child: Text(
                  internship.title,
                  style: AppConstants.subheadingStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      internship.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                internship.location,
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (internship.workArrangement != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '\$${internship.minSalary!.toStringAsFixed(0)} - \$${internship.maxSalary!.toStringAsFixed(0)}',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CompanyApplicationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined, size: 12),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to edit internship screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateInternshipScreen(internship: internship),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, internship),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic internship) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              const Text('Delete Internship'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${internship.title}"?',
                style: AppConstants.subheadingStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone. All applications for this internship will also be affected.',
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteInternship(context, internship),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteInternship(BuildContext context, dynamic internship) async {
    // Close the dialog first
    Navigator.of(context).pop();
    
    // Store references before async operations
    final internshipProvider = context.read<InternshipProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final success = await internshipProvider.deleteInternship(internship.internshipID);
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${internship.title} deleted successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Refresh the internships list
        internshipProvider.fetchInternships();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(internshipProvider.error ?? 'Failed to delete internship'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error deleting internship: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete internship: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onCreateInternship;
  
  const _QuickActionsSection({
    required this.onCreateInternship,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppConstants.headingStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Create Internship',
                subtitle: 'Post a new opportunity',
                icon: Icons.add_circle_outline,
                color: AppConstants.primaryColor,
                onTap: onCreateInternship,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'View Applications',
                subtitle: 'Review candidates',
                icon: Icons.assignment_outlined,
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CompanyApplicationsScreen(),
                    ),
                  );
                  // Refresh dashboard data when returning from applications
                  if (result != null) {
                    context.read<InternshipProvider>().fetchInternships();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Company Profile',
                subtitle: 'Update information',
                icon: Icons.business_outlined,
                color: Colors.green,
                onTap: () {
                  // Navigate to profile
                  DefaultTabController.of(context)?.animateTo(4);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'Analytics',
                subtitle: 'View insights',
                icon: Icons.analytics_outlined,
                color: Colors.purple,
                onTap: () {
                  // Navigate to analytics
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}