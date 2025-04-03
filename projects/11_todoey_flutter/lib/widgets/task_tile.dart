import 'package:flutter/material.dart';
import 'package:todoey_flutter/models/task.dart';


class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key, required this.task,
    required this.onChanged,
    required this.deleteCallback
  });
  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? deleteCallback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      // checkColor: Colors.black,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: onChanged,
            activeColor: Colors.black,
            checkColor: Colors.white,
          ),
          IconButton(
              onPressed: deleteCallback,
              icon: Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}





// class TaskTile extends StatefulWidget {
//   const TaskTile({super.key});
//
//   @override
//   State<TaskTile> createState() => _TaskTileState();
// }
//
// class _TaskTileState extends State<TaskTile> {
//   bool isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     return CheckboxListTile(
//       value: isChecked,
//       title: Text(
//         'Headline',
//         style: TextStyle(
//           decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {
//           isChecked = value!;
//         });
//       },
//     );
//   }
// }
