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
}
