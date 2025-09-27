import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/company_profile_provider.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Technology', 'Healthcare', 'Finance', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild when search text changes
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileProvider>().fetchAllCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _SearchAndFilterSection(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
            filterOptions: _filterOptions,
          ),
          Expanded(
            child: Consumer<CompanyProfileProvider>(
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
                          onPressed: () => provider.fetchAllCompanies(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final companies = provider.allCompanies;
                final filteredCompanies = _filterCompanies(companies);

                return filteredCompanies.isEmpty
                    ? _EmptyCompaniesState()
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchAllCompanies(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCompanies.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final company = filteredCompanies[index];
                            return _CompanyCard(company: company);
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

  List<dynamic> _filterCompanies(List<dynamic> companies) {
    var filtered = companies;

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((company) {
        final name = company['companyName']?.toString().toLowerCase() ?? '';
        final industry = company['industry']?.toString().toLowerCase() ?? '';
        final searchText = _searchController.text.toLowerCase();
        return name.contains(searchText) || industry.contains(searchText);
      }).toList();
    }

    // Filter by industry
    if (_selectedFilter != 'All') {
      filtered = filtered.where((company) {
        final industry = company['industry']?.toString().toLowerCase() ?? '';
        return industry.contains(_selectedFilter.toLowerCase());
      }).toList();
    }

    return filtered;
  }
}

class _SearchAndFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const _SearchAndFilterSection({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search companies...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
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
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SizedBox(
            height: 40,
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
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Map<String, dynamic> company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final companyName = company['companyName']?.toString() ?? 'Unknown Company';
    final industry = company['industry']?.toString() ?? '';
    final website = company['website']?.toString() ?? '';
    final description = company['description']?.toString() ?? '';

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
              // Company Logo/Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
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
                      companyName,
                      style: AppConstants.subheadingStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (industry.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        industry,
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showCompanyOptions(context),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
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
              if (website.isNotEmpty) ...[
                Icon(Icons.language_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    website,
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              _CompanyStats(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewCompanyDetails(context),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewCompanyInternships(context),
                  icon: const Icon(Icons.work_outline, size: 16),
                  label: const Text('Internships'),
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

  void _showCompanyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View Company Details'),
              onTap: () {
                Navigator.pop(context);
                _viewCompanyDetails(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('View Internships'),
              onTap: () {
                Navigator.pop(context);
                _viewCompanyInternships(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Rate Company'),
              onTap: () {
                Navigator.pop(context);
                _rateCompany(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Company'),
              onTap: () {
                Navigator.pop(context);
                _shareCompany(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewCompanyDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompanyDetailScreen(company: company),
      ),
    );
  }

  void _viewCompanyInternships(BuildContext context) {
    // Navigate to company's internships
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company internships feature coming soon!')),
    );
  }

  void _rateCompany(BuildContext context) {
    // Show rating dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }

  void _shareCompany(BuildContext context) {
    // Share company
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }
}

class _CompanyStats extends StatelessWidget {
  const _CompanyStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(icon: Icons.work_outline, value: '5+', label: 'Jobs'),
        const SizedBox(width: 12),
        _StatItem(icon: Icons.star, value: '4.5', label: 'Rating'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppConstants.bodyStyle.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppConstants.bodyStyle.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _EmptyCompaniesState extends StatelessWidget {
  const _EmptyCompaniesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Companies Found',
              style: AppConstants.subheadingStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
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
