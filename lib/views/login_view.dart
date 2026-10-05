import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../components/custom_text_field.dart';
import '../components/custom_button.dart';
import '../constants/app_colors.dart';
import '../inscription.dart';
import '../bottom_navigation_bar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(context, listen: false).loginByCode(
        _codeController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie !'), backgroundColor: AppColors.success),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code invalide ou erreur réseau'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.directions_car_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  "Bon retour !",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.slate900),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Entrez le code reçu par email pour accéder à votre espace",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.slate500),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _codeController,
                  hintText: "Votre code d'accès",
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  keyboardType: TextInputType.text,
                  validator: (v) => v == null || v.trim().isEmpty ? "Veuillez entrer votre code" : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Se connecter",
                  isLoading: authProvider.isLoading,
                  onPressed: _handleLogin,
                  gradientColors: AppColors.primaryGradient,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous n'avez pas de compte ? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InscriptionPage())),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomBottomNavigationBar()),
                    );
                  },
                  icon: const Icon(Icons.explore_outlined, color: AppColors.primary),
                  label: const Text(
                    "Accéder directement à l'accueil (Mode Démo)",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
