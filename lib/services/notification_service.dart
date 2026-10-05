class LessonReminder {
  final String title;
  final String message;
  final bool isImminent; // true si < 2h, false si veille (24h)
  final DateTime lessonDate;
  final String? instructorName;
  final String? pickupLocation;

  LessonReminder({
    required this.title,
    required this.message,
    required this.isImminent,
    required this.lessonDate,
    this.instructorName,
    this.pickupLocation,
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Analyse les cours à venir et génère les alertes pour la veille et 2h avant.
  List<LessonReminder> checkUpcomingReminders(List<Map<String, dynamic>> lessons) {
    final List<LessonReminder> reminders = [];
    final now = DateTime.now();

    for (final lesson in lessons) {
      final status = (lesson['status'] ?? '').toString().toLowerCase();
      if (status == 'annule' || status == 'annulée' || status == 'termine' || status == 'terminée') {
        continue;
      }

      final rawStartsAt = lesson['starts_at'];
      if (rawStartsAt == null) continue;

      DateTime? startsAt;
      try {
        startsAt = DateTime.parse(rawStartsAt.toString());
      } catch (_) {
        continue;
      }

      final difference = startsAt.difference(now);
      final hoursUntil = difference.inHours;
      final minutesUntil = difference.inMinutes;

      final title = lesson['title'] ?? 'Leçon de conduite';
      final instructor = lesson['instructor_name'] ?? lesson['teacher_name'] ?? 'Votre moniteur';
      final location = lesson['pickup_location'] ?? 'Auto-école';

      // Rappel 2h avant (entre 0 et 120 minutes)
      if (minutesUntil > 0 && minutesUntil <= 120) {
        reminders.add(LessonReminder(
          title: '🚨 Rappel : Votre leçon commence bientôt !',
          message: 'Votre cours "$title" avec $instructor débute dans $minutesUntil min au point de rendez-vous : $location.',
          isImminent: true,
          lessonDate: startsAt,
          instructorName: instructor,
          pickupLocation: location,
        ));
      }
      // Rappel la veille (entre 12 et 28 heures avant)
      else if (hoursUntil >= 12 && hoursUntil <= 28) {
        reminders.add(LessonReminder(
          title: '📅 Rappel : Leçon prévue demain',
          message: 'Vous avez un cours de conduite prévu demain à ${_formatTime(startsAt)} avec $instructor.',
          isImminent: false,
          lessonDate: startsAt,
          instructorName: instructor,
          pickupLocation: location,
        ));
      }
    }

    return reminders;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
