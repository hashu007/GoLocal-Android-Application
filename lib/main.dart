import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/SplashScreen.dart';
import 'package:login/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Poppins", // 🔹 global font

          textTheme: TextTheme(
            bodyLarge: TextStyle(fontFamily: "Poppins"),
            bodyMedium: TextStyle(fontFamily: "Poppins"),
            bodySmall: TextStyle(fontFamily: "Poppins"),
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue,
            titleTextStyle: TextStyle(
              fontFamily: "Poppins",
            ),
            toolbarTextStyle: TextStyle(
              fontFamily: "Poppins",
            ),
          ),
        ),
            home: SplashScreen());
  }
}
