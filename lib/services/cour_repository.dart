import '../models/cour_model.dart';
import 'api_service.dart';

abstract class CourRepository {
  Future<CourseDashboardData> fetchCoursesData(int studentId);
}

/// Implémentation réelle : appelle l'API Laravel /learner/dashboard
class ApiLaravelLessonRepository implements CourRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<CourseDashboardData> fetchCoursesData(int studentId) async {
    final data = await _apiService.getLearnerDashboard();
    return CourseDashboardData.fromJson(data);
  }
}

/// Implémentation de test avec des données fictives
class MockLessonRepository implements CourRepository {
  @override
  Future<CourseDashboardData> fetchCoursesData(int studentId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockJson = {
      "progress": {
        "completed_hours": 12,
        "total_hours": 20,
      },
      "next_lesson": {
        "id": 101,
        "title": "Créneau et Rangement en bataille",
        "formatted_date": "Mardi 25 Août à 14h00",
        "instructor_name": "Jean Marc",
        "status": "À venir"
      },
      "lessons": [
        {
          "id": 101,
          "title": "Créneau et Rangement en bataille",
          "formatted_date": "Mardi 25 Août - 14h00",
          "instructor_name": "Jean Marc",
          "status": "À venir"
        },
        {
          "id": 100,
          "title": "Conduite en agglomération & rond-point",
          "formatted_date": "Hier - 10h00",
          "instructor_name": "Jean Marc",
          "status": "Effectuée"
        },
        {
          "id": 99,
          "title": "Démarrage en côte & Contrôles",
          "formatted_date": "18 Août - 11h00",
          "instructor_name": "Sarah",
          "status": "Effectuée"
        }
      ]
    };

    return CourseDashboardData.fromJson(mockJson);
  }
}