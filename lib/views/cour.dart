import 'package:flutter/material.dart';
import '../models/cour_model.dart';
import '../services/cour_repository.dart';
import '../constants/app_colors.dart';
import 'pdf_viewer_page.dart';

class Cour extends StatefulWidget {
  final int studentId;

  const Cour({super.key, this.studentId = 1});

  @override
  State<Cour> createState() => _CourState();
}

class _CourState extends State<Cour> {
  late CourRepository _repository;
  late Future<CourseDashboardData> _coursesFuture;

  @override
  void initState() {
    super.initState();

    // Utilise le vrai backend Laravel via l'API /learner/dashboard
    _repository = ApiLaravelLessonRepository();

    _loadData();
  }

  void _loadData() {
    setState(() {
      _coursesFuture = _repository.fetchCoursesData(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mes Leçons de Conduite',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
      ),
      body: FutureBuilder<CourseDashboardData>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: AppColors.slate400),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Carte de Progression
                  _buildProgressCard(data.progress),
                  const SizedBox(height: 20),

                  // 2. Prochaine Leçon (si disponible)
                  if (data.nextLesson != null) ...[
                    const Text(
                      'Prochaine leçon',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildNextLessonCard(data.nextLesson!),
                    const SizedBox(height: 24),
                  ],

                  // 3. Historique & Leçons à venir
                  const Text(
                    'Toutes mes leçons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (data.lessons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Aucune leçon enregistrée.')),
                    )
                  else
                    ...data.lessons.map((lesson) => _buildLessonItem(lesson)),
                ],
              ),
            ),
          );
        },
      ),

      // Bouton de réservation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action de réservation
        },
        icon: const Icon(Icons.add),
        label: const Text('Réserver un cours'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Widget : Carte de progression
  Widget _buildProgressCard(StudentProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression de la formation',
            style: TextStyle(color: AppColors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.completedHours}h réalisées sur ${progress.totalHours}h',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 8,
              backgroundColor: AppColors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  // Widget : Prochaine leçon
  Widget _buildNextLessonCard(Lesson lesson) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(lesson.isTheory ? Icons.menu_book : Icons.directions_car, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.date,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Module : ${lesson.title}', style: const TextStyle(color: AppColors.slate500)),
                  Text('Moniteur : ${lesson.instructor}', style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget réutilisable : Élément de la liste
  Widget _buildLessonItem(Lesson lesson) {
    final String statusLower = lesson.status.toLowerCase();
    final bool isCompleted = statusLower == 'effectuée' || statusLower == 'completed';
    final Color statusColor = isCompleted ? AppColors.success : AppColors.warning;
    final IconData icon = lesson.isTheory ? Icons.menu_book : (isCompleted ? Icons.check_circle_outline : Icons.calendar_today);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: statusColor),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${lesson.date}\nMoniteur : ${lesson.instructor}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                lesson.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              if (lesson.mediaUrl != null) ...[
                const SizedBox(height: 4),
                  GestureDetector(
                  onTap: () {
                    final mediaUrl = lesson.mediaUrl!.startsWith('http')
                        ? lesson.mediaUrl!
                        : 'http://192.168.2.214:8000/storage/${lesson.mediaUrl!}';
                    
                    if (lesson.mediaType?.contains('pdf') ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            url: mediaUrl,
                            title: lesson.title,
                          ),
                        ),
                      );
                    } else {
                      // Ouverture image/autre via navigateur ou viewer dédié
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Image.network(mediaUrl),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Icon(
                    lesson.mediaType?.contains('pdf') ?? false
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}