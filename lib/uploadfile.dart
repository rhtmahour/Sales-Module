import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/managerdashboard.dart';

class CsvDataProvider extends ChangeNotifier {
  File? _file;
  List<List<dynamic>>? _csvData;
  String? _errorMessage;

  File? get file => _file;

  List<List<dynamic>>? get csvData => _csvData;

  String? get errorMessage => _errorMessage;

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File newFile = File(result.files.single.path!);
      String csvString = await newFile.readAsString();
      CsvToListConverter converter = const CsvToListConverter();
      List<List<dynamic>> csvData = converter.convert(csvString);

      _file = newFile;
      _csvData = csvData;
      _errorMessage = null; // Reset error message
    } else {
      // User canceled the file picker
      _file = null;
      _csvData = null;
      _errorMessage = 'No file selected';
    }

    notifyListeners();
  }
}

class FileUploadScreen extends StatelessWidget {
  const FileUploadScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Go back to ManagerScreen
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('File Upload'),
        ),
        body: Center(
          child: Consumer<CsvDataProvider>(
            builder: (context, provider, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await provider.uploadFile();
                      // Navigate to ManagerScreen with uploaded CSV data
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerScreen(
                            file: provider.file,
                            csvData: provider.csvData,
                          ),
                        ),
                      );
                    },
                    child: const Text('Upload CSV File'),
                  ),
                  const SizedBox(height: 20),
                  if (provider.file != null)
                    Text('File Name: ${provider.file!.path}')
                  else
                    const Text('No file selected'),
                  const SizedBox(height: 20),
                  if (provider.errorMessage != null)
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (provider.csvData != null)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: provider.csvData![0]
                            .map<DataColumn>((column) =>
                                DataColumn(label: Text(column.toString())))
                            .toList(),
                        rows: provider.csvData!.sublist(1).map<DataRow>((row) {
                          return DataRow(
                            cells: row
                                .map<DataCell>(
                                    (cell) => DataCell(Text(cell.toString())))
                                .toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  if (provider.file != null && provider.errorMessage == null)
                    const Text(
                      'File uploaded successfully',
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
