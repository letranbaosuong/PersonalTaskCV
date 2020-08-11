import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_personal_taskcv_app/src/daos/daos.dart';
import 'package:flutter_personal_taskcv_app/src/models/models.dart';

class TaskDAOImpl implements ITaskDAO {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Future<List<Task>> getListTask(String userId, Project project) async {
    List<Task> _listTask = List();
    var dataSnapshot = await _database
        .reference()
        .child('Tasks')
        .child(userId)
        .child(project.id)
        .once();
    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> valueTasks = dataSnapshot.value;
      valueTasks.forEach((key, value) {
        // print(value);
        Task task = Task.fromSnapshot(value);
        _listTask.add(task);
      });
    }

    return _listTask;
  }

  @override
  Future<double> getPercentTotalTasks(String userId, String projectId) async {
    List<Task> _listTask = List();
    double _percentCompleted = 0.0;
    var dataSnapshot = await _database
        .reference()
        .child('Tasks')
        .child(userId)
        .child(projectId)
        .once();
    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> valueTasks = dataSnapshot.value;
      valueTasks.forEach((key, value) {
        // print(value);
        Task task = Task.fromSnapshot(value);
        _listTask.add(task);
      });
    }

    int dem = 0;
    _listTask.forEach((task) {
      if (task.completed) {
        dem++;
      }
    });
    _percentCompleted = dem / _listTask.length;

    return _percentCompleted;
  }
}
