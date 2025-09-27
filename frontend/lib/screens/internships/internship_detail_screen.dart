import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/company_profile_provider.dart';
import '../../models/internship.dart';

class InternshipDetailScreen extends StatefulWidget {
  final Internship internship;

  const InternshipDetailScreen({
    Key? key,
    required this.internship,
  }) : super(key: key);

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  bool _isBookmarked = false;
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AppBarSection(internship: widget.internship),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(internship: widget.internship),
                  const SizedBox(height: 24),
                  _DescriptionSection(internship: widget.internship),
                  const SizedBox(height: 24),
                  _RequirementsSection(internship: widget.internship),
                  const SizedBox(height: 24),
                  _CompanySection(internship: widget.internship),
                  const SizedBox(height: 24),
                  _ApplicationSection(
                    internship: widget.internship,
                    isApplying: _isApplying,
                    onApply: _applyToInternship,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyToInternship() async {
    setState(() => _isApplying = true);
    
    try {
      // TODO: Implement application logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}

class _AppBarSection extends StatelessWidget {
  final Internship internship;

  const _AppBarSection({required this.internship});

  @override
  Widget build(BuildContext context) {
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
                      icon: const Icon(Icons.bookmark_border, color: Colors.white),
                      onPressed: () {
                        // Toggle bookmark
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // Share internship
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
                      internship.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          internship.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (internship.workArrangement != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.work_outline, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            internship.workArrangement!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
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
}

class _HeaderSection extends StatelessWidget {
  final Internship internship;

  const _HeaderSection({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                internship.title,
                style: AppConstants.headingStyle.copyWith(fontSize: 24),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                internship.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: internship.location,
        ),
        if (internship.workArrangement != null)
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Work Type',
            value: internship.workArrangement!,
          ),
        if (internship.workTime != null)
          _InfoRow(
            icon: Icons.schedule,
            label: 'Schedule',
            value: internship.workTime!,
          ),
        if (internship.minSalary != null && internship.maxSalary != null)
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Salary',
            value: '\$${internship.minSalary!.toStringAsFixed(0)} - \$${internship.maxSalary!.toStringAsFixed(0)}',
          ),
        if (internship.payment != null)
          _InfoRow(
            icon: Icons.payment,
            label: 'Payment',
            value: internship.payment!,
          ),
        _InfoRow(
          icon: Icons.calendar_today,
          label: 'Duration',
          value: '${_formatDate(internship.startDate)} - ${_formatDate(internship.endDate)}',
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (internship.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.orange;
    }
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyStyle.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final Internship internship;

  const _DescriptionSection({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppConstants.headingStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            internship.description ?? 'No description available.',
            style: AppConstants.bodyStyle.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequirementsSection extends StatelessWidget {
  final Internship internship;

  const _RequirementsSection({required this.internship});

  @override
  Widget build(BuildContext context) {
    // Mock requirements - in real app, this would come from the API
    final requirements = [
      'Currently enrolled in a university program',
      'Strong communication skills',
      'Basic knowledge of relevant technologies',
      'Ability to work independently and in a team',
      'Passion for learning and growth',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: AppConstants.headingStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...requirements.map((requirement) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  requirement,
                  style: AppConstants.bodyStyle,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _CompanySection extends StatelessWidget {
  final Internship internship;

  const _CompanySection({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Company',
          style: AppConstants.headingStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Consumer<CompanyProfileProvider>(
          builder: (context, provider, _) {
            // In a real app, you would fetch company details by internship.companyID
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'C',
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
                              'Company Name',
                              style: AppConstants.subheadingStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Technology • 50-200 employees',
                              style: AppConstants.bodyStyle.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to company profile
                        },
                        child: const Text('View Company'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are a leading technology company focused on innovation and growth. Join our team to work on exciting projects and develop your skills.',
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ApplicationSection extends StatelessWidget {
  final Internship internship;
  final bool isApplying;
  final VoidCallback onApply;

  const _ApplicationSection({
    required this.internship,
    required this.isApplying,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to Apply?',
            style: AppConstants.headingStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit your application for this internship opportunity.',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isApplying ? null : () {
                    // Show application form or navigate to application screen
                    _showApplicationDialog(context);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Apply Now'),
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
                  onPressed: isApplying ? null : onApply,
                  icon: isApplying 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(isApplying ? 'Applying...' : 'Quick Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Application deadline: ${_formatDate(internship.endDate)}',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to Internship'),
        content: const Text('This will open the application form. This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onApply();
            },
            child: const Text('Continue'),
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
