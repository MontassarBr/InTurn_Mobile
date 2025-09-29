import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/internship.dart';
import '../internships/internship_detail_screen.dart';

class CompanyInternshipsScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyInternshipsScreen({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanyInternshipsScreen> createState() => _CompanyInternshipsScreenState();
}

class _CompanyInternshipsScreenState extends State<CompanyInternshipsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Active', 'Remote', 'Hybrid', 'Onsite'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipProvider>().fetchInternships();
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyName = widget.company['companyName'] ?? widget.company['name'] ?? 'Company';
    
    // Handle both string and int company IDs
    final companyIdRaw = widget.company['companyID'] ?? widget.company['id'] ?? 0;
    final companyId = companyIdRaw is String ? int.tryParse(companyIdRaw) ?? 0 : companyIdRaw as int;
    
    // Debug: Print company data to see what we're working with
    print('Company data: ${widget.company}');
    print('Company name: $companyName');
    print('Company ID: $companyId (original: $companyIdRaw)');

    return Scaffold(
      appBar: AppBar(
        title: Text('$companyName Internships'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Company Header
          _CompanyHeader(company: widget.company),
          
          // Filter Section
          _FilterSection(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
            filterOptions: _filterOptions,
          ),
          
          // Internships List
          Expanded(
            child: Consumer<InternshipProvider>(
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
                          onPressed: () => provider.fetchInternships(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter internships by company
                print('Total internships: ${provider.internships.length}');
                print('Looking for companyID: $companyId');
                
                final companyInternships = provider.internships
                    .where((internship) {
                      print('Internship ${internship.title} has companyID: ${internship.companyID}');
                      return internship.companyID == companyId;
                    })
                    .toList();
                
                print('Found ${companyInternships.length} internships for this company');

                final filteredInternships = _filterInternships(companyInternships);
                
                print('Filtered internships: ${filteredInternships.length}');

                return filteredInternships.isEmpty
                    ? _EmptyInternshipsState(
                        companyName: companyName, 
                        filter: _selectedFilter,
                        totalInternships: provider.internships.length,
                        companyId: companyId,
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchInternships(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredInternships.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final internship = filteredInternships[index];
                            return _InternshipCard(
                              internship: internship,
                              onTap: () => _navigateToInternshipDetail(context, internship),
                            );
                          },
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Internship> _filterInternships(List<Internship> internships) {
    switch (_selectedFilter.toLowerCase()) {
      case 'active':
        return internships.where((i) => i.status.toLowerCase() == 'active').toList();
      case 'remote':
        return internships.where((i) => i.workArrangement?.toLowerCase().contains('remote') ?? false).toList();
      case 'hybrid':
        return internships.where((i) => i.workArrangement?.toLowerCase().contains('hybrid') ?? false).toList();
      case 'onsite':
        return internships.where((i) => i.workArrangement?.toLowerCase().contains('onsite') ?? false).toList();
      default:
        return internships;
    }
  }

  void _navigateToInternshipDetail(BuildContext context, Internship internship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternshipDetailScreen(internship: internship),
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final Map<String, dynamic> company;

  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context) {
    final companyName = company['companyName'] ?? company['name'] ?? 'Company Name';
    final industry = company['industry'] ?? 'Technology';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Company Logo
          Container(
            width: 60,
            height: 60,
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
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: AppConstants.subheadingStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$industry • Available Opportunities',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
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

class _FilterSection extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const _FilterSection({
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

class _InternshipCard extends StatelessWidget {
  final Internship internship;
  final VoidCallback onTap;

  const _InternshipCard({
    required this.internship,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(internship.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      internship.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(internship.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Location and Work Arrangement
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
              
              // Salary
              if (internship.minSalary != null && internship.maxSalary != null) ...[
                const SizedBox(height: 8),
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
              
              // Description
              if (internship.description != null && internship.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  internship.description!,
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Action Buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewInternshipDetails(context),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        side: BorderSide(color: AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _applyToInternship(context),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewInternshipDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternshipDetailScreen(internship: internship),
      ),
    );
  }

  void _applyToInternship(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final applicationProvider = context.read<ApplicationProvider>();
      final success = await applicationProvider.applyToInternship(internship.internshipID);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(applicationProvider.error ?? 'Failed to apply'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'draft':
        return Colors.orange;
      default:
        return AppConstants.primaryColor;
    }
  }
}

class _EmptyInternshipsState extends StatelessWidget {
  final String companyName;
  final String filter;
  final int totalInternships;
  final int companyId;

  const _EmptyInternshipsState({
    required this.companyName,
    required this.filter,
    required this.totalInternships,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
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
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (filter == 'All') {
      return 'No Internships Available';
    }
    return 'No ${filter} Internships';
  }

  String _getEmptyStateMessage() {
    if (filter == 'All') {
      return '$companyName doesn\'t have any internship opportunities available at the moment. Check back later for new postings.';
    }
    return '$companyName doesn\'t have any $filter internships available right now. Try changing the filter or check back later.';
  }
}
