import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final emailreset = TextEditingController();

  // 🔹 Email Validation
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return regex.hasMatch(email);
  }

  void Resetpasword() async {
    final email = emailreset.text.trim();

    // 🔹 Validate email
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email (must contain @ and .com)")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check your Inbox for Reset Password Email")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20, // 👈 same bold/bigger style as login/signup
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // back button white
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: emailreset,
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

          // Reset Button
          ElevatedButton(
            onPressed: Resetpasword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 3,
            ),
            child: const Text(
              "Send Reset Password Email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
