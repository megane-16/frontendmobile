import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/sign_history.dart';
import '../services/database_helper.dart';

class SignHistoryView extends StatefulWidget {
  const SignHistoryView({super.key});

  @override
  State<SignHistoryView> createState() => _SignHistoryViewState();
}

class _SignHistoryViewState extends State<SignHistoryView> {
  late Future<List<SignHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getSignHistory();
    });
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteSignHistory(id);
    _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Panneau retiré de l’historique.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetailModal(BuildContext context, SignHistory item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Détail du scan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: File(item.imagePath).existsSync()
                  ? Image.file(
                      File(item.imagePath),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: AppColors.infoLight,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: AppColors.slate500),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              item.signName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900),
            ),
            const SizedBox(height: 6),
            Text(
              'Scanné le ${_formatDate(item.scannedAt)}',
              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Compris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique des scans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<SignHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.infoLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aucun panneau scanné pour le moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prenez en photo les panneaux routiers croisés dans la rue pour les mémoriser et réviser le code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.slate500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Lancer un scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final file = File(item.imagePath);

                return Dismissible(
                  key: Key('sign_${item.id ?? index}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: AppColors.white),
                  ),
                  onDismissed: (_) {
                    if (item.id != null) {
                      _deleteItem(item.id!);
                    }
                  },
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showDetailModal(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: file.existsSync()
                                  ? Image.file(
                                      file,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 65,
                                      height: 65,
                                      color: AppColors.infoLight,
                                      child: const Icon(Icons.traffic, color: AppColors.primary),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.signName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 13, color: AppColors.slate500),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(item.scannedAt),
                                        style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.slate500),
                              onPressed: () {
                                if (item.id != null) {
                                  _deleteItem(item.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
