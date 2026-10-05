import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'components/custom_text_field.dart';
import 'components/custom_button.dart';
import 'components/custom_dropdown.dart';
import 'components/image_picker_field.dart';
import 'constants/app_colors.dart';
import 'provider/auth_provider.dart';
import 'models/user_model.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Nouveau
  final _villeController = TextEditingController();
  final _phoneController = TextEditingController(text: "+237 ");

  // State Variables
  String? _sexe;
  String? _categoriePermis;
  String? _typeAutoEcole;
  String? _horaireFormation;
  DateTime? _dateNaissance;
  File? _cniFile; // Remplacé bool _hasCNI

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
      } else {
        _submitData();
      }
    }
  }



  Future<void> _pickCNIImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _cniFile = File(image.path);
      });
    }
  }

  void _submitData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final errorMessage = await authProvider.register(
      User(
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _phoneController.text,
        ville: _villeController.text,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        categoriePermis: _categoriePermis,
        autoEcole: _typeAutoEcole,
        horaireFormation: _horaireFormation,
        hasCNI: _cniFile != null,
      ),
      _passwordController.text,
    );

    if (errorMessage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inscription réussie !"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Retour au login
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Inscription",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.slate900, letterSpacing: -1),
                        ),
                        Text("Étape ${_currentStep + 1} sur $_totalSteps",
                            style: const TextStyle(fontSize: 16, color: AppColors.slate500, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: AppColors.slate100),
                    ),
                  ],
                ),
              ),

              // Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8),
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: index <= _currentStep ? AppColors.primary : AppColors.slate200,
                          gradient: index == _currentStep ? const LinearGradient(colors: AppColors.primaryGradient) : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildStepContent(),
                  ),
                ),
              ),

              // Navigation
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [BoxShadow(color: AppColors.black.withAlpha(12), blurRadius: 20, offset: const Offset(0, -10))],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      IconButton(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(backgroundColor: AppColors.slate100, padding: const EdgeInsets.all(16)),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: _currentStep == _totalSteps - 1 ? "Terminer l'inscription" : "Étape suivante",
                        gradientColors: AppColors.primaryGradient,
                        onPressed: _nextStep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
            CustomTextField(
              hintText: "Nom de famille",
              controller: _nomController,
              prefixIcon: const Icon(Icons.badge_outlined),
              validator: (v) => v == null || v.isEmpty ? "Nom requis" : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Prénom de famille",
              controller: _prenomController,
              prefixIcon: const Icon(Icons.person_outline),
              validator: (v) => v == null || v.isEmpty ? "Prénom requis" : null,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              value: _sexe,
              items: const ["Homme", "Femme"],
              hintText: "Genre",
              prefixIcon: const Icon(Icons.transgender_rounded),
              itemToString: (s) => s,
              onChanged: (val) => setState(() => _sexe = val),
              validator: (v) => v == null ? "Sélectionnez votre genre" : null,
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          children: [
            CustomTextField(
              hintText: "Email",
              controller: _emailController,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains("@") ? "Email invalide" : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Mot de passe",
              controller: _passwordController,
              prefixIcon: const Icon(Icons.lock_outline),
              isPassword: true,
              validator: (v) => v == null || v.length < 6 ? "Minimum 6 caractères" : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Téléphone",
              controller: _phoneController,
              enabled: true,
              prefixIcon: const Icon(Icons.phone_iphone_rounded),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.length < 9 ? "Numéro invalide" : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Ville",
              controller: _villeController,
              prefixIcon: const Icon(Icons.map_outlined),
              validator: (v) => v == null || v.isEmpty ? "Ville requise" : null,
            ),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDropdown<String>(
              value: _categoriePermis,
              items: const ["Permis A", "Permis B", "Permis C"],
              hintText: "Catégorie de permis",
              prefixIcon: const Icon(Icons.credit_card_rounded),
              itemToString: (s) => s,
              onChanged: (val) => setState(() => _categoriePermis = val),
              validator: (v) => v == null ? "Sélectionnez une catégorie" : null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
            value: _typeAutoEcole,
            items: const ["autoecole philippe ", "autoecoleParis", "autoecole EEP"],
            hintText: "type d'autoecole",
            prefixIcon: const Icon(Icons.credit_card_rounded),
            itemToString: (s) => s,
            onChanged: (val) => setState(() => _typeAutoEcole = val),
            validator: (v) => v == null ? "Sélectionnez une autoecole" : null,
            ),
            const SizedBox(height: 24),
            Text("Pièce d'identité", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 12),
            ImagePickerField(
              label: "Scanner votre CNI", 
              hasImage: _cniFile != null, 
              onTap: _pickCNIImage,
            ),
            const SizedBox(height: 24),
            Text("Préférence horaire", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.slate800)),
            const SizedBox(height: 8),
            _buildModernRadio("Session du Matin", "Matin"),
            _buildModernRadio("Session d'Après-midi", "Après-midi"),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
            context: context, initialDate: DateTime.now().subtract(const Duration(days: 6570)), firstDate: DateTime(1950), lastDate: DateTime.now());
        if (picked != null) setState(() => _dateNaissance = picked);
      },
      child: AbsorbPointer(
        child: CustomTextField(
          hintText: _dateNaissance == null ? "Date de naissance" : "${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}",
          prefixIcon: const Icon(Icons.cake_outlined),
          validator: (v) => _dateNaissance == null ? "Date requise" : null,
        ),
      ),
    );
  }

  Widget _buildModernRadio(String title, String value) {
    bool isSelected = _horaireFormation == value;
    return GestureDetector(
      onTap: () => setState(() => _horaireFormation = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(12) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.slate200, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, color: isSelected ? AppColors.primary : AppColors.slate400),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate800)),
          ],
        ),
      ),
    );
  }
}
