import 'package:flutter/material.dart' ;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do 앱')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/todo-local'),
                child: const Text('로컬 To-Do')
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/todo-remote'),
                child: const Text('클라우드 To-Do')
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('로그인')
            )
          ],
        ),
      ),
    );
  }
}
