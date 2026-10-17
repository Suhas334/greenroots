import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/root_screen.dart';

class GreenRootsApp extends StatelessWidget {
  const GreenRootsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenRoots',
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: canvas,
          colorScheme: ColorScheme.fromSeed(
              seedColor: forest, primary: forest, surface: canvas),
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationThemeData(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(17)),
          cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)))),
      home: const RootScreen());
}
