import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import '../../utils/constants.dart';
import '../../providers/internship_provider.dart';
import '../../models/internship.dart';

class CompanyApplicationsScreen extends StatefulWidget {
  const CompanyApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<CompanyApplicationsScreen> createState() => _CompanyApplicationsScreenState();
}

class _CompanyApplicationsScreenState extends State<CompanyApplicationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipProvider>().fetchInternships();
      // Try to load real company applications, fallback to mock if needed
      _loadCompanyApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyApplications() async {
    try {
      // Get authenticated company ID
      final prefs = await SharedPreferences.getInstance();
      final companyIdStr = prefs.getString(AppConstants.userIdKey);
      final userType = prefs.getString(AppConstants.userTypeKey);
      
      if (companyIdStr == null || userType != AppConstants.companyType) {
        throw Exception('No authenticated company found');
      }
      
      final companyId = int.parse(companyIdStr);
      print('Loading applications for authenticated company ID: $companyId');
      
      await context.read<ApplicationProvider>().fetchApplicationsForCompany(companyId);
    } catch (e) {
      print('Error loading company applications: $e');
      // Fallback is handled inside the provider
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Applications'),
      backgroundColor: AppConstants.primaryColor,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'All Applications', icon: Icon(Icons.assignment_outlined)),
          Tab(text: 'By Internship', icon: Icon(Icons.work_outline)),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _AllApplicationsTab(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() => _selectedFilter = filter);
          },
          filterOptions: _filterOptions,
          onRefresh: _loadCompanyApplications,
        ),
        _InternshipApplicationsTab(onRefresh: _loadCompanyApplications),
      ],
    ),
  );
}

}

class _AllApplicationsTab extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;
  final Future<void> Function() onRefresh;

  const _AllApplicationsTab({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterOptions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchMyApplications(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final applications = provider.applications;
        final filteredApplications = applications.where((app) {
          if (selectedFilter == 'All') return true;
          return app.status.toLowerCase() == selectedFilter.toLowerCase();
        }).toList();

        return Column(
          children: [
            _FilterChips(
              selectedFilter: selectedFilter,
              onFilterChanged: onFilterChanged,
              filterOptions: filterOptions,
            ),
            Expanded(
              child: filteredApplications.isEmpty
                  ? _EmptyApplicationsState(filter: selectedFilter)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredApplications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final application = filteredApplications[index];
                          return _CompanyApplicationCard(
                            application: application,
                            onStatusChange: (newStatus) => _updateApplicationStatus(context, application, newStatus),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateApplicationStatus(BuildContext context, Application application, String newStatus) async {
    // Store references before async operations
    final provider = context.read<ApplicationProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final success = await provider.updateApplicationStatus(
        studentID: application.studentID,
        internshipID: application.internshipID,
        applicationDate: application.applicationDate,
        status: newStatus,
      );
      
      // Use stored references instead of context
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Application ${newStatus.toLowerCase()} successfully!'),
            backgroundColor: newStatus == 'Accepted' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update application'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error updating application status: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update application: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = filter == selectedFilter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter);
                }
              },
              selectedColor: AppConstants.primaryColor.withOpacity(0.2),
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppConstants.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompanyApplicationCard extends StatelessWidget {
  final Application application;
  final Function(String) onStatusChange;

  const _CompanyApplicationCard({
    required this.application,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final status = application.status;
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  application.studentName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.studentName,
                      style: AppConstants.subheadingStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.title ?? 'Internship #${application.internshipID}',
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                      status.toUpperCase(),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  application.email ?? 'No email',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Applied ${_formatDate(application.applicationDate)}',
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStudentProfile(context, application),
                  icon: const Icon(Icons.person_outlined, size: 16),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (status == 'Pending') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStatusDialog(context, application, onStatusChange),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: status != 'Pending' ? () => _showStatusDialog(context, application, onStatusChange) : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Change Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStudentProfile(BuildContext context, Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              application.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            application.studentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              application.email ?? 'No email provided',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Application Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(application.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(application.status).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(application.status),
                            color: _getStatusColor(application.status),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Application Status',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                application.status,
                                style: TextStyle(
                                  color: _getStatusColor(application.status),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // About Me Section
                    if (application.aboutMe != null && application.aboutMe!.isNotEmpty)
                      _buildAboutSection(application.aboutMe!),
                    const SizedBox(height: 20),

                    // Education Section
                    _buildInfoSection(
                      'Education',
                      Icons.school_outlined,
                      [
                        if (application.university != null)
                          _buildDetailTile(
                            'University',
                            application.university!,
                            Icons.account_balance,
                          ),
                        if (application.degree != null)
                          _buildDetailTile(
                            'Degree',
                            application.degree!,
                            Icons.school,
                          ),
                        if (application.graduationYear != null)
                          _buildDetailTile(
                            'Graduation Year',
                            application.graduationYear!,
                            Icons.calendar_today,
                          ),
                        if (application.gpa != null)
                          _buildDetailTile(
                            'GPA',
                            '${application.gpa!.toStringAsFixed(1)}/4.0',
                            Icons.grade,
                          ),
                        ...application.education.map((edu) => _buildEducationTile(edu)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Skills Section
                    if (application.skills.isNotEmpty)
                      _buildSkillsSection(application.skills),
                    const SizedBox(height: 20),

                    // Experience Section
                    if (application.experience.isNotEmpty)
                      _buildExperienceSection(application.experience),
                    const SizedBox(height: 20),

                    // Application Details Section
                    _buildInfoSection(
                      'Application Details',
                      Icons.assignment_outlined,
                      [
                        _buildDetailTile(
                          'Position Applied For',
                          application.title ?? 'Internship #${application.internshipID}',
                          Icons.work_outline,
                        ),
                        _buildDetailTile(
                          'Application Date',
                          _formatDate(application.applicationDate),
                          Icons.calendar_today_outlined,
                        ),
                        _buildDetailTile(
                          'Location',
                          application.location ?? 'Not specified',
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contact Information Section
                    _buildInfoSection(
                      'Contact Information',
                      Icons.contact_page_outlined,
                      [
                        _buildDetailTile(
                          'Email Address',
                          application.email ?? 'Not provided',
                          Icons.email_outlined,
                        ),
                        if (application.phone != null && application.phone!.isNotEmpty)
                          _buildDetailTile(
                            'Phone Number',
                            application.phone!,
                            Icons.phone_outlined,
                          ),
                        _buildDetailTile(
                          'Student ID',
                          '#${application.studentID}',
                          Icons.badge_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Portfolio & Social Links Section
                    if (_hasPortfolioLinks(application))
                      _buildPortfolioSection(application),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Resume download feature coming soon!')),
                              );
                            },
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Download Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showStatusDialog(context, application, onStatusChange);
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Update Status'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                              side: BorderSide(color: AppConstants.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildAboutSection(String aboutMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'About',
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            aboutMe,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_outline, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Skills',
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              skill,
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceSection(List<Map<String, dynamic>> experience) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Experience',
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...experience.map((exp) => _buildExperienceCard(exp)).toList(),
      ],
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience['title'] ?? 'Position',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${experience['company'] ?? 'Company'} • ${experience['duration'] ?? 'Duration'}',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (experience['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationTile(Map<String, dynamic> education) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education['degree'] ?? 'Degree',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            education['institution'] ?? 'Institution',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (education['gpa'] != null || education['duration'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '${education['gpa'] ?? ''} • ${education['duration'] ?? ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
          if (education['courses'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Relevant Courses: ${education['courses']}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasPortfolioLinks(Application application) {
    return (application.portfolioUrl != null && application.portfolioUrl!.isNotEmpty) ||
           (application.linkedinUrl != null && application.linkedinUrl!.isNotEmpty) ||
           (application.githubUrl != null && application.githubUrl!.isNotEmpty);
  }

  Widget _buildPortfolioSection(Application application) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Portfolio & Links',
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              if (application.portfolioUrl != null && application.portfolioUrl!.isNotEmpty)
                _buildLinkTile('Portfolio', application.portfolioUrl!, Icons.web, Colors.purple),
              if (application.linkedinUrl != null && application.linkedinUrl!.isNotEmpty)
                _buildLinkTile('LinkedIn', application.linkedinUrl!, Icons.business, Colors.blue[700]!),
              if (application.githubUrl != null && application.githubUrl!.isNotEmpty)
                _buildLinkTile('GitHub', application.githubUrl!, Icons.code, Colors.grey[800]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTile(String title, String url, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, Application application, Function(String) onStatusChange) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Application Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${application.studentName}'),
            const SizedBox(height: 8),
            Text('Position: ${application.title ?? 'Internship #${application.internshipID}'}'),
            const SizedBox(height: 16),
            Text('Select new status:', style: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Use Future.microtask to ensure dialog is fully closed before status update
              Future.microtask(() => onStatusChange('Rejected'));
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Use Future.microtask to ensure dialog is fully closed before status update
              Future.microtask(() => onStatusChange('Accepted'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
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

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InternshipApplicationsTab extends StatelessWidget {
  final Future<void> Function() onRefresh;
  
  const _InternshipApplicationsTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group applications by internship
        final applications = provider.applications;
        final Map<int, List<Application>> applicationsByInternship = {};
        
        for (final app in applications) {
          final internshipId = app.internshipID;
          if (!applicationsByInternship.containsKey(internshipId)) {
            applicationsByInternship[internshipId] = [];
          }
          applicationsByInternship[internshipId]!.add(app);
        }

        if (applicationsByInternship.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No applications for your internships yet',
                        style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applicationsByInternship.keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final internshipId = applicationsByInternship.keys.elementAt(index);
              final internshipApplications = applicationsByInternship[internshipId]!;
              // Use the first application to get internship details
              final sampleApp = internshipApplications.first;
              
              return _InternshipApplicationsCard(
                internshipId: internshipId,
                title: sampleApp.title ?? 'Internship #$internshipId',
                location: sampleApp.location ?? 'Unknown location',
                applications: internshipApplications,
              );
            },
          ),
        );
      },
    );
  }
}

class _InternshipApplicationsCard extends StatelessWidget {
  final int internshipId;
  final String title;
  final String location;
  final List<Application> applications;

  const _InternshipApplicationsCard({
    required this.internshipId,
    required this.title,
    required this.location,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate real application counts
    final totalApplications = applications.length;
    final pendingApplications = applications.where((app) => app.status == 'Pending').length;
    final acceptedApplications = applications.where((app) => app.status == 'Accepted').length;
    final rejectedApplications = applications.where((app) => app.status == 'Rejected').length;

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
              Expanded(
                child: Text(
                  title,
                  style: AppConstants.subheadingStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$totalApplications application${totalApplications != 1 ? 's' : ''}',
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location,
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Pending',
                  value: pendingApplications.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatChip(
                  label: 'Accepted',
                  value: acceptedApplications.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatChip(
                  label: 'Rejected',
                  value: rejectedApplications.toString(),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to detailed applications for this internship
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _InternshipApplicationsDetailScreen(
                      internshipId: internshipId,
                      title: title,
                      location: location,
                      applications: applications,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('View All Applications'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: BorderSide(color: AppConstants.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppConstants.subheadingStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppConstants.bodyStyle.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyApplicationsState extends StatelessWidget {
  final String filter;

  const _EmptyApplicationsState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'All' ? 'No applications yet' : 'No $filter applications',
              style: AppConstants.subheadingStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here when students apply to your internships.',
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InternshipApplicationsDetailScreen extends StatelessWidget {
  final int internshipId;
  final String title;
  final String location;
  final List<Application> applications;

  const _InternshipApplicationsDetailScreen({
    required this.internshipId,
    required this.title,
    required this.location,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applications for $title'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppConstants.subheadingStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Applications',
              style: AppConstants.subheadingStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No applications yet',
                            style: AppConstants.subheadingStyle.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: applications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final application = applications[index];
                        return _CompanyApplicationCard(
                          application: application,
                          onStatusChange: (newStatus) => _updateApplicationStatus(context, application, newStatus),
                        );
                      },
                    ),
              ),
            
          ],
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(BuildContext context, Application application, String newStatus) async {
    // Store references before async operations
    final provider = context.read<ApplicationProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final success = await provider.updateApplicationStatus(
        studentID: application.studentID,
        internshipID: application.internshipID,
        applicationDate: application.applicationDate,
        status: newStatus,
      );
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Application ${newStatus.toLowerCase()} successfully!'),
            backgroundColor: newStatus == 'Accepted' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update application'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error updating application status: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update application: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
