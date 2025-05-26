import 'dart:convert';

import 'package:flutter/material.dart' ;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoRemotePage extends StatefulWidget {
  const TodoRemotePage({super.key});

  @override
  State<TodoRemotePage> createState() => _TodoRemotePageState();
}

class _TodoRemotePageState extends State<TodoRemotePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();

  }

  void _addTodo(String text) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (text.trim().isEmpty) return;
    await supabase.from("todos").insert({
      'text': text.trim(),
      'done': false,
      'user_id': userId,
    });

    _controller.clear();
    _loadTodos();
  }

  void _deleteTodo(int index) async {
    final todo = _todos[index];
    await supabase.from('todos').delete().eq('id',todo['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("'${todo['text']}' 삭제됨"))
    );
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', jsonEncode(_todos));
  }

  Future<void> _loadTodos() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final response = await supabase
      .from('todos')
      .select()
      .eq('user_id', userId as Object)
      .order('id', ascending: false);

    setState(() {
      _todos = List<Map<String, dynamic>>.from(response);

    });
  }

  void _toggleDone(int index, bool? value) async {
    final todo = _todos[index];
    final updated = value ?? false;

    await supabase
        .from('todos')
        .update({'done': updated})
        .eq('id', todo['id']);

    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 To-Do 앱"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _addTodo,
                    decoration: InputDecoration(
                      hintText: '할 일을 입력하세요',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _addTodo(_controller.text),
                  icon: const Icon(Icons.add),
                  label: const Text("추가"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                )
              ],
            )
          ),
          Expanded(
            child: _todos.isEmpty
              ? const Center(child: Text("할 일이 없습니다"))
              : ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Checkbox(
                        value: todo['done'],
                        onChanged: (value) => _toggleDone(index, value),
                      ),
                      title: Text(
                        todo['text'],
                        style: TextStyle(
                            fontSize: 18,
                            decoration: todo['done']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                            color: todo['done'] ? Colors.grey : Colors.black
                        ),
                      ),
                      onLongPress: () => _deleteTodo(index),
                    ),
                  );
                  //
                },
              )
          )
        ],
      )
    );
  }
}
