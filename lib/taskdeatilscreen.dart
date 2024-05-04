import 'package:flutter/material.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen(
      {Key? key, required this.taskId, required this.taskData})
      : super(key: key);

  final String taskId;
  final Map<String, dynamic> taskData;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Task Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          _buildDetailItem('Task Number', widget.taskData['Task_no']),
          _buildDetailItem(
              'Assigned Date Time', widget.taskData['AssignedDateTime']),
          _buildDetailItem('Agent name', widget.taskData['Agent name']),
          _buildDetailItem('Customer name', widget.taskData['Customer name']),
          _buildDetailItem('Phone', widget.taskData['Phone']),
          _buildDetailItem('Address', widget.taskData['Address']),
          _buildDetailItem('Date', widget.taskData['Date']),
          _buildDetailItem('Time', widget.taskData['Time']),
          _buildDetailItem('status', widget.taskData['status']),
          _buildDetailItem('Remark', widget.taskData['Remark']),
          _buildDetailItem('Remarks', widget.taskData['Remarks']),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value) {
    if (value != null) {
      if (title == 'Remarks') {
        List<String> remarksList = value.toString().split(',');
        List<Widget> remarkWidgets = remarksList
            .map((remark) =>
                Text(remark.trim(), style: const TextStyle(fontSize: 16)))
            .toList();
        return ListTile(
          title: Text(title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: remarkWidgets,
          ),
        );
      } else {
        return ListTile(
          title: Text(title),
          subtitle: Text(value.toString()),
        );
      }
    } else {
      return const SizedBox(); // Return an empty SizedBox if value is null
    }
  }
}
