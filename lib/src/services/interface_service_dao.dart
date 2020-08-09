import 'package:flutter_personal_taskcv_app/src/models/models.dart';

abstract class IServiceDAO {
  Future<List<Task>> getListTask(String userId, Project project);
}
