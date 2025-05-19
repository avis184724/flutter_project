import 'package:flutter/material.dart';
import 'package:flutter_project/todo_local_page.dart';
import 'package:flutter_project/todo_remote_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPAVASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do 프로젝트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/todo-local': (context) => const TodoLocalPage(),
        '/todo-remote': (context) => const TodoRemotePage()
      }
    );
  }
}
