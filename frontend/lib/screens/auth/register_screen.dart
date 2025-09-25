import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/social_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _roleNotifier = ValueNotifier<String>(AppConstants.studentType);
  final List<bool> _selections = [true, false];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleNotifier.dispose();
    super.dispose();
  }

  void _submit() {
    final userType = _roleNotifier.value;
    if (_formKey.currentState!.validate()) {
      final payload = <String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'userType': userType,
      };
      if (userType == AppConstants.studentType) {
        payload['firstName'] = _firstNameController.text.trim();
        payload['lastName'] = _lastNameController.text.trim();
      } else {
        payload['companyName'] = _companyNameController.text.trim();
      }
      context.read<AuthProvider>().register(
            payload: payload,
            context: context,
          );
  }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.black87)),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text('Create Account', style: AppConstants.headingStyle),
                      const SizedBox(height: 4),
                      Container(height: 2, width: 60, color: AppConstants.primaryColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ToggleButtons(
                    isSelected: _selections,
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    color: AppConstants.primaryTextColor,
                    fillColor: AppConstants.primaryColor,
                    constraints: const BoxConstraints(minWidth: 140, minHeight: 40),
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < _selections.length; i++) {
                          _selections[i] = i == index;
                        }
                        _roleNotifier.value = index == 0 ? AppConstants.studentType : AppConstants.companyType;
                      });
                    },
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.school), SizedBox(width: 6), Text('Student')],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.business), SizedBox(width: 6), Text('Company')],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<String>(
                  valueListenable: _roleNotifier,
                  builder: (context, value, _) {
                    if (value == AppConstants.studentType) {
                      return Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter first name' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter last name' : null,
                          ),
                        ],
                      );
                    } else {
                      return TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter company name' : null,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter email';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter password';
                    if (value.length < 6) return 'Too short';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: authProvider.status == AuthStatus.loading ? null : _submit,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: authProvider.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up'),
                  ),
                ),

                const SizedBox(height: 16),
                Row(children: const [Expanded(child: Divider()), SizedBox(width: 8), Text('or continue with'), SizedBox(width: 8), Expanded(child: Divider())]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: FontAwesomeIcons.google,
                      backgroundColor: const Color(0xFFDB4437),
                    ),
                    const SizedBox(width: 16),
                    SocialIconButton(
                      icon: FontAwesomeIcons.apple,
                      backgroundColor: Colors.black,
                    ),
                    const SizedBox(width: 16),
                    SocialIconButton(
                      icon: FontAwesomeIcons.facebookF,
                      backgroundColor: const Color(0xFF1877F2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('Sign In'),
                    ),
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
