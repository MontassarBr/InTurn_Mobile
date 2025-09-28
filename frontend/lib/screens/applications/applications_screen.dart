import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/application_provider.dart';
import '../../providers/internship_provider.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../internships/internship_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Pending', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchMyApplications();
      context.read<InternshipProvider>().fetchInternships();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Applications', icon: Icon(Icons.assignment_outlined)),
            Tab(text: 'Saved', icon: Icon(Icons.bookmark_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ApplicationsTab(
            selectedFilter: _selectedFilter, 
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
            filterOptions: _filterOptions,
          ),
          _SavedTab(),
        ],
      ),
    );
  }
}

class _ApplicationsTab extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const _ApplicationsTab({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApplicationProvider, InternshipProvider>(
      builder: (context, appProvider, internshipProvider, _) {
        if (appProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  appProvider.error!,
                  style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => appProvider.fetchMyApplications(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final applications = appProvider.applications;
        final filteredApplications = _filterApplications(applications, selectedFilter);

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
                      onRefresh: () => appProvider.fetchMyApplications(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredApplications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final application = filteredApplications[index];
                          return _ApplicationCard(
                            application: application,
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

  List<Application> _filterApplications(List<Application> applications, String filter) {
    if (filter == 'All') return applications;
    return applications.where((app) => app.status.toLowerCase() == filter.toLowerCase()).toList();
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

class _ApplicationCard extends StatelessWidget {
  final Application application;

  const _ApplicationCard({
    required this.application,
  });

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

    return GestureDetector(
      onTap: () {
        // Get the internship provider to find the internship by ID
        final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
        
        // Find the internship by ID
        final internship = internshipProvider.internships.firstWhere(
          (internship) => internship.internshipID == application.internshipID,
          orElse: () => Internship(
            internshipID: application.internshipID,
            title: application.title ?? 'Unknown Internship',
            description: '',
            location: application.location ?? '',
            status: '',
            companyID: application.companyID ?? 0,
            startDate: '',
            endDate: '',
          ),
        );
        
        // Navigate to internship detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InternshipDetailScreen(internship: internship),
          ),
        );
      },
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
                    // Show first letter of company name or 'C' if no company name
                    (application.companyName != null && application.companyName!.isNotEmpty)
                        ? application.companyName![0].toUpperCase()
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
                      application.title ?? 'Internship #${application.internshipID}',
                      style: AppConstants.subheadingStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (application.companyName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        application.companyName!,
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (application.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              application.location!,
                              style: AppConstants.bodyStyle.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (application.minSalary != null && application.maxSalary != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '\$${application.minSalary!.toInt()} - \$${application.maxSalary!.toInt()}',
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
                      application.status.toUpperCase(),
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
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Applied on ${_formatDate(application.applicationDate)}',
                style: AppConstants.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (application.status.toLowerCase() == 'pending')
                Text(
                  'Under Review',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (application.status.toLowerCase() == 'accepted') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Congratulations! Your application has been accepted.',
                      style: AppConstants.bodyStyle.copyWith(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (application.status.toLowerCase() == 'rejected') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unfortunately, your application was not selected this time.',
                      style: AppConstants.bodyStyle.copyWith(
                        color: Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
              _getEmptyStateIcon(),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: AppConstants.subheadingStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            if (filter == 'All') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to internships screen
                  DefaultTabController.of(context)?.animateTo(1);
                },
                icon: const Icon(Icons.search),
                label: const Text('Browse Internships'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (filter.toLowerCase()) {
      case 'pending':
        return Icons.schedule_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _getEmptyStateTitle() {
    switch (filter.toLowerCase()) {
      case 'pending':
        return 'No Pending Applications';
      case 'accepted':
        return 'No Accepted Applications';
      case 'rejected':
        return 'No Rejected Applications';
      default:
        return 'No Applications Yet';
    }
  }

  String _getEmptyStateMessage() {
    switch (filter.toLowerCase()) {
      case 'pending':
        return 'You don\'t have any applications under review at the moment.';
      case 'accepted':
        return 'You haven\'t been accepted for any internships yet. Keep applying!';
      case 'rejected':
        return 'You don\'t have any rejected applications. That\'s a good sign!';
      default:
        return 'Start applying to internships to track your applications here.';
    }
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Internships',
              style: AppConstants.subheadingStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save internships you\'re interested in to view them here.',
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to internships screen
                DefaultTabController.of(context)?.animateTo(1);
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Internships'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
