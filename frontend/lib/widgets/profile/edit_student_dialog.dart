import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_profile_provider.dart';

Future<void> showEditStudentDialog(BuildContext context, StudentProfileProvider provider) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EditStudentDialog(provider: provider),
  );
}

class _EditStudentDialog extends StatefulWidget {
  final StudentProfileProvider provider;

  const _EditStudentDialog({required this.provider});

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController titleController;
  late final TextEditingController aboutController;
  late final TextEditingController phoneController;
  late final TextEditingController universityController;
  late final TextEditingController degreeController;
  late final TextEditingController graduationYearController;
  late final TextEditingController gpaController;
  late final TextEditingController portfolioUrlController;
  late final TextEditingController linkedinUrlController;
  late final TextEditingController githubUrlController;
  
  late bool openToWork;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.provider.firstName);
    lastNameController = TextEditingController(text: widget.provider.lastName);
    titleController = TextEditingController(text: widget.provider.title ?? '');
    aboutController = TextEditingController(text: widget.provider.about ?? '');
    phoneController = TextEditingController(text: widget.provider.phone ?? '');
    universityController = TextEditingController(text: widget.provider.university ?? '');
    degreeController = TextEditingController(text: widget.provider.degree ?? '');
    graduationYearController = TextEditingController(text: widget.provider.graduationYear?.toString() ?? '');
    gpaController = TextEditingController(text: widget.provider.gpa?.toString() ?? '');
    portfolioUrlController = TextEditingController(text: widget.provider.portfolioUrl ?? '');
    linkedinUrlController = TextEditingController(text: widget.provider.linkedinUrl ?? '');
    githubUrlController = TextEditingController(text: widget.provider.githubUrl ?? '');
    
    openToWork = widget.provider.openToWork;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    titleController.dispose();
    aboutController.dispose();
    phoneController.dispose();
    universityController.dispose();
    degreeController.dispose();
    graduationYearController.dispose();
    gpaController.dispose();
    portfolioUrlController.dispose();
    linkedinUrlController.dispose();
    githubUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: firstNameController,
                          label: 'First Name',
                          icon: Icons.person,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Open to Work Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Open to Work',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Switch(
                          value: openToWork,
                          onChanged: (value) => setState(() => openToWork = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Professional Details Section
                  _buildSectionHeader('Professional Details'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: titleController,
                    label: 'Title/Role',
                    hint: 'e.g., Computer Science Student',
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: aboutController,
                    label: 'About',
                    hint: 'Tell us about yourself...',
                    icon: Icons.info_outline,
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 24),

                  // Education Section
                  _buildSectionHeader('Education'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: universityController,
                    label: 'University',
                    hint: 'e.g., Harvard University',
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: degreeController,
                          label: 'Degree',
                          hint: 'e.g., Bachelor of Science',
                          icon: Icons.school,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: graduationYearController,
                          label: 'Graduation Year',
                          hint: '2024',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final year = int.tryParse(value);
                              if (year == null || year < 1900 || year > 2030) {
                                return 'Please enter a valid year';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: gpaController,
                    label: 'GPA',
                    hint: '3.85',
                    icon: Icons.grade,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final gpa = double.tryParse(value);
                        if (gpa == null || gpa < 0 || gpa > 4) {
                          return 'Please enter a valid GPA (0-4)';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Social Links Section
                  _buildSectionHeader('Social Links'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: portfolioUrlController,
                    label: 'Portfolio URL',
                    hint: 'https://yourportfolio.com',
                    icon: Icons.web,
                    keyboardType: TextInputType.url,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: linkedinUrlController,
                    label: 'LinkedIn URL',
                    hint: 'https://linkedin.com/in/yourprofile',
                    icon: Icons.person_pin,
                    keyboardType: TextInputType.url,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: githubUrlController,
                    label: 'GitHub URL',
                    hint: 'https://github.com/yourusername',
                    icon: Icons.code,
                    keyboardType: TextInputType.url,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);

                      try {
                        print('Dialog: Starting profile update...'); // Debug log
                        final success = await widget.provider.updateProfile({
                          'firstName': firstNameController.text.trim(),
                          'lastName': lastNameController.text.trim(),
                          'title': titleController.text.trim().isEmpty ? null : titleController.text.trim(),
                          'about': aboutController.text.trim().isEmpty ? null : aboutController.text.trim(),
                          'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                          'openToWork': openToWork,
                          'university': universityController.text.trim().isEmpty ? null : universityController.text.trim(),
                          'degree': degreeController.text.trim().isEmpty ? null : degreeController.text.trim(),
                          'graduationYear': graduationYearController.text.trim().isEmpty ? null : int.tryParse(graduationYearController.text.trim()),
                          'gpa': gpaController.text.trim().isEmpty ? null : double.tryParse(gpaController.text.trim()),
                          'portfolioUrl': portfolioUrlController.text.trim().isEmpty ? null : portfolioUrlController.text.trim(),
                          'linkedinUrl': linkedinUrlController.text.trim().isEmpty ? null : linkedinUrlController.text.trim(),
                          'githubUrl': githubUrlController.text.trim().isEmpty ? null : githubUrlController.text.trim(),
                        });
                        print('Dialog: Profile update result: $success'); // Debug log

                        if (mounted) {
                          Navigator.of(context).pop();

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
                                      ? 'Profile updated successfully!'
                                      : widget.provider.error ?? 'Failed to update profile'),
                                ],
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      } catch (dialogError) {
                        print('Dialog Error: $dialogError'); // Debug log
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unexpected error: $dialogError'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isLoading = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        alignLabelWithHint: maxLines > 1,
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textAlignVertical: maxLines > 1 ? TextAlignVertical.top : null,
      validator: validator ?? (required ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      } : null),
    );
  }

  String? _urlValidator(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        return 'Please enter a valid URL starting with http:// or https://';
      }
    }
    return null;
  }
}
