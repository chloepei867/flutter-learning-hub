import 'package:flutter/foundation.dart';
import 'task.dart';

class TaskData extends ChangeNotifier {
  List<Task> tasks = [
    Task("sleeping"),
    Task("shopping"),
  ];

  void add(String newTaskTitle) {
    tasks.add(Task(newTaskTitle));
    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  void updateTask(Task task) {
    task.toggleDone();
    notifyListeners();
  }

  int countTasks() {
    return tasks.length;
  }


  void remove(int taskIndex) {
    tasks.remove(tasks[taskIndex]);
    // Don't forget to tell dependent widgets to rebuild _every time_
    // you change the model.
    notifyListeners();
  }
}



