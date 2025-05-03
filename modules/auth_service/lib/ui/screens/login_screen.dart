import 'package:flutter/material.dart';
import 'package:ocr_service/ui/components/app_header.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../utils/input_validators.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text)
          .then((_) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.status == AuthStatus.success) {
          Navigator.pop(context); // Return to previous screen
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  AppHeader(showBar: true),
                  const SizedBox(height: 20),
                  const Text(
                    "Login to Biblio Squad",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7643),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthInputField(
                          controller: _emailController,
                          label: "Email",
                          validator: InputValidators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        AuthInputField(
                          controller: _passwordController,
                          label: "Password",
                          validator: InputValidators.validatePassword,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        if (authProvider.status == AuthStatus.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              authProvider.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        AuthButton(
                          text: authProvider.status == AuthStatus.loading
                              ? "Logging in..."
                              : "Login",
                          onPressed: authProvider.status == AuthStatus.loading
                              ? null
                              : _handleLogin,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Color(0xFFFF7643),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
