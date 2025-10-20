import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/SignIn.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final emailctrl = TextEditingController();
  final passctrl = TextEditingController();
  final cpassctrl = TextEditingController();
  final namectrl = TextEditingController();

  // 🔹 Email Validation
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return regex.hasMatch(email);
  }

  // 🔹 Password Validation
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> SignUp() async {
    final email = emailctrl.text.trim();
    final password = passctrl.text.trim();
    final confirmPassword = cpassctrl.text.trim();
    final name = namectrl.text.trim();

    // 🔹 Validate inputs
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email (must contain @ and .com)")),
      );
      return;
    }

    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 👇 Save user info in Firestore
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": name.isNotEmpty ? name : "User",
          "email": email,
          "imageUrl": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign Up Successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUp"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20, // 👈 Bigger & bold like Login page
          fontFamily: "Poppins",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // 👇 Name field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: namectrl,
                decoration: InputDecoration(
                  hintText: "Enter Your Name",
                  fillColor: Colors.grey.withOpacity(0.3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: emailctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter Your E-mail",
                  fillColor: Colors.grey.withOpacity(0.3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: passctrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter Your Password",
                  fillColor: Colors.grey.withOpacity(0.3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Password
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: cpassctrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirm Your Password",
                  fillColor: Colors.grey.withOpacity(0.3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: SignUp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Signin()),
                );
              },
              child: const Text("Back To Login"),
            ),
          ],
        ),
      ),
    );
  }
}
