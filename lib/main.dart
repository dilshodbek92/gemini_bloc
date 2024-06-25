import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gemini/presentation/bloc/starter/starter_bloc.dart';
import 'package:gemini/presentation/pages/starter_page.dart';

import 'data/datasources/local/no_sql.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyC1pW5LeC2htQf8c_aM6-GOH5k2eWu79RQ",
        // paste your api key here
        appId: "1:1078379417:android:c3a77b6d2eb43a10aec908",
        //paste your app id here
        messagingSenderId: "1078379417",
        //paste your messagingSenderId here
        projectId: "gemini-53e97",
        //
        storageBucket:
        "gemini-53e97.appspot.com" // paste your project id here
    ),
  );
  HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => StarterBloc(),
        child: const StarterPage(),
      ),
    );
  }
}
