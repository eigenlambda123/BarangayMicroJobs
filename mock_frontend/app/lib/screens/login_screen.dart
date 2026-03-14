import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth/login_header.dart';
import '../widgets/auth/phone_field.dart';
import '../widgets/auth/password_field.dart';
import '../widgets/auth/login_button.dart';
import '../widgets/auth/register_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().login(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, ${result['user']['full_name']}!')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const LoginHeader(),
                const SizedBox(height: 48),
                PhoneField(controller: _phoneController),
                const SizedBox(height: 20),
                PasswordField(controller: _passwordController),
                const SizedBox(height: 32),
                LoginButton(isLoading: _isLoading, onPressed: _handleLogin),
                const SizedBox(height: 16),
                const RegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
