import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/expense_tracker_app.dart';
import 'features/expenses/data/expense_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ExpenseTrackerApp(
        repository: FirestoreExpenseRepository(FirebaseFirestore.instance),
      ),
    );
  } catch (error) {
    runApp(FirebaseSetupApp(error: error));
  }
}

class FirebaseSetupApp extends StatelessWidget {
  const FirebaseSetupApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Firebase is not configured for this app yet.\n\n'
              'Run FlutterFire configuration and try again.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
