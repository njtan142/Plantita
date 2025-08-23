import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/data/models/user.dart';
import 'package:user_app/state_management/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.userProfile;

    _usernameController = TextEditingController(text: currentUser?.username);
    _emailController = TextEditingController(text: currentUser?.email);
    _bioController = TextEditingController(text: currentUser?.bio);
    _avatarUrlController = TextEditingController(text: currentUser?.avatarUrl);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.userProfile!;

      final updatedUser = currentUser.copyWith(
        username: _usernameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        avatarUrl: _avatarUrlController.text,
      );

      await userProvider.updateUserProfile(updatedUser);
      if (userProvider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Go back to profile screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${userProvider.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  // Basic email validation
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
