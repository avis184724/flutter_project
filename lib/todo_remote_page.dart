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
    if (text.trim().isEmpty) return;

    await supabase.from("todos").insert({
      'text': text.trim(),
      'done': false,
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
    final response = await supabase
        .from('todos')
        .select()
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
        title: const Text("리모트 To-Do"),
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
                    decoration: const InputDecoration(
                      hintText: '할 일을 입력하세요',
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => _addTodo(_controller.text),
                    child: const Text("추가")
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
                  return ListTile(
                    leading: Checkbox(
                      value: todo['done'],
                      onChanged: (value) => _toggleDone(index, value),
                    ),
                    title: Text(
                      todo['text'],
                      style: TextStyle(
                        decoration: todo['done']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                        color: todo['done'] ? Colors.grey : Colors.black
                      ),

                    ),
                    onLongPress: () => _deleteTodo(index),
                  );
                },
                )
          )
        ],
      )
    );
  }
}
