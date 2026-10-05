class StudentProgress {
  final int completedHours;
  final int totalHours;

  StudentProgress({required this.completedHours, required this.totalHours});

  double get ratio =>
      totalHours > 0 ? (completedHours / totalHours).clamp(0.0, 1.0) : 0.0;

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      completedHours: json['completed_hours'] ?? 0,
      totalHours: json['total_hours'] ?? 20,
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String date;
  final String instructor;
  final String status; // 'A venir', 'Effectuée', 'Annulée'

  Lesson({
    required this.id,
    required this.title,
    required this.date,
    required this.instructor,
    required this.status,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      date: json['formatted_date'] ?? json['date'],
      instructor: json['instructor_name'] ?? 'Non assigné',
      status: json['status'],
    );
  }
}

class CourseDashboardData {
  final StudentProgress progress;
  final Lesson? nextLesson;
  final List<Lesson> allLessons;

  CourseDashboardData({
    required this.progress,
    this.nextLesson,
    required this.allLessons,
  });

  factory CourseDashboardData.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['progress'] ?? json['stats'] ?? {};
    final progressJson = rawProgress is Map
        ? Map<String, dynamic>.from(rawProgress)
        : <String, dynamic>{};

    final courseList = json['courses'] is List
        ? json['courses'] as List
        : (json['lessons'] as List<dynamic>? ?? const []);

    final nextLessonJson =
        json['next_lesson'] ??
        (courseList.isNotEmpty ? courseList.first : null);

    return CourseDashboardData(
      progress: StudentProgress.fromJson(progressJson),
      nextLesson: nextLessonJson != null
          ? Lesson.fromJson(Map<String, dynamic>.from(nextLessonJson))
          : null,
      allLessons: courseList
          .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
