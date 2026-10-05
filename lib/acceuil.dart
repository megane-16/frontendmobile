import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'inscription.dart';
import 'models/school_model.dart';
import 'provider/auth_provider.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'views/lesson_detail_view.dart';
import 'views/lessons_viewer.dart';
import 'views/sign_history_view.dart';
import 'views/traffic_sign_scan_view.dart';

class _AccueilData {
  final Map<String, dynamic> dashboard;
  final List<School> schools;

  _AccueilData({required this.dashboard, required this.schools});
}

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  late Future<_AccueilData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_AccueilData> _loadData() async {
    final api = ApiService();
    try {
      final dashboard = await api.getLearnerDashboard();
      final schools = await api.getAutoEcoles();
      return _AccueilData(dashboard: dashboard, schools: schools);
    } catch (e) {
      debugPrint("Erreur chargement dashboard API, utilisation des données locales: $e");
      final sampleCourses = [
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
      ];

      final fallbackDashboard = <String, dynamic>{
        'stats': {
          'courses_completed': 4,
          'hours_driven': 8,
          'success_rate': 85,
        },
        'next_lesson': sampleCourses.first,
        'courses': sampleCourses,
      };
      final schools = await api.getAutoEcoles();
      return _AccueilData(dashboard: fallbackDashboard, schools: schools);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_AccueilData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 56,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger le dashboard\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _future = _loadData();
                        });
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dashboard = snapshot.data!.dashboard;
          final stats = dashboard['stats'] is Map
              ? dashboard['stats'] as Map<String, dynamic>
              : const <String, dynamic>{};
          final schools = snapshot.data!.schools;
          final nextLesson = dashboard['next_lesson'] is Map
              ? Map<String, dynamic>.from(dashboard['next_lesson'])
              : null;
          final schoolKey = context.read<AuthProvider>().user?.autoEcole ?? '';
          final normalizedSchoolKey = _normalizeSchoolKey(schoolKey);
          final visibleSchools = schools.where((school) {
            if (normalizedSchoolKey.isEmpty) return true;
            final name = school.name.toLowerCase();
            return name.contains(normalizedSchoolKey);
          }).toList();
          final displaySchools = visibleSchools.isNotEmpty
              ? visibleSchools
              : schools;
          final heroAsset = _heroAssetForSchool(normalizedSchoolKey);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _loadData();
              });
              await _future;
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue sur',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.slate500,
                            ),
                          ),
                          Text(
                            'DriveFlow',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.slate900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.white,
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...() {
                    final rawCourses = dashboard['courses'] ?? dashboard['lessons'] ?? [];
                    final courseList = List<Map<String, dynamic>>.from(rawCourses is List ? rawCourses : []);
                    final reminders = NotificationService.instance.checkUpcomingReminders(courseList);

                    return reminders.map((reminder) {
                      final isUrgent = reminder.isImminent;
                      final bg = isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
                      final border = isUrgent ? AppColors.error : AppColors.success;
                      final iconColor = isUrgent ? AppColors.error : AppColors.success;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isUrgent ? Icons.access_time_filled : Icons.notifications_active,
                                color: iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isUrgent ? AppColors.error : AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reminder.message,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.slate900, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  }(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prêt pour le permis ?',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                nextLesson != null
                                    ? 'Prochaine séance : ${nextLesson['title'] ?? 'À venir'}'
                                    : 'Inscrivez-vous dès maintenant et commencez vos cours.',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const InscriptionPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  foregroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("S'inscrire"),
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(heroAsset, height: 100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrafficSignScanView(),
                        ),
                      ),
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: const Text('Scanner un panneau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slate900,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Apprenants',
                          value: '${stats['learners_count'] ?? 0}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Cours',
                          value: '${stats['courses_count'] ?? 0}',
                          color: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LessonsView(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Scans',
                          value: '${stats['scans_count'] ?? 0}',
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignHistoryView(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (nextLesson != null)
                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonDetailView(lesson: nextLesson),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Prochaine leçon',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      nextLesson['title'] ?? 'Cours à venir',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      nextLesson['start_at_display'] ??
                                          nextLesson['formatted_date'] ??
                                          'Date à confirmer',
                                      style: const TextStyle(
                                        color: AppColors.slate500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.slate300,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nos Auto-écoles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (displaySchools.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displaySchools.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final school = displaySchools[index];
                        final color = index.isEven
                            ? AppColors.primary
                            : AppColors.secondary;
                        final imagePath = school.imagePath.isNotEmpty
                            ? school.imagePath
                            : 'assets/images/autostop.svg';
                        return _buildSchoolCard(
                          context,
                          school.name,
                          school.location,
                          imagePath,
                          color,
                          school.rating,
                        );
                      },
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'Aucune auto-école disponible pour le moment.',
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ));
        },
      ),
    );
  }

  String _normalizeSchoolKey(String? schoolName) {
    final raw = (schoolName ?? '').toLowerCase();
    final compact = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (compact.contains('kopa')) return 'kopa';
    if (compact.contains('paris')) return 'paris';
    return '';
  }

  String _heroAssetForSchool(String schoolKey) {
    if (schoolKey.contains('kopa')) return 'assets/images/autostop1.svg';
    if (schoolKey.contains('paris')) return 'assets/images/autostop.svg';
    return 'assets/images/inscription.svg';
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolCard(
    BuildContext context,
    String title,
    String subtitle,
    String assetPath,
    Color themeColor,
    double rating,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: SvgPicture.asset(assetPath, height: 45),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.slate500, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
