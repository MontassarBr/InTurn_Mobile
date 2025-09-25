import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/social_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.black87)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text('Welcome Back', style: AppConstants.headingStyle),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 60, color: AppConstants.primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  prefixIcon: const Icon(Icons.lock_outline),
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
                  icon: const Icon(Icons.login),
                  onPressed: authProvider.status == AuthStatus.loading ? null : _submit,
                  label: authProvider.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: const [Expanded(child: Divider()), SizedBox(width: 8), Text('or continue with'), SizedBox(width: 8), Expanded(child: Divider())]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIconButton(icon: FontAwesomeIcons.google, backgroundColor: Color(0xFFDB4437)),
                  const SizedBox(width: 16),
                  SocialIconButton(icon: FontAwesomeIcons.apple, backgroundColor: Colors.black),
                  const SizedBox(width: 16),
                  SocialIconButton(icon: FontAwesomeIcons.facebookF, backgroundColor: Color(0xFF1877F2)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: AppConstants.errorColor),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
