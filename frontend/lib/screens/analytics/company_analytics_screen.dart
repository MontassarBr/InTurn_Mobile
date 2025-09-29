import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import '../../utils/constants.dart';

class CompanyAnalyticsScreen extends StatefulWidget {
  const CompanyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<CompanyAnalyticsScreen> createState() => _CompanyAnalyticsScreenState();
}

class _CompanyAnalyticsScreenState extends State<CompanyAnalyticsScreen> {
  int? _companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final idStr = prefs.getString(AppConstants.userIdKey);
    final userType = prefs.getString(AppConstants.userTypeKey);
    if (idStr != null && userType == AppConstants.companyType) {
      setState(() => _companyId = int.parse(idStr));
    }
    await context.read<InternshipProvider>().fetchInternships();
    if (_companyId != null) {
      await context.read<ApplicationProvider>().fetchApplicationsForCompany(_companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Consumer2<InternshipProvider, ApplicationProvider>(
        builder: (context, internships, applications, _) {
          final companyInternships = (_companyId == null)
              ? internships.internships
              : internships.internships.where((i) => i.companyID == _companyId).toList();

          final totalInternships = companyInternships.length;
          final published = companyInternships.where((i) => i.status.toLowerCase() == 'published').length;
          final drafts = companyInternships.where((i) => i.status.toLowerCase() != 'published').length;

          final apps = applications.applications;
          final totalApps = apps.length;
          final pending = apps.where((a) => a.status == 'Pending').length;
          final accepted = apps.where((a) => a.status == 'Accepted').length;
          final rejected = apps.where((a) => a.status == 'Rejected').length;

          final isLoading = internships.loading || applications.loading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _init,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MetricCard(title: 'Total Internships', value: totalInternships.toString(), color: AppConstants.primaryColor, icon: Icons.work_outline),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _MetricCard(title: 'Published', value: published.toString(), color: Colors.green, icon: Icons.check_circle_outline)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Draft/Other', value: drafts.toString(), color: Colors.orange, icon: Icons.pending_outlined)),
                ]),
                const SizedBox(height: 20),
                _SectionHeader('Applications'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _MetricCard(title: 'Total', value: totalApps.toString(), color: Colors.blue, icon: Icons.assignment_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Pending', value: pending.toString(), color: Colors.orange, icon: Icons.schedule_outlined)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _MetricCard(title: 'Accepted', value: accepted.toString(), color: Colors.green, icon: Icons.thumb_up_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Rejected', value: rejected.toString(), color: Colors.red, icon: Icons.thumb_down_outlined)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.analytics_outlined, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(title, style: AppConstants.bodyStyle.copyWith(fontSize: 12, color: Colors.grey[600])))]),
        const SizedBox(height: 8),
        Text(value, style: AppConstants.headingStyle.copyWith(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}


