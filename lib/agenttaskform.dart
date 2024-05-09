import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_module/agentdashboard.dart';

class Agenttaskform extends StatefulWidget {
  final String? taskNo;
  final String? customerName;
  final String? address;
  final String? phoneNumber;
  String? remark;

  Agenttaskform({
    Key? key,
    this.taskNo,
    this.customerName,
    this.address,
    this.phoneNumber,
    this.remark,
  }) : super(key: key);
  @override
  State<Agenttaskform> createState() => _AgenttaskformState();
}

class _AgenttaskformState extends State<Agenttaskform> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _taskNumberController = TextEditingController();
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _statuscontroller = TextEditingController();
  String? selectedUser;
  String? selectedTaskNumber; // Added variable for selected Task Number
  TimeOfDay? _selectedTime;
  List<String> agentNames = [];

  @override
  void initState() {
    super.initState();
    fetchAgents();
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
          'Date': _dateController.text,
          'Time': _selectedTime != null ? _selectedTime!.format(context) : null,
          'Customer name': _customerNameController.text.isNotEmpty
              ? _customerNameController.text
              : widget.customerName ?? '',
          'Address': _locationController.text.isNotEmpty
              ? _locationController.text
              : widget.address ?? '',
          'Phone': _phoneNumberController.text.isNotEmpty
              ? _phoneNumberController.text
              : widget.phoneNumber ?? '',
          'Agent name': selectedUser, // Update the agent's name
          'status': _statuscontroller.text,
          'Remarks': FieldValue.arrayUnion([_remarkController.text]),
          // Add the new remark to the 'Remarks' array in the document
          // Update the other fields as needed
          //'DateUpdated': DateFormat('dd-MM-yyyy').format(DateTime.now()),
          //'TimeUpdated': DateFormat('HH:mm:ss').format(DateTime.now()),
        });

        // Show a success message or navigate to a new screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
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

  Future<void> fetchAgents() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      agentNames =
          querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      print('Error fetching agents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("taskNo: ${widget.taskNo}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Agent Task Assign Form',
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
                borderRadius: BorderRadius.circular(10.0),
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
              child: TextFormField(
                initialValue: widget.customerName,
                // Remove readOnly property to allow editing
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
                initialValue: widget.address,
                // Remove readOnly property to allow editing
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
                initialValue: widget.phoneNumber,
                // Remove readOnly property to allow editing
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "phone number",
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
                controller: _remarkController,
                onChanged: (value) {
                  // Update the _remarkController's text value as the user types
                  _remarkController.text = value;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Remark",
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
              await updateTaskInFirestore();

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
                  builder: (context) => const AgentScreen(),
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
    );
  }

  void showUsersList(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

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
