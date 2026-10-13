import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../models/unit_model.dart';
import '../models/lesson_model.dart';

class CurriculumRepositoryImpl implements CurriculumRepository {
  final String assetPath;
  List<UnitModel>? _cachedUnits;
  final AssetBundle? bundle;

  CurriculumRepositoryImpl({
    this.assetPath = 'assets/data/units.json',
    this.bundle,
  });

  @override
  Future<List<UnitModel>> getAllUnits() async {
    if (_cachedUnits != null) {
      return _cachedUnits!;
    }
    final activeBundle = bundle ?? rootBundle;
    final jsonString = await activeBundle.loadString(assetPath);
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    _cachedUnits = list
        .map((item) => UnitModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _cachedUnits!.sort((a, b) => a.order.compareTo(b.order));
    return _cachedUnits!;
  }

  @override
  Future<UnitModel?> getUnitById(String unitId) async {
    final units = await getAllUnits();
    return units.where((u) => u.id == unitId).firstOrNull;
  }

  @override
  Future<LessonModel?> getLessonById(String lessonId) async {
    final units = await getAllUnits();
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
