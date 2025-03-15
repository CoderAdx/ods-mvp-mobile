import 'package:flutter/material.dart';

class UsageHistoryScreen extends StatelessWidget {
  const UsageHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Uso')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ListTile(
            title: Text('WhatsApp'),
            subtitle: Text('90 minutos - 12/03/2025'),
          ),
          ListTile(
            title: Text('Instagram'),
            subtitle: Text('45 minutos - 13/03/2025'),
          ),
          // TODO: Buscar dados da API (GET /api/usage/:userId)
        ],
      ),
    );
  }
}
