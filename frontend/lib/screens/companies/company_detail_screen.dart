import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/company_profile_provider.dart';
import '../../providers/internship_provider.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyDetailScreen({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      body: CustomScrollView(
        slivers: [
          _AppBarSection(company: widget.company),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _HeaderSection(company: widget.company),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppConstants.primaryColor,
                  labelColor: AppConstants.primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(text: 'About', icon: Icon(Icons.info_outline)),
                    Tab(text: 'Internships', icon: Icon(Icons.work_outline)),
                    Tab(text: 'Reviews', icon: Icon(Icons.star_outline)),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AboutTab(company: widget.company),
                      _InternshipsTab(company: widget.company),
                      _ReviewsTab(company: widget.company),
                    ],
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

class _AppBarSection extends StatelessWidget {
  final Map<String, dynamic> company;

  const _AppBarSection({required this.company});

  @override
  Widget build(BuildContext context) {
    final companyName = company['companyName']?.toString() ?? 'Company';
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // Share company
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        _showCompanyOptions(context);
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (company['industry'] != null)
                      Text(
                        company['industry'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    if (company['website'] != null)
                      Text(
                        company['website'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
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
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Company'),
              onTap: () {
                Navigator.pop(context);
                _shareCompany(context);
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
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Company'),
              onTap: () {
                Navigator.pop(context);
                _reportCompany(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareCompany(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _rateCompany(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }

  void _reportCompany(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report feature coming soon!')),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Map<String, dynamic> company;

  const _HeaderSection({required this.company});

  @override
  Widget build(BuildContext context) {
    final companyName = company['companyName']?.toString() ?? 'Company';
    final industry = company['industry']?.toString() ?? '';
    final website = company['website']?.toString() ?? '';
    final description = company['description']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
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
                      style: AppConstants.headingStyle.copyWith(fontSize: 24),
                    ),
                    if (industry.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        industry,
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (website.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.language_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            website,
                            style: AppConstants.bodyStyle.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: AppConstants.bodyStyle.copyWith(
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _CompanyStats(),
        ],
      ),
    );
  }
}

class _CompanyStats extends StatelessWidget {
  const _CompanyStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.work_outline,
          value: '15+',
          label: 'Open Positions',
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.star,
          value: '4.5',
          label: 'Rating',
          color: Colors.orange,
        ),
        const SizedBox(width: 16),
        _StatCard(
          icon: Icons.people_outline,
          value: '50-200',
          label: 'Employees',
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Map<String, dynamic> company;

  const _AboutTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Company Information',
            items: [
              _InfoItem(
                label: 'Industry',
                value: company['industry']?.toString() ?? 'Not specified',
              ),
              _InfoItem(
                label: 'Website',
                value: company['website']?.toString() ?? 'Not available',
              ),
              _InfoItem(
                label: 'Founded',
                value: '2020', // Mock data
              ),
              _InfoItem(
                label: 'Company Size',
                value: '50-200 employees',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'Company Culture',
            items: [
              _InfoItem(
                label: 'Work Environment',
                value: 'Remote-friendly, Collaborative',
              ),
              _InfoItem(
                label: 'Benefits',
                value: 'Health insurance, Flexible hours, Learning opportunities',
              ),
              _InfoItem(
                label: 'Values',
                value: 'Innovation, Teamwork, Growth, Diversity',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'What We Do',
            items: [
              _InfoItem(
                label: 'Mission',
                value: 'To provide innovative solutions and create meaningful impact in the technology industry.',
              ),
              _InfoItem(
                label: 'Focus Areas',
                value: 'Software Development, Data Analytics, AI/ML, Cloud Computing',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppConstants.headingStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.label}: ',
                    style: AppConstants.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: AppConstants.bodyStyle.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem({required this.label, required this.value});
}

class _InternshipsTab extends StatelessWidget {
  final Map<String, dynamic> company;

  const _InternshipsTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternshipProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: AppConstants.subheadingStyle.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final internships = provider.internships;
        final companyInternships = internships.where((internship) {
          // In a real app, you would filter by company ID
          return true; // For now, show all internships
        }).toList();

        return companyInternships.isEmpty
            ? _EmptyInternshipsState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: companyInternships.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final internship = companyInternships[index];
                  return _InternshipCard(internship: internship);
                },
              );
      },
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final dynamic internship;

  const _InternshipCard({required this.internship});

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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
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
                Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  internship.workArrangement,
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
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '\$${internship.minSalary.toStringAsFixed(0)} - \$${internship.maxSalary.toStringAsFixed(0)}',
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
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to internship details
                  },
                  child: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply to internship
                  },
                  child: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyInternshipsState extends StatelessWidget {
  const _EmptyInternshipsState();

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
              'No Internships Available',
              style: AppConstants.subheadingStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This company doesn\'t have any open internship positions at the moment.',
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

class _ReviewsTab extends StatelessWidget {
  final Map<String, dynamic> company;

  const _ReviewsTab({required this.company});

  @override
  Widget build(BuildContext context) {
    // Mock reviews data
    final reviews = [
      {
        'name': 'Sarah Johnson',
        'rating': 5,
        'date': '2 months ago',
        'title': 'Great learning experience',
        'content': 'The internship provided excellent opportunities to learn and grow. The team was supportive and the projects were challenging.',
        'role': 'Software Development Intern',
      },
      {
        'name': 'Michael Chen',
        'rating': 4,
        'date': '3 months ago',
        'title': 'Good company culture',
        'content': 'The company has a great culture and work environment. The mentorship program is particularly helpful.',
        'role': 'Data Science Intern',
      },
      {
        'name': 'Emily Rodriguez',
        'rating': 5,
        'date': '4 months ago',
        'title': 'Amazing experience',
        'content': 'I learned so much during my internship. The projects were interesting and the team was very welcoming.',
        'role': 'Marketing Intern',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewCard(review: review);
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  review['name'][0],
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
                      review['name'],
                      style: AppConstants.subheadingStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review['role'],
                      style: AppConstants.bodyStyle.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review['date'],
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['title'],
            style: AppConstants.subheadingStyle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review['content'],
            style: AppConstants.bodyStyle.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
