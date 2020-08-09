import 'package:flutter_personal_taskcv_app/src/models/models.dart';

abstract class ITaskDAO {
  Future<List<Task>> getListTask(String userId, Project project);
}
