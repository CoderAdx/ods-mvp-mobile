import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InteractionHistoryScreen extends StatefulWidget {
  const InteractionHistoryScreen({super.key});

  @override
  _InteractionHistoryScreenState createState() =>
      _InteractionHistoryScreenState();
}

class _InteractionHistoryScreenState extends State<InteractionHistoryScreen> {
  List<dynamic> interactionData = [];
  String? userId;

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }
    _fetchInteractions();
  }

  Future<void> _fetchInteractions() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/interaction-history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          interactionData = jsonDecode(response.body);
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

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(title: const Text('Histórico de Interações')),
      body:
          interactionData.isEmpty
              ? const Center(child: Text('Nenhum histórico encontrado.'))
              : ListView.builder(
                itemCount: interactionData.length,
                itemBuilder: (context, index) {
                  final interaction = interactionData[index];
                  // Formatação manual da data (sem intl)
                  String formattedDate = 'Data inválida';
                  if (interaction['generated_at'] != null) {
                    try {
                      DateTime dateTime = DateTime.parse(
                        interaction['generated_at'],
                      );
                      String day = dateTime.day.toString().padLeft(2, '0');
                      String month = dateTime.month.toString().padLeft(2, '0');
                      String year = dateTime.year.toString();
                      String hour = dateTime.hour.toString().padLeft(2, '0');
                      String minute = dateTime.minute.toString().padLeft(
                        2,
                        '0',
                      );
                      formattedDate = '$day/$month/$year $hour:$minute';
                    } catch (e) {
                      formattedDate = 'Data inválida';
                    }
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            interaction['response_text'] ?? 'Sem texto',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data: $formattedDate',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
