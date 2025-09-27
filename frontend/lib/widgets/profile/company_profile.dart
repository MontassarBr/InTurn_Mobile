import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/company_profile_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'sections/company_info_section.dart';
import 'sections/benefits_section.dart';
import 'sections/reviews_section.dart';
import 'sections/internship_section.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({Key? key}) : super(key: key);

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CompanyProfileProvider>(
      create: (_) => CompanyProfileProvider()..fetchProfile(),
      builder: (context, _) {
        return Consumer<CompanyProfileProvider>(
          builder: (context, provider, __) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Company Profile'),
                backgroundColor: AppConstants.primaryColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    onPressed: () => context.read<AuthProvider>().logout(context),
                    tooltip: 'Logout',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditDialog(context, provider),
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompanyHeaderSection(provider: provider),
                    const SizedBox(height: 16),
                    BenefitsSection(isOwner: true),
                    const SizedBox(height: 16),
                    InternshipSection(isOwner: true),
                    const SizedBox(height: 16),
                    ReviewsSection(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

void _showEditDialog(BuildContext context, CompanyProfileProvider provider) {
  final formKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController(text: provider.companyName);
  final websiteController = TextEditingController(text: provider.website ?? '');
  final industryController = TextEditingController(text: provider.industry ?? '');

  bool isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.business, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Edit Company Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Company Name
                  TextFormField(
                    controller: companyNameController,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Website
                  TextFormField(
                    controller: websiteController,
                    decoration: InputDecoration(
                      labelText: 'Website',
                      hintText: 'https://www.example.com',
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Industry
                  TextFormField(
                    controller: industryController,
                    decoration: InputDecoration(
                      labelText: 'Industry',
                      hintText: 'e.g., Technology, Healthcare, Finance',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'All fields except company name are optional',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);

                      try {
                        final success = await provider.updateProfile({
                          'companyName': companyNameController.text.trim(),
                          'website': websiteController.text.trim().isEmpty
                              ? null
                              : websiteController.text.trim(),
                          'industry': industryController.text.trim().isEmpty
                              ? null
                              : industryController.text.trim(),
                        });

                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    success ? Icons.check_circle : Icons.error,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(success
                                      ? 'Company profile updated successfully!'
                                      : provider.error ?? 'Failed to update profile'),
                                ],
                              ),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) setState(() => isLoading = false);
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
}


}

class _CompanyHeaderSection extends StatelessWidget {
  final CompanyProfileProvider provider;
  const _CompanyHeaderSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.primaryColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.lightPrimaryColor,
                    child: Text(
                      provider.companyName.isNotEmpty ? provider.companyName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.companyName,
                        style: AppConstants.headingStyle.copyWith(fontSize: 24),
                      ),
                      if (provider.industry != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.industry!,
                          style: AppConstants.subheadingStyle.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (provider.website != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.language_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(provider.website!, style: AppConstants.bodyStyle.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
