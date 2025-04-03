import 'package:flutter/material.dart';
import 'package:todoey_flutter/models/task.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/models/task_data.dart';

class AddTaskScreen extends StatefulWidget {
  // AddTaskScreen({required this.onTaskAdded});
  // // final List<Task> tasks;
  // Function(String) onTaskAdded;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  late String newTaskTitle;

  final TextEditingController _controller = TextEditingController();

  // final List<Task> tasks;
  @override
  Widget build(BuildContext context) {
    var taskData = context.watch<TaskData>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Add Task',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          //input task
          TextFormField(
            textAlign: TextAlign.center,
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black38, width: 2.0),
              ),
              // For the focused state
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
              ),
              hintText: 'Enter a new task',

            ),
            onChanged: (newValue) {
              newTaskTitle = newValue;
            },
          ),
          SizedBox(height: 20.0),
          //add task button
          Container(
            color: Colors.black,
            height: 50.0,
            width: double.infinity,
            child: TextButton(
              onPressed: ()=>{
                if (newTaskTitle.isNotEmpty) {
                taskData.add(newTaskTitle),
                },
                _controller.clear(),
                Navigator.pop(context),
              },
              child: Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
