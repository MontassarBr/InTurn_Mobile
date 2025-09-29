import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/company_profile_provider.dart';
import '../../providers/saved_internship_provider.dart';
import '../../models/internship.dart';
import '../companies/company_detail_screen.dart';

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
      final applicationProvider = context.read<ApplicationProvider>();
      final success = await applicationProvider.applyToInternship(widget.internship.internshipID);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Application submitted successfully!' 
              : applicationProvider.error ?? 'Failed to apply'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          Navigator.of(context).pop(); // Go back to internships list
        }
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
                top: 50, // Moved down from 16 to 50 to avoid status bar
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Consumer<SavedInternshipProvider>(
                        builder: (context, savedProvider, _) {
                          final isSaved = savedProvider.isInternshipSaved(internship.internshipID);
                          return IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            tooltip: isSaved ? 'Remove from saved' : 'Save internship',
                            onPressed: () async {
                              if (isSaved) {
                                final success = await savedProvider.unsaveInternship(internship.internshipID);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Internship removed from saved!'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              } else {
                                final success = await savedProvider.saveInternship(internship.internshipID);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Internship saved!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share feature coming soon!')),
                          );
                        },
                        tooltip: 'Share Internship',
                      ),
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
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(Icons.business_outlined, color: AppConstants.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'About the Company',
                    style: AppConstants.headingStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Company Logo Circle
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
                        // Show first letter of company name or 'C' if no company name
                        (internship.companyName != null && internship.companyName!.isNotEmpty)
                            ? internship.companyName![0].toUpperCase()
                            : 'C',
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
                          internship.companyName ?? 'Company Name',
                          style: AppConstants.subheadingStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          internship.industry ?? 'Technology • Growing Company',
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'About the Company',
                          style: AppConstants.subheadingStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getCompanyDescription(internship),
                      style: AppConstants.bodyStyle.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CompanyDetailScreen(
                              company: {
                                'id': internship.companyID,
                                'companyName': internship.companyName ?? 'Company Name',
                                'industry': internship.industry ?? 'Technology',
                                'description': _getCompanyDescription(internship),
                                // Add more company details as needed
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.business, size: 16),
                      label: const Text('View Company'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  String _getCompanyDescription(Internship internship) {
    final companyName = internship.companyName ?? 'this company';
    final industry = internship.industry ?? 'Technology';
    
    // Generate dynamic company descriptions based on industry and company name
    final descriptions = {
      'Technology': [
        '$companyName is a forward-thinking technology company that specializes in cutting-edge software solutions. We foster innovation, embrace emerging technologies, and provide an environment where talented individuals can grow their careers in the tech industry.',
        'As a leading technology firm, $companyName is dedicated to creating innovative solutions that drive digital transformation. Our team of experts works on challenging projects that make a real impact in the technology sector.',
        '$companyName combines technical excellence with creative innovation to deliver world-class software products. We believe in empowering our team members with the tools and opportunities they need to succeed in their careers.',
      ],
      'Healthcare': [
        '$companyName is committed to improving healthcare outcomes through innovative solutions and dedicated service. We work at the intersection of healthcare and technology to create meaningful impact in people\'s lives.',
        'At $companyName, we believe that quality healthcare should be accessible to everyone. Our team is passionate about developing solutions that enhance patient care and support healthcare professionals.',
      ],
      'Finance': [
        '$companyName provides comprehensive financial services with a focus on innovation and customer satisfaction. We leverage cutting-edge technology to deliver secure, efficient financial solutions.',
        'As a trusted financial institution, $companyName combines traditional banking values with modern fintech innovations to serve our clients better and create opportunities for professional growth.',
      ],
      'Education': [
        '$companyName is dedicated to transforming education through innovative approaches and technology integration. We believe in empowering learners and educators with tools that enhance the educational experience.',
        'At $companyName, we are passionate about education and committed to creating learning solutions that prepare students for future success. Our team works on projects that make education more accessible and engaging.',
      ],
    };

    final industryDescriptions = descriptions[industry];
    if (industryDescriptions != null && industryDescriptions.isNotEmpty) {
      // Use a simple hash to consistently select the same description for the same company
      final index = (companyName.hashCode % industryDescriptions.length).abs();
      return industryDescriptions[index];
    }

    // Default description for unknown industries
    return '$companyName is a dynamic and innovative company in the $industry sector. We are committed to excellence, innovation, and providing meaningful opportunities for professional growth. Our team works on exciting projects that make a real impact in our industry and beyond.';
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
    // Hide application actions for Company accounts
    final isCompany = () {
      // We don't have direct access to SharedPreferences here; infer via provider or fallback to hiding when company tab is active.
      // Simpler: check if Applications tab shows company applications by looking for ApplicationProvider? We'll instead fetch from SharedPreferences.
      return false;
    }();

    // We'll guard the UI below by user type pulled from SharedPreferences asynchronously using FutureBuilder
    // to avoid blocking rebuilds.
    return FutureBuilder<String?>(
      future: _getUserType(),
      builder: (context, snapshot) {
        final userType = snapshot.data;
        final hideApply = userType == AppConstants.companyType;
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
          if (!hideApply)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isApplying ? null : () {
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
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'You are logged in as a company. Applying is available to students only.',
                style: AppConstants.bodyStyle.copyWith(color: Colors.grey[600]),
              ),
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
      },
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

Future<String?> _getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(AppConstants.userTypeKey);
}
