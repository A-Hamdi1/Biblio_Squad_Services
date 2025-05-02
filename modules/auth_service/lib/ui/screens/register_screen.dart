import 'package:flutter/material.dart';
import 'package:ocr_service/ui/components/app_header.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../utils/input_validators.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Client'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AuthProvider>(context, listen: false)
          .register(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      )
          .then((_) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.status == AuthStatus.success) {
          // Navigate to LoginScreen instead of popping
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
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
                  AppHeader(
                      onBackPressed: () => Navigator.pop(context),
                      showBar: false),
                  const SizedBox(height: 20),
                  const Text(
                    "Register to Biblio Squad",
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
                          controller: _nameController,
                          label: "Full Name",
                          validator: InputValidators.validateName,
                        ),
                        const SizedBox(height: 16),
                        AuthInputField(
                          controller: _phoneController,
                          label: "Phone Number",
                          validator: InputValidators.validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: AuthButton(
                                text: "Author",
                                onPressed:
                                    authProvider.status == AuthStatus.loading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedRole = 'Author';
                                            });
                                          },
                                textStyle: TextStyle(
                                  color: _selectedRole == 'Author'
                                      ? Colors.black
                                      : const Color(0xFFFF7643),
                                ),
                                backgroundColor: _selectedRole == 'Author'
                                    ? const Color(0xFFFF7643)
                                    : Colors.grey[200],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AuthButton(
                                text: "Client",
                                onPressed:
                                    authProvider.status == AuthStatus.loading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedRole = 'Client';
                                            });
                                          },
                                textStyle: TextStyle(
                                  color: _selectedRole == 'Client'
                                      ? Colors.black
                                      : const Color(0xFFFF7643),
                                ),
                                backgroundColor: _selectedRole == 'Client'
                                    ? const Color(0xFFFF7643)
                                    : Colors.grey[200],
                              ),
                            ),
                          ],
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
                              ? "Registering..."
                              : "Register",
                          onPressed: authProvider.status == AuthStatus.loading
                              ? null
                              : _handleRegister,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Login",
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
