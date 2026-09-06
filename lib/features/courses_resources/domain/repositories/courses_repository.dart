import '../../data/models/course_model.dart';

abstract class CoursesRepository {
  Future<List<CourseModel>> getAllCourses();

  Future<List<CourseModel>> getCoursesForSkills(List<String> skillNames);
}
