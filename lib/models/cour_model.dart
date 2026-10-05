class StudentProgress {
  final int completedHours;
  final int totalHours;

  StudentProgress({required this.completedHours, required this.totalHours});

  double get ratio => totalHours > 0 ? completedHours / totalHours : 0;

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    final completed =
        json['completed_hours'] ??
        json['completed_lessons'] ??
        json['completed_courses'] ??
        0;
    final total =
        json['total_hours'] ??
        json['total_lessons'] ??
        json['total_courses'] ??
        json['courses_count'] ??
        0;

    return StudentProgress(
      completedHours: completed is num
          ? completed.toInt()
          : int.tryParse(completed.toString()) ?? 0,
      totalHours: total is num
          ? total.toInt()
          : int.tryParse(total.toString()) ?? 0,
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String date;
  final String instructor;
  final String status;
  final String type;
  final String? notes;
  final int? rating;
  final String? appreciation;
  final String? mediaUrl;
  final String? mediaType;

  Lesson({
    required this.id,
    required this.title,
    required this.date,
    required this.instructor,
    required this.status,
    this.type = 'practical',
    this.notes,
    this.rating,
    this.appreciation,
    this.mediaUrl,
    this.mediaType,
  });

  bool get isTheory => type == 'theory';

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final topic = json['topic'] ?? json['title'] ?? json['name'] ?? '';
    final typeLabel = json['type_label'] ?? '';
    final title = (topic is String && topic.isNotEmpty) ? topic : typeLabel;

    final formattedDate =
        json['formatted_date'] ?? json['start_at_display'] ?? '';
    final formattedTime = json['formatted_time'] ?? '';
    final date = formattedTime.isNotEmpty
        ? '$formattedDate à $formattedTime'
        : (formattedDate.isNotEmpty ? formattedDate : (json['start_at'] ?? ''));

    final status = json['status_label'] ?? json['status'] ?? '';

    return Lesson(
      id: json['id'] ?? 0,
      title: title,
      date: date.toString(),
      instructor: json['instructor_name'] ?? json['teacher_name'] ?? '',
      status: status,
      type: json['type'] ?? 'practical',
      notes: json['notes'],
      rating: json['rating'],
      appreciation: json['appreciation'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
    );
  }
}

class CourseDashboardData {
  final StudentProgress progress;
  final Lesson? nextLesson;
  final List<Lesson> lessons;

  CourseDashboardData({
    required this.progress,
    this.nextLesson,
    required this.lessons,
  });

  factory CourseDashboardData.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['progress'] ?? json['stats'] ?? {};
    final progressJson = rawProgress is Map
        ? Map<String, dynamic>.from(rawProgress)
        : <String, dynamic>{};

    final courseList = json['courses'] is List
        ? json['courses'] as List
        : (json['lessons'] as List? ?? const []);

    final nextLessonJson =
        json['next_lesson'] ??
        (courseList.isNotEmpty ? courseList.first : null);

    return CourseDashboardData(
      progress: StudentProgress.fromJson(progressJson),
      nextLesson: nextLessonJson != null
          ? Lesson.fromJson(Map<String, dynamic>.from(nextLessonJson))
          : null,
      lessons: courseList
          .map((l) => Lesson.fromJson(Map<String, dynamic>.from(l)))
          .toList(),
    );
  }
}
