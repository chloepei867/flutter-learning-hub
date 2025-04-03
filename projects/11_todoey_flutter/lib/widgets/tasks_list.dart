import 'package:flutter/material.dart';
import 'package:todoey_flutter/widgets/task_tile.dart';
import 'package:todoey_flutter/models/task.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/models/task_data.dart';

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer<TaskData>(
      builder: (context, taskData, child) {
        return ListView.builder(
            itemCount: taskData.tasks.length,
            itemBuilder: (context, index) {
              // bool? isDone = tasks[index].isDone;
              return TaskTile(
                task: taskData.tasks[index],
                onChanged: (bool? newValue) {
                  taskData.updateTask(taskData.tasks[index]);
                },
                deleteCallback: () {
                  taskData.remove(index);
                }
              );
            }
        );
      },
    );
  }
}