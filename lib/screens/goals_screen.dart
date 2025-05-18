import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<dynamic> goalsData = [];
  String? userId;
  String? token;
  final TextEditingController _goalDescriptionController =
      TextEditingController();

  Future<void> _fetchUserIdAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');
    if (userId == null || token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/goals'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Adiciona o token JWT
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          goalsData =
              responseData['data'] ??
              []; // Ajustado para a estrutura da resposta
          print('Lista de metas atualizada: $goalsData'); // Log para depuração
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${jsonDecode(response.body)['error']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _saveGoal() async {
    final description = _goalDescriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira a descrição da meta')),
      );
      return;
    }

    final regex = RegExp(r'Reduzir (\w+) a (\d+)min');
    final match = regex.firstMatch(description);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato inválido. Use: "Reduzir <App> a <número>min"'),
        ),
      );
      return;
    }

    final targetTime = int.parse(match.group(2)!);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/goals'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Adiciona o token JWT
        },
        body: jsonEncode({
          'goalDescription': description,
          'targetTime': targetTime,
          'status': 'Em andamento',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Meta salva com sucesso')));
        _fetchGoals();
        _goalDescriptionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${jsonDecode(response.body)['error']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _deleteGoal(int goalId) async {
    try {
      // Remove a meta localmente para atualização imediata da UI
      setState(() {
        goalsData.removeWhere((goal) => goal['id'] == goalId);
      });

      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/goals/$goalId'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Adiciona o token JWT
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta deletada com sucesso')),
        );
        await _fetchGoals(); // Atualiza a lista com os dados do backend
      } else {
        // Se houver erro, recarrega a lista para reverter a remoção local
        await _fetchGoals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${jsonDecode(response.body)['error']}'),
          ),
        );
      }
    } catch (e) {
      // Se houver erro de conexão, recarrega a lista para reverter a remoção local
      await _fetchGoals();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _updateGoalStatus(int goalId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/goals/$goalId'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Adiciona o token JWT
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _fetchGoals(); // Atualiza a lista após a mudança de status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${jsonDecode(response.body)['error']}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(title: const Text('Metas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Nova Meta (ex.: Reduzir WhatsApp a 30min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveGoal,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: goalsData.length,
              itemBuilder: (context, index) {
                final goal = goalsData[index];
                final isCompleted = goal['status'] == 'Concluída';

                return ListTile(
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (bool? value) {
                      final newStatus =
                          value == true ? 'Concluída' : 'Em andamento';
                      _updateGoalStatus(goal['id'], newStatus);
                    },
                  ),
                  title: Text(
                    goal['goal_description'] ?? 'Sem descrição',
                    style: TextStyle(
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text('Status: ${goal['status'] ?? 'N/A'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteGoal(goal['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
