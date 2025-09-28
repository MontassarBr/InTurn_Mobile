import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/internship.dart';
import 'package:provider/provider.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import 'internship_detail_screen.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({Key? key}) : super(key: key);

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All';
  String _selectedWorkTime = 'All';
  String _selectedWorkArrangement = 'All';
  String _selectedPayment = 'All';

  final List<String> _locations = ['All', 'Remote', 'New York', 'San Francisco', 'London', 'Berlin'];
  final List<String> _workTimes = ['All', 'Full Time', 'Part Time'];
  final List<String> _workArrangements = ['All', 'Remote', 'Onsite', 'Hybrid'];
  final List<String> _payments = ['All', 'paid', 'unpaid'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipProvider>().fetchInternships();
      context.read<ApplicationProvider>().fetchMyApplications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_selectedLocation != 'All') filters['location'] = _selectedLocation;
    if (_selectedWorkTime != 'All') filters['workTime'] = _selectedWorkTime;
    if (_selectedWorkArrangement != 'All') filters['workArrangement'] = _selectedWorkArrangement;
    if (_selectedPayment != 'All') filters['payment'] = _selectedPayment;
    
    context.read<InternshipProvider>().fetchInternships(filters: filters);
  }

  List<Internship> _filterInternships(List<Internship> internships) {
    if (_searchController.text.isEmpty) return internships;
    
    final searchTerm = _searchController.text.toLowerCase();
    return internships.where((internship) {
      return internship.title.toLowerCase().contains(searchTerm) ||
             internship.location.toLowerCase().contains(searchTerm) ||
             (internship.description?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internships'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(),
          Expanded(
            child: Consumer2<InternshipProvider, ApplicationProvider>(
              builder: (context, internshipProvider, applicationProvider, _) {
                if (internshipProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (internshipProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          internshipProvider.error!,
                          style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => internshipProvider.fetchInternships(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredInternships = _filterInternships(internshipProvider.internships);
                
                if (filteredInternships.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No internships found',
                          style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: AppConstants.bodyStyle.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => internshipProvider.fetchInternships(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredInternships.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final internship = filteredInternships[index];
                      final hasApplied = applicationProvider.hasAppliedToInternship(internship.internshipID);
                      return _InternshipCard(
                        internship: internship,
                        hasApplied: hasApplied,
                        onTap: () => _navigateToDetail(internship),
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

  Widget _SearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search internships...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  void _navigateToDetail(Internship internship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternshipDetailScreen(internship: internship),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedLocation = 'All';
                        _selectedWorkTime = 'All';
                        _selectedWorkArrangement = 'All';
                        _selectedPayment = 'All';
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _FilterDropdown('Location', _selectedLocation, _locations, (value) {
                setModalState(() => _selectedLocation = value!);
              }),
              _FilterDropdown('Work Time', _selectedWorkTime, _workTimes, (value) {
                setModalState(() => _selectedWorkTime = value!);
              }),
              _FilterDropdown('Work Arrangement', _selectedWorkArrangement, _workArrangements, (value) {
                setModalState(() => _selectedWorkArrangement = value!);
              }),
              _FilterDropdown('Payment', _selectedPayment, _payments, (value) {
                setModalState(() => _selectedPayment = value!);
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _FilterDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final Internship internship;
  final bool hasApplied;
  final VoidCallback onTap;

  const _InternshipCard({
    required this.internship,
    required this.hasApplied,
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
      child: Material(
        color: Colors.transparent,
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
                            maxLines: 2,
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
                    if (hasApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Applied',
                          style: TextStyle(
                            color: Colors.green[700],
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
                if (internship.description != null) ...[
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (internship.payment != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: internship.payment == 'paid' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          internship.payment!.toUpperCase(),
                          style: TextStyle(
                            color: internship.payment == 'paid' ? Colors.green[700] : Colors.orange[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
