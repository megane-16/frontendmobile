import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../models/sign_history.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

import 'sign_history_view.dart';

class TrafficSignScanView extends StatefulWidget {
  const TrafficSignScanView({super.key});

  @override
  State<TrafficSignScanView> createState() => _TrafficSignScanViewState();
}

class _TrafficSignScanViewState extends State<TrafficSignScanView> {
  final _picker = ImagePicker();
  final _api = ApiService();
  File? _image;
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _image = File(picked.path);
        _result = null;
        _error = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      final message = e.code == 'camera_access_denied'
          ? 'Accès caméra refusé. Autorisez la caméra dans les réglages.'
          : e.code == 'no_available_camera'
              ? 'Aucune caméra disponible sur cet appareil. Utilisez la galerie.'
              : 'Impossible d’ouvrir la caméra (${e.code}).';
      setState(() => _error = message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Impossible d’ouvrir la caméra.');
    }
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.analyzeTrafficSign(image);
      if (!mounted) return;
      setState(() => _result = result);
      if (result['is_traffic_sign'] == true) {
        await DatabaseHelper.instance.insertSignHistory(SignHistory(
          signName: result['sign_name'] as String? ?? 'Panneau non identifié',
          scannedAt: DateTime.now(),
          imagePath: image.path,
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Analyse impossible. Vérifiez votre connexion.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scanner un panneau'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Historique des scans',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignHistoryView()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Analyse pédagogique', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Ne manipulez jamais l’application en conduisant. Résultat à but pédagogique uniquement.'),
              const SizedBox(height: 20),
              if (_image != null)
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, height: 260, fit: BoxFit.cover))
              else
                Container(height: 260, decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.traffic, size: 80)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Caméra'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Galerie'))),
              ]),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _image == null || _loading ? null : _analyze, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search), label: Text(_loading ? 'Analyse...' : 'Analyser le panneau')),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: Colors.red))],
              if (_result != null) ...[_ResultCard(result: _result!)],
            ]),
          ),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isSign = result['is_traffic_sign'] == true;
    if (!isSign) {
      final message = result['message'] as String? ?? 'Ceci n’est pas un panneau de signalisation.';
      return Card(
        margin: const EdgeInsets.only(top: 20),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.orange, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final category = result['category'] as String? ?? 'Non précisée';
    final color = _categoryColor(category);
    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: const [Icon(Icons.check_circle, color: Colors.green, size: 18), SizedBox(width: 6), Text('Analyse terminée', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
          const Text('Cameroun', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: .12), foregroundColor: color, child: Icon(_categoryIcon(category))),
          const SizedBox(width: 12),
          Expanded(child: Text(result['sign_name'] as String? ?? 'Panneau identifié', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(category, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        _InfoSection(icon: Icons.info_outline, title: 'Signification', text: result['meaning'] as String? ?? 'Non précisée'),
        Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(12)), child: _InfoSection(icon: Icons.directions_car, title: 'Comportement attendu', text: result['action_required'] as String? ?? 'Non précisé')),
        if (result['penalty_risk'] != null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)), child: _InfoSection(icon: Icons.warning_amber_rounded, title: 'Risque / rappel', text: result['penalty_risk'] as String)),
        const SizedBox(height: 4),
        const Text('Conseil : respectez toujours la signalisation présente sur la route et les indications des autorités.', style: TextStyle(fontSize: 12, color: AppColors.slate500, height: 1.35)),
      ])),
    );
  }

  static Color _categoryColor(String category) => switch (category) {
        'Danger' => Colors.red,
        'Interdiction' => Colors.deepOrange,
        'Obligation' => Colors.blue,
        'Indication' => Colors.teal,
        _ => Colors.grey,
      };

  static IconData _categoryIcon(String category) => switch (category) {
        'Danger' => Icons.warning_amber,
        'Interdiction' => Icons.block,
        'Obligation' => Icons.arrow_circle_right,
        'Indication' => Icons.info,
        _ => Icons.traffic,
      };
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoSection({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(text, style: const TextStyle(height: 1.35))])),
        ]),
      );
}
