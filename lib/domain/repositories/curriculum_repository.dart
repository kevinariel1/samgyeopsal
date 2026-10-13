import '../../data/models/unit_model.dart';
import '../../data/models/lesson_model.dart';

abstract class CurriculumRepository {
  Future<List<UnitModel>> getAllUnits();
  Future<UnitModel?> getUnitById(String unitId);
  Future<LessonModel?> getLessonById(String lessonId);
}
