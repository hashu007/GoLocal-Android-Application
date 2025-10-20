import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String? imageUrl;
  bool loading = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 🔹 Load user profile from Firestore
  Future<void> _loadProfile() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data["name"] ?? "";
          _contactController.text = data["contact"] ?? "";
          imageUrl = data["imageUrl"];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
    }
  }

  /// 🔹 Pick image and upload to Firebase Storage
  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => loading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_pics")
          .child("${user!.uid}.jpg");
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      setState(() {
        imageUrl = url;
      });

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "imageUrl": url,
        "lastUpdated": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
    }

    setState(() => loading = false);
  }

  /// 🔹 Save profile details to Firestore
  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "name": _nameController.text.trim(),
        "contact": _contactController.text.trim(),
        "imageUrl": imageUrl,
        "email": user!.email,
        "lastUpdated": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("✅ Profile updated")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 🔹 Light background
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 👤 Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.blue[100],
                    backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                    child: imageUrl == null
                        ? Icon(Icons.camera_alt,
                        size: 40, color: Colors.blue)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 📌 Name Field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 📌 Contact Field
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    prefixIcon: Icon(Icons.phone, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // 💾 Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Save Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔄 Loading Overlay
          if (loading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
