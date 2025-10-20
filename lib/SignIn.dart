import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/ForgetPassword.dart';
import 'package:login/PublicDashboard.dart';
import 'package:login/SignUp.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final emailctrl = TextEditingController();
  final passctrl = TextEditingController();

  // 🔹 Email Validation
  bool isValidEmail(String email) {
    // Only allows letters, numbers, @ and .com
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$');
    return regex.hasMatch(email);
  }

  // 🔹 Password Validation
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  void SignInAuth() async {
    final email = emailctrl.text.trim();
    final password = passctrl.text.trim();

    // 🔹 Validate before sending to Firebase
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pop(context); // close loader
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PublicDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.code)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LogIn",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email Input
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

          // Password Input
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: passctrl,
              obscureText: true, // hide password
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

          // Login Button
          ElevatedButton(
            onPressed: SignInAuth,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Links
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Signup()),
              );
            },
            child: const Text("Create New Account"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Forgetpassword()),
              );
            },
            child: const Text("Forget Password"),
          ),
        ],
      ),
    );
  }
}
