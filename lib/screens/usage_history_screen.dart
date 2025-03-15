import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  _UsageHistoryScreenState createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  List<dynamic> usageData = [];
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
    _fetchUsage();
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

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Uso')),
      body: ListView.builder(
        itemCount: usageData.length,
        itemBuilder: (context, index) {
          final usage = usageData[index];
          // Formatação manual da data (sem intl)
          String formattedDate = 'Data inválida';
          if (usage['date'] != null) {
            try {
              DateTime dateTime = DateTime.parse(usage['date']);
              String day = dateTime.day.toString().padLeft(2, '0');
              String month = dateTime.month.toString().padLeft(2, '0');
              String year = dateTime.year.toString();
              formattedDate = '$day/$month/$year';
            } catch (e) {
              formattedDate = 'Data inválida';
            }
          }
          return ListTile(
            title: Text(usage['app_name'] ?? 'Sem nome'),
            subtitle: Text(
              'Data: $formattedDate | Tempo: ${usage['time_spent'] ?? 'Não informado'}',
            ),
          );
        },
      ),
    );
  }
}
