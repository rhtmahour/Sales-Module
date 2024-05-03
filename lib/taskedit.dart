import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/agentdashboard.dart';

// ignore: must_be_immutable
class EditTask extends StatefulWidget {
  var customerName;
  var address;
  var phoneNumber;

  EditTask({
    Key? key,
    required this.taskNo,
    required this.customerName,
    required this.address,
    required this.phoneNumber,
  }) : super(key: key);

  final String taskNo;

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateTaskInFirestore() async {
    try {
      // Query to find the document with matching Task_no
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('task')
          .where('Task_no', isEqualTo: widget.taskNo)
          .get();

      // Check if a document with matching Task_no was found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the matched document
        String docId = querySnapshot.docs.first.id;

        // Update the document with the new data
        await FirebaseFirestore.instance.collection('task').doc(docId).update({
          'Customer name': _customerNameController.text.isNotEmpty
              ? _customerNameController.text
              : widget.customerName ?? '',
          'Address': _addressController.text.isNotEmpty
              ? _addressController.text
              : widget.address ?? '',
          'Phone': _phoneController.text.isNotEmpty
              ? _phoneController.text
              : widget.phoneNumber ?? '',
        });

        // Show a success message or navigate to a new screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );

        // Clear the form fields after updating the task
        _customerNameController.clear();
        _addressController.clear();
        _phoneController.clear();
      } else {
        // If no document with matching Task_no was found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No task found with the specified Task_no')),
        );
      }
    } catch (e) {
      print('Error updating task: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Task Edit Form',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                initialValue: widget.taskNo,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Task Number",
                  hintStyle: TextStyle(fontSize: 15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Customer name",
                  hintStyle: TextStyle(fontSize: 15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Address",
                  hintStyle: TextStyle(fontSize: 15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "phone number",
                  hintStyle: TextStyle(fontSize: 15),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          MaterialButton(
            height: 50,
            color: Colors.blue,
            onPressed: () async {
              await updateTaskInFirestore();

              // Optionally, you can reset the form fields here
              _customerNameController.clear();
              _addressController.clear();
              _phoneController.clear();
              // Navigate back to the previous screen
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
