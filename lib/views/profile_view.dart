import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../provider/auth_provider.dart';

import 'edit_profile_view.dart';
import 'lessons_viewer.dart';
import 'sign_history_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 26),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.white,
                    backgroundImage: (user?.photoProfil != null && user!.photoProfil!.isNotEmpty)
                        ? NetworkImage(user.photoProfil!) as ImageProvider
                        : null,
                    child: (user?.photoProfil == null || user!.photoProfil!.isEmpty)
                        ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user != null ? "${user.nom} ${user.prenom}" : "Apprenant DriveFlow",
                    style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "apprenant@driveflow.com",
                    style: const TextStyle(color: AppColors.white70, fontSize: 13),
                  ),
                  if (user?.autoEcole != null && user!.autoEcole!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Auto-École : ${user.autoEcole}',
                        style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildOption(
                  Icons.person_outline,
                  "Modifier mes informations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileView()),
                    );
                  },
                ),
                _buildOption(
                  Icons.directions_car,
                  "Mes cours & séances",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LessonsView()),
                    );
                  },
                ),
                _buildOption(
                  Icons.document_scanner,
                  "Historique des panneaux scannés",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignHistoryView()),
                    );
                  },
                ),
                _buildOption(
                  Icons.school_outlined,
                  "Livret d’apprentissage",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Livret d’apprentissage en cours de synchronisation.')),
                    );
                  },
                ),
                _buildOption(
                  Icons.help_outline,
                  "Aide & Support",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support DriveFlow : support@driveflow.com')),
                    );
                  },
                ),
                _buildOption(
                  Icons.logout,
                  "Déconnexion",
                  isDestructive: true,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Se déconnecter'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await authProvider.logout();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.slate900),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.slate900)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
