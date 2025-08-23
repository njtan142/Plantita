'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../widgets/user_selection/user_search_dropdown.dart';
import '../widgets/file_selection/file_picker_interface.dart';
import '../widgets/upload/upload_progress_interface.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentStep = 0;
  UserModel? _selectedUser;
  List<PlatformFile> _selectedFiles = [];

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onStepTapped(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Media'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: _onStepTapped,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('Select User'),
            content: UserSearchDropdown(
              onUserSelected: (user) {
                setState(() {
                  _selectedUser = user;
                });
              },
              selectedUser: _selectedUser,
            ),
            isActive: _currentStep >= 0,
            state: _selectedUser != null ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Select Files'),
            content: FilePickerInterface(
              selectedUser: _selectedUser,
              onFilesSelected: (files) {
                setState(() {
                  _selectedFiles = files;
                });
              },
            ),
            isActive: _currentStep >= 1,
            state: _selectedFiles.isNotEmpty ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Upload'),
            content: UploadProgressInterface(
              selectedUser: _selectedUser,
              selectedFiles: _selectedFiles,
              onUploadComplete: (results) {
                // Handle upload completion
              },
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
''