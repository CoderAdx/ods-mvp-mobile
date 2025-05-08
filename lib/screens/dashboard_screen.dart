import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Função para fazer logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Remove o userId do SharedPreferences
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Redireciona para a tela de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50], // Mesmo fundo das outras telas
      appBar: AppBar(
        title: const Text('Dashboard'),
        // Removida a cor personalizada para usar o padrão do tema (como em UsageHistoryScreen)
        actions: [
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza verticalmente
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centraliza horizontalmente
          children: [
            const Text(
              'Bem-vindo ao Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign:
                  TextAlign.center, // Garante que o texto esteja centralizado
            ),
            const SizedBox(height: 20),
            SizedBox(
              width:
                  double
                      .infinity, // Faz o botão ocupar toda a largura disponível
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/usage_history');
                },
                style: ElevatedButton.styleFrom(
                  // Removida a cor personalizada para usar o padrão do tema
                  minimumSize: const Size.fromHeight(
                    50,
                  ), // Altura fixa para consistência
                ),
                child: const Text('Histórico de Uso'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/goals');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Metas'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/interactions');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Interações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
