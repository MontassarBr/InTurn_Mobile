import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/internship_provider.dart';
import '../../models/internship.dart';

class CreateInternshipScreen extends StatefulWidget {
  final Internship? internship; // Optional internship for editing
  
  const CreateInternshipScreen({Key? key, this.internship}) : super(key: key);

  @override
  State<CreateInternshipScreen> createState() => _CreateInternshipScreenState();
}

class _CreateInternshipScreenState extends State<CreateInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPayment = 'paid';
  String _selectedWorkArrangement = 'Remote';
  String _selectedWorkTime = 'Full Time';
  bool _isLoading = false;

  final List<String> _paymentOptions = ['paid', 'unpaid'];
  final List<String> _workArrangementOptions = ['Remote', 'Onsite', 'Hybrid'];
  final List<String> _workTimeOptions = ['Full Time', 'Part Time'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.internship != null) {
      // Pre-fill form fields with existing internship data
      final internship = widget.internship!;
      _titleController.text = internship.title ?? '';
      _descriptionController.text = internship.description ?? '';
      _locationController.text = internship.location ?? '';
      _minSalaryController.text = internship.minSalary?.toString() ?? '';
      _maxSalaryController.text = internship.maxSalary?.toString() ?? '';
      
      // Parse dates
      _startDate = DateTime.tryParse(internship.startDate ?? '');
      _endDate = DateTime.tryParse(internship.endDate ?? '');
      
      // Set dropdown values with null-aware operators
      _selectedPayment = internship.payment ?? 'paid';
      _selectedWorkArrangement = internship.workArrangement ?? 'Remote';
      _selectedWorkTime = internship.workTime ?? 'Full Time';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.internship != null ? 'Edit Internship' : 'Create Internship'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(),
              const SizedBox(height: 24),
              _BasicInfoSection(),
              const SizedBox(height: 24),
              _DetailsSection(),
              const SizedBox(height: 24),
              _DateSection(),
              const SizedBox(height: 24),
              _SalarySection(),
              const SizedBox(height: 32),
              _CreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _HeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.work, size: 32, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Post New Internship',
            style: AppConstants.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the details to create a new internship opportunity',
            style: AppConstants.bodyStyle.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _BasicInfoSection() {
    return _SectionCard(
      title: 'Basic Information',
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Internship Title *',
              hintText: 'e.g., Software Development Intern',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Title is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location *',
              hintText: 'e.g., New York, NY or Remote',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Location is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Job Description *',
              hintText: 'Describe the internship role, responsibilities, and requirements...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Description is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _DetailsSection() {
    return _SectionCard(
      title: 'Work Details',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedWorkArrangement,
            decoration: InputDecoration(
              labelText: 'Work Arrangement',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.work_outline),
            ),
            items: _workArrangementOptions.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: (value) => setState(() => _selectedWorkArrangement = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedWorkTime,
            decoration: InputDecoration(
              labelText: 'Work Time',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.schedule),
            ),
            items: _workTimeOptions.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: (value) => setState(() => _selectedWorkTime = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPayment,
            decoration: InputDecoration(
              labelText: 'Payment Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.payment),
            ),
            items: _paymentOptions.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option.toUpperCase()),
            )).toList(),
            onChanged: (value) => setState(() => _selectedPayment = value!),
          ),
        ],
      ),
    );
  }

  Widget _DateSection() {
    return _SectionCard(
      title: 'Duration',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _startDate != null 
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Select start date',
                      style: _startDate != null 
                          ? null 
                          : TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _endDate != null 
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Select end date',
                      style: _endDate != null 
                          ? null 
                          : TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days',
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _SalarySection() {
    return _SectionCard(
      title: 'Compensation (Optional)',
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _minSalaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Min Salary (\$)',
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  final salary = double.tryParse(value!);
                  if (salary == null || salary < 0) {
                    return 'Enter valid amount';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _maxSalaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Max Salary (\$)',
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  final salary = double.tryParse(value!);
                  if (salary == null || salary < 0) {
                    return 'Enter valid amount';
                  }
                  final minSalary = double.tryParse(_minSalaryController.text);
                  if (minSalary != null && salary < minSalary) {
                    return 'Max must be ≥ min';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _CreateButton() {
    final isEditing = widget.internship != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitInternship,
        icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(isEditing ? Icons.edit : Icons.add_circle),
        label: Text(_isLoading 
            ? (isEditing ? 'Updating...' : 'Creating...') 
            : (isEditing ? 'Update Internship' : 'Create Internship')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _SectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: AppConstants.subheadingStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _submitInternship() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final internshipData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'startDate': _startDate!.toIso8601String().split('T')[0],
        'endDate': _endDate!.toIso8601String().split('T')[0],
        'workArrangement': _selectedWorkArrangement,
        'workTime': _selectedWorkTime,
        'payment': _selectedPayment,
        if (_minSalaryController.text.isNotEmpty)
          'minSalary': double.parse(_minSalaryController.text),
        if (_maxSalaryController.text.isNotEmpty)
          'maxSalary': double.parse(_maxSalaryController.text),
      };

      final internshipProvider = context.read<InternshipProvider>();
      final bool success;
      
      if (widget.internship != null) {
        // Update existing internship
        success = await internshipProvider.updateInternship(widget.internship!.internshipID, internshipData);
      } else {
        // Create new internship
        success = await internshipProvider.createInternship(internshipData);
      }

      if (mounted) {
        final isEditing = widget.internship != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? (isEditing ? 'Internship updated successfully!' : 'Internship created successfully!')
              : internshipProvider.error ?? (isEditing ? 'Failed to update internship' : 'Failed to create internship')),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final isEditing = widget.internship != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Failed to update internship: $e' : 'Failed to create internship: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
