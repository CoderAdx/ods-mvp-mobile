import 'package:flutter/material.dart';

class InteractionsScreen extends StatelessWidget {
  const InteractionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interações')),
      body: Column(
        children: [
          // Campo pra adicionar nova interação
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText:
                          'Nova Mensagem (ex.: Parabéns pelo progresso!)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Chamar a API pra criar interação (POST /api/interactions)
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
          // Lista de interações
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                ListTile(
                  title: Text('João: Parabéns, você reduziu o uso hoje!'),
                  subtitle: Text('13/03/2025'),
                ),
                ListTile(
                  title: Text('Maria: Ótimo progresso com o WhatsApp!'),
                  subtitle: Text('13/03/2025'),
                ),
                // TODO: Buscar interações da API (GET /api/interactions/:userId)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
