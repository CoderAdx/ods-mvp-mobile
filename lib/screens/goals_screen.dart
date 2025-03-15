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
  List<dynamic> usageData = [];
  String? userId;
  final TextEditingController _goalDescriptionController =
      TextEditingController();

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }
    _fetchGoals();
    _fetchUsage();
  }

  Future<void> _fetchGoals() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/goals/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          goalsData = jsonDecode(response.body);
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

  Future<void> _fetchUsage() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/usage/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          usageData = jsonDecode(response.body);
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

    final appName = match.group(1)!;
    final targetTime = int.parse(match.group(2)!);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/goals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
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
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/goals/$goalId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta deletada com sucesso')),
        );
        _fetchGoals(); // Atualiza a lista após exclusão
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

  int _calculateProgress(String appName) {
    int totalMinutes = 0;
    final today = DateTime.now();
    for (var usage in usageData) {
      if (usage['app_name'] != appName) continue;
      final usageDate = DateTime.parse(usage['date']);
      if (usageDate.day == today.day &&
          usageDate.month == today.month &&
          usageDate.year == today.year) {
        final timeSpent = usage['time_spent'] as String;
        final parts = timeSpent.split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        totalMinutes += hours * 60 + minutes;
      }
    }
    return totalMinutes;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final appName =
                    RegExp(
                      r'Reduzir (\w+) a',
                    ).firstMatch(goal['goal_description'] ?? '')?.group(1) ??
                    'Desconhecido';
                final progress = _calculateProgress(appName);
                return ListTile(
                  title: Text(goal['goal_description'] ?? 'Sem descrição'),
                  subtitle: Text(
                    'Progresso: ${progress}min hoje | Status: ${goal['status'] ?? 'N/A'}',
                  ),
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
