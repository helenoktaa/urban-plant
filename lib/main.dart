import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/routes/app_router.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Inisialisasi Firebase SEBELUM runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
