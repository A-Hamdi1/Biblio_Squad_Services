import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
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
          // Rediriger vers la page d'accueil en effaçant la pile de navigation
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                  AppHeader(showBar: false), // Masquer la barre de recherche
                  const SizedBox(height: 30),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Connexion à Biblio Squad",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7643),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Accédez à vos services personnalisés",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                          label: "Mot de passe",
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
                              ? "Connexion en cours..."
                              : "Se connecter",
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
                            "Pas encore de compte ? Inscrivez-vous",
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
