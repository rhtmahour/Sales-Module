import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/managerdashboard.dart';
//import 'package:csv/csv.dart';
//import 'package:file_picker/file_picker.dart';

class TaskForm extends StatefulWidget {
  final File? file;
  final List<List<dynamic>>? csvData;

  const TaskForm({super.key, this.file, this.csvData});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _tasknoController = TextEditingController();
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _statuscontroller = TextEditingController();
  TimeOfDay? _selectedTime;
  String? selectedUser;
  String? selectedTaskNumber;
  List<String> users = [];
  List<String> taskNumbers = [];

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'AGENT')
          .get();

      setState(() {
        users =
            querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> saveFormDataToFirestore() async {
    try {
      // Check if the task number already exists in Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('task')
          .where('Task_no', isEqualTo: selectedTaskNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show a message if the task number is already assigned
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task number already assigned')),
        );
        return; // Exit the function
      }

      DateTime currentDateTime = DateTime.now();
      String formattedDateTime =
          DateFormat('dd-MM-yyyy HH:mm:ss').format(currentDateTime);

      // Get the status text from the controller
      String statusText = _statuscontroller.text;

      // Update the 'status' field with the statusText variable
      await FirebaseFirestore.instance.collection('task').add({
        'Agent name': selectedUser,
        'Date': _dateController.text,
        'Time': _selectedTime != null ? _selectedTime!.format(context) : null,
        'Task_no': selectedTaskNumber,
        'Customer name': _customerNameController.text,
        'Address': _locationController.text,
        'Phone': _phoneNumberController.text,
        'Remark': _remarkController.text,
        'AssignedDateTime': formattedDateTime,
        'status': statusText,
      });

      // Show a success message or navigate to a new screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task submitted successfully')),
      );
    } catch (e) {
      print('Error saving form data: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit form')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ManagerScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Task Assign Form',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(
                      10.0), // Adjust the radius as needed
                ),
                child: ListTile(
                  title: Text(
                      'Selected Agent: ${selectedUser ?? "Select an agent"}'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () {
                    showUsersList(context);
                  },
                ),
              ),
            ),
            //Date and Time set manually for the Agent with the calendar icon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the radius as needed
                      ),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select Date",
                          hintStyle: const TextStyle(
                            fontSize: 15,
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  String formattedDate =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  _dateController.text = formattedDate;
                                });
                              }
                            },
                          ),
                        ),
                        onTap: () {
                          // Open calendar to pick date
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the radius as needed
                      ),
                      child: TextFormField(
                        readOnly: true, // Make the text field read-only
                        controller: TextEditingController(
                          text: _selectedTime != null
                              ? '${_selectedTime!.format(context)}'
                              : '',
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select Time",
                          hintStyle: const TextStyle(
                            fontSize: 15,
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime != null) {
                                setState(() {
                                  _selectedTime = pickedTime;
                                });
                              }
                            },
                          ),
                        ),
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedTaskNumber,
                  onChanged: (value) {
                    setState(() {
                      selectedTaskNumber = value;

                      // Find the row in csvData that corresponds to the selected task number
                      List<dynamic>? selectedRow = widget.csvData?.firstWhere(
                        (row) => row[0].toString() == value,
                        orElse: () => [],
                      );

                      // Autofill the other fields if a row is found
                      if (selectedRow != null) {
                        _customerNameController.text =
                            selectedRow[2].toString(); // Customer name
                        _locationController.text =
                            selectedRow[4].toString(); // Address
                        _phoneNumberController.text =
                            selectedRow[3].toString(); // Phone number
                        _remarkController.text =
                            selectedRow[7].toString(); // Remark
                      }
                    });
                  },
                  items: widget.csvData?.skip(1).map((row) {
                    return DropdownMenuItem<String>(
                      value: row[0].toString(),
                      child: Text(row[0].toString()),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Select Task Number",
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
                  controller: _customerNameController, // Add controller here
                  readOnly: true, // Make the text field read-only
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Customer name",
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
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
                  controller: _locationController, // Add controller here
                  readOnly: true, // Make the text field read-only
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Address",
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
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
                  controller: _phoneNumberController, // Add controller here
                  readOnly: true, // Make the text field read-only
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "phone number",
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
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
                  controller: _remarkController, // Add controller here
                  readOnly: true, // Make the text field read-only
                  maxLines: null, // Allows unlimited lines of text
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Remark",
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                  controller: _statuscontroller, // Add controller here
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Status",
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
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
              minWidth: 50,
              color: Colors.blue,
              onPressed: () async {
                // Save form data to Firestore
                await saveFormDataToFirestore();

                // Optionally, you can reset the form fields here
                _dateController.clear();
                _selectedTime = null;
                selectedUser = null;
                selectedTaskNumber = null;
                _customerNameController.clear();
                _locationController.clear();
                _phoneNumberController.clear();
                _remarkController.clear();
                _statuscontroller.text = '';

                // Navigate back to the ManagerScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerScreen(),
                  ),
                );
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
            ),
          ],
        ),
      ),
    );
  }

  void showUsersList(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'AGENT')
          .get();

      List<String> agents =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Agent'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(agents[index]),
                    onTap: () {
                      setState(() {
                        selectedUser = agents[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching agents: $e');
    }
  }
}
