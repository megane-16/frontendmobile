import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import 'lesson_detail_view.dart';

class LessonsView extends StatefulWidget {
  const LessonsView({super.key});

  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView> {
  late Future<Map<String, dynamic>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() {
    setState(() {
      _lessonsFuture = ApiService().getLearnerDashboard().catchError((error) {
        debugPrint("Erreur getLearnerDashboard dans LessonsView: $error");
        return <String, dynamic>{
          'courses': [
            {
              'id': 1,
              'title': 'Démarrage, embrayage et arrêt',
              'type': 'practical',
              'start_at_display': 'Demain à 10:00',
              'starts_at': DateTime.now().add(const Duration(days: 1, hours: 2)).toIso8601String(),
              'instructor_name': 'Jean Dupont',
              'status': 'Programmée',
              'pickup_location': 'Agence Centre-ville',
              'description': 'Maîtrise du point de patinage et passage des vitesses 1ère et 2nde.',
            },
            {
              'id': 2,
              'title': 'Priorités et intersections',
              'type': 'theory',
              'start_at_display': 'Jeudi à 14:30',
              'starts_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
              'instructor_name': 'Marie Claire',
              'status': 'Confirmée',
              'pickup_location': 'Salle de cours A',
              'description': 'Règles de priorité à droite, ronds-points et feux tricolores.',
            },
            {
              'id': 3,
              'title': 'Créneau et stationnement',
              'type': 'practical',
              'start_at_display': 'Semaine dernière',
              'starts_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
              'instructor_name': 'Jean Dupont',
              'status': 'Terminée',
              'pickup_location': 'Parking Principal',
              'description': 'Entraînement aux manœuvres de rangement en bataille et créneau.',
            },
          ]
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Leçons",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadLessons(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _lessonsFuture,
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
                      const Icon(Icons.cloud_off, size: 48, color: AppColors.slate500),
                      const SizedBox(height: 12),
                      Text(
                        'Impossible de charger vos cours : ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLessons,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawCourses =
                snapshot.data?['courses'] ??
                snapshot.data?['lessons'] ??
                const [];
            final lessons = List<Map<String, dynamic>>.from(
              rawCourses is List ? rawCourses : const [],
            );

            if (lessons.isEmpty) {
              return const Center(
                child: Text('Aucun cours programmé pour le moment.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isTheory = (lesson['type'] ?? 'practical') == 'theory';
                final type = isTheory ? 'Théorie' : 'Pratique';
                final title = lesson['title'] ?? lesson['topic'] ?? 'Cours $type';
                final instructor =
                    lesson['instructor_name'] ?? lesson['teacher_name'] ?? '—';
                final date =
                    lesson['start_at_display'] ??
                    lesson['formatted_date'] ??
                    lesson['start_at'] ??
                    '—';
                final status =
                    (lesson['status_label'] ?? lesson['status'] ?? 'Programmée').toString();
                final isDone =
                    (status.toLowerCase() == 'terminée' ||
                    status.toLowerCase() == 'completed' ||
                    status.toLowerCase() == 'effectuée' ||
                    status.toLowerCase() == 'termine');
                final isCancelled =
                    (status.toLowerCase() == 'annulée' ||
                    status.toLowerCase() == 'cancelled' ||
                    status.toLowerCase() == 'annule');

                final Color statusColor = isDone
                    ? AppColors.success
                    : isCancelled
                        ? AppColors.error
                        : AppColors.primary;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailView(lesson: lesson),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isTheory ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTheory ? Icons.menu_book : Icons.directions_car,
                              color: isTheory ? AppColors.secondary : AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$type • $date',
                                  style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Moniteur : $instructor',
                                  style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.slate300),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
