import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Nova Meta (ex.: Reduzir WhatsApp a 30min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Chamar a API pra criar meta (POST /api/goals)
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Reduzir WhatsApp a 30min/dia'),
                  subtitle: Text('Progresso: 25min hoje'),
                ),
                // TODO: Buscar metas da API (GET /api/goals/:userId)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
