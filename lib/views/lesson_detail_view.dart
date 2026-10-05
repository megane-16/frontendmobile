import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'pdf_viewer_page.dart';

class LessonDetailView extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailView({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isTheory = (lesson['type'] ?? 'practical') == 'theory';
    final typeLabel = isTheory ? 'Cours Théorique' : 'Cours Pratique';
    final title = lesson['title'] ?? lesson['topic'] ?? typeLabel;
    final instructor = lesson['instructor_name'] ?? lesson['teacher_name'] ?? 'Moniteur assigné';
    final date = lesson['start_at_display'] ?? lesson['formatted_date'] ?? lesson['starts_at'] ?? 'Date à confirmer';
    final time = lesson['formatted_time'] ?? '';
    final pickupLocation = lesson['pickup_location'] ?? 'Agence auto-école';
    final notes = lesson['notes'] ?? 'Aucune consigne particulière pour cette séance.';
    final status = (lesson['status_label'] ?? lesson['status'] ?? 'Planifiée').toString();
    final isCompleted = status.toLowerCase() == 'terminée' || status.toLowerCase() == 'completed' || status.toLowerCase() == 'termine';
    final isCancelled = status.toLowerCase() == 'annulée' || status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'annule';

    final Color statusColor = isCompleted
        ? AppColors.success
        : isCancelled
            ? AppColors.error
            : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la leçon', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale d'en-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeLabel,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.white70),
                      const SizedBox(width: 6),
                      Text(
                        time.isNotEmpty ? '$date • $time' : date,
                        style: const TextStyle(color: AppColors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Moniteur
            _buildSectionCard(
              title: 'Moniteur responsable',
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.infoLight,
                    child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Enseignant de la conduite agréé',
                          style: TextStyle(fontSize: 12, color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Lieu de rendez-vous
            _buildSectionCard(
              title: 'Lieu de prise en charge',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickupLocation,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Présentez-vous 5 minutes avant l’heure prévue.',
                          style: TextStyle(fontSize: 12, color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Section Media / Support de cours
            if (lesson['media_url'] != null && lesson['media_url'].toString().isNotEmpty) ...[
              _buildSectionCard(
                title: 'Support pédagogique du cours',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lesson['media_url'].toString().toLowerCase().endsWith('.pdf') || (lesson['media_type'] ?? '') == 'pdf')
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerPage(
                                url: lesson['media_url'].toString(),
                                title: title,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: AppColors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Support de cours (PDF)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Appuyez pour ouvrir et lire le document',
                                      style: TextStyle(fontSize: 12, color: AppColors.slate500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.primary),
                            ],
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          lesson['media_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: AppColors.infoLight,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: AppColors.slate500, size: 40),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Section Notes et Consignes
            _buildSectionCard(
              title: 'Consignes & Objectifs',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.slate900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'N’oubliez pas votre livret d’apprentissage et une pièce d’identité valide.',
                            style: TextStyle(fontSize: 12, color: AppColors.slate500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton retour / confirmation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour à la liste des cours'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate900,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
