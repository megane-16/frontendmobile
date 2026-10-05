import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../provider/auth_provider.dart';
import '../services/quiz_repository.dart';
import 'quiz_view.dart';

class TheoryView extends StatelessWidget {
  const TheoryView({super.key});

  String _schoolName(BuildContext context) {
    final userSchool = context.read<AuthProvider>().user?.autoEcole;
    return QuizRepository().normalizeSchoolKey(userSchool);
  }

  @override
  Widget build(BuildContext context) {
    final schoolKey = _schoolName(context);
    final modules = QuizRepository().getSchoolModules(
      schoolKey == 'kopa' ? 'KOPA' : 'PARIS',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Théorie & Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolKey == 'kopa'
                              ? 'Programme KOPA'
                              : 'Programme Paris',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schoolKey == 'kopa'
                              ? 'Conduite urbaine, priorité et sécurité proactive.'
                              : 'Signalisation, priorité, vitesse et maîtrise du code.',
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations du parcours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    schoolKey == 'kopa'
                        ? 'Objectif: renforcer l’anticipation, la sécurité et le respect du code en ville.'
                        : 'Objectif: maîtriser les panneaux, la priorité à droite et la conduite en agglomération.',
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: modules
                        .map(
                          (module) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              module,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Activités de formation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 20),

            _InteractiveCard(
              title: 'Quiz Rapide',
              subtitle:
                  'Questions ciblées ${schoolKey == 'kopa' ? 'KOPA' : 'Paris'}',
              icon: Icons.timer_rounded,
              color: AppColors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizView(
                      questions: QuizRepository().getQuestionsForSchool(
                        schoolKey,
                      ),
                    ),
                  ),
                );
              },
            ),

            _InteractiveCard(
              title: 'Thématiques',
              subtitle: 'Signalisation, Priorités, etc.',
              icon: Icons.category_rounded,
              color: AppColors.green,
              onTap: () {},
            ),

            _InteractiveCard(
              title: 'Examens Blancs',
              subtitle: 'Conditions réelles de l\'examen (20 questions)',
              icon: Icons.assignment_rounded,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizView(
                      questions: QuizRepository().getOfficialExamQuestions(count: 20),
                    ),
                  ),
                );
              },
            ),

            _InteractiveCard(
              title: 'Mes Statistiques',
              subtitle: 'Suivez votre progression',
              icon: Icons.bar_chart_rounded,
              color: AppColors.purple,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.slate900,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.slate300,
            ),
          ),
        ),
      ),
    );
  }
}
