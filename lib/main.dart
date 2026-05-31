import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/chat_screen.dart';
import 'widgets/scribble_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const NeiWuFuApp());
}

class NeiWuFuApp extends StatelessWidget {
  const NeiWuFuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '内务府',
      debugShowCheckedModeBanner: false,
      theme: ScribbleTheme.theme,
      home: const ChatScreen(),
    );
  }
}
