import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
  auth.User user;
  EditProfile({required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState(user);
}

class _EditProfileState extends State<EditProfile> {
  auth.User user;
  _EditProfileState(this.user);
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    if (user.displayName != null) {
      _usernameController.text = user.displayName!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: user.photoURL != null
                  ? NetworkImage("${user.photoURL}")
                  : const NetworkImage(
                      "https://cdn-icons-png.flaticon.com/64/3177/3177440.png"),
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı Adı',
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (_usernameController.text.isNotEmpty) {}
            },
            child: Text('Kaydet'),
          ),
        ],
      )),
    );
  }
}
