import 'package:flutter/material.dart';


class Task {
  final String name;
  bool isDone;

  Task(this.name, {this.isDone = false});

  void toggleDone() {
    this.isDone = !isDone;
  }

  @override
  String toString() {
    return 'Task(name: $name, isDone: $isDone)';
  }
}