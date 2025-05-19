import 'dart:convert';

import 'package:flutter/material.dart' ;
import 'package:shared_preferences/shared_preferences.dart';

class TodoLocalPage extends StatefulWidget {
  const TodoLocalPage({super.key});

  @override
  State<TodoLocalPage> createState() => _TodoLocalPageState();
}

class _TodoLocalPageState extends State<TodoLocalPage> {

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();

  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos.add({"text": text, "done": false});
        _controller.clear();
      });
      _saveTodos();
    }
  }

  void _deleteTodo(int index) {
    final deleted = _todos[index]['text'];
    setState(() {
      _todos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'$deleted' 삭제됨"))
    );
    _saveTodos();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', jsonEncode(_todos));
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('todos');
    if (saved != null) {
      final List decoded = jsonDecode(saved);
      setState(() {
        _todos.clear();
        _todos.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      });
    }
  }

  void _toggleDone(int index, bool? value) {
    setState(() {
      _todos[index]['done'] = value ?? false;
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로컬 TO-DO"),
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
                    onSubmitted: (_) => _addTodo(),
                    decoration: const InputDecoration(
                      hintText: '할 일을 입력하세요',
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: _addTodo,
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
