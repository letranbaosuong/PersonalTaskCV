import 'package:flutter_personal_taskcv_app/src/daos/daos.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';
import 'package:flutter_personal_taskcv_app/src/services/services.dart';

class ServiceDAOImpl implements IServiceDAO {
  ITaskDAO _taskDAO = TaskDAOImpl();

  @override
  Future<List<Task>> getListTask(String userId, Project project) {
    return _taskDAO.getListTask(userId, project);
  }
}
