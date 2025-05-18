import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'goals_screen.dart'; // Importe a tela de metas

class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({super.key});

  @override
  _InteractionsScreenState createState() => _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen> {
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';
  bool _isLoading = false;
  String? _userId;
  String? _token;
  bool _noGoals = false; // Para controlar se há metas ou não

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndToken();
  }

  // Carrega o userId, token e busca as metas do back-end
  Future<void> _fetchUserIdAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _token = prefs.getString('token');
    if (_userId == null || _token == null) {
      setState(() {
        _feedback = 'Usuário não logado. Faça login novamente.';
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/goals'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Adiciona o token JWT
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final goalsData = responseData['data'] ?? [];
        setState(() {
          _noGoals = goalsData.isEmpty; // Verifica se há metas
        });
      } else {
        setState(() {
          _noGoals = true;
        });
      }
    } catch (e) {
      setState(() {
        _feedback = 'Erro ao carregar metas: $e';
      });
    }
  }

  // Gera o feedback usando o Gemini LLM e salva no histórico
  Future<void> _generateFeedback(String userInput) async {
    setState(() {
      _isLoading = true;
      _feedback = '';
    });

    try {
      await dotenv.load();
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        setState(() {
          _feedback =
              'Erro: Chave da API não encontrada. Por favor, verifique a configuração.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/goals'), // URL corrigida
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Adiciona o token JWT
        },
      );

      String goalsText;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final goalsData = responseData['data'] ?? [];
        goalsText =
            goalsData.isNotEmpty
                ? goalsData
                    .map(
                      (goal) =>
                          "${goal['goal_description']} (Status: ${goal['status']})",
                    )
                    .join(', ')
                : 'Nenhuma meta definida';
      } else {
        goalsText = 'Nenhuma meta definida';
      }

      final prompt = '''
Você é um assistente de bem-estar emocional. O usuário está enfrentando desafios no relacionamento e compartilhou o seguinte problema: "$userInput". As metas do usuário para melhorar o relacionamento são: $goalsText.

Forneça um feedback empático e prático, estruturado EXATAMENTE em 3 parágrafos:
1) Reflexão: Reflita sobre o problema do usuário, mostrando empatia e entendimento.
2) Sugestões: Dê 2-3 sugestões práticas e específicas para enfrentar o problema, considerando as metas do usuário. Elogie as metas que estão com status "Concluída" e, para as metas "Em andamento", sugira formas de progredir nelas. Se não houver metas, sugira ações gerais para melhorar o relacionamento.
3) Encorajamento: Finalize com uma mensagem motivacional e encorajadora.

Responda em português, em um tom amigável e acolhedor. Cada parágrafo deve ter entre 3 e 5 frases.
''';

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-8b-latest:generateContent?key=$apiKey';
      final responseGemini = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topP': 0.95,
            'topK': 40,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (responseGemini.statusCode == 200) {
        final data = jsonDecode(responseGemini.body);
        final feedback = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _feedback = feedback;
        });
        // Salva a resposta no histórico
        await http.post(
          Uri.parse(
            'http://localhost:3000/api/interaction-history',
          ), // URL corrigida
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token', // Adiciona o token JWT
          },
          body: jsonEncode({'responseText': feedback}),
        );
      } else {
        setState(() {
          _feedback =
              'Erro ao gerar feedback: ${responseGemini.statusCode} - ${responseGemini.body}';
        });
      }
    } catch (e) {
      setState(() {
        _feedback = 'Erro ao gerar feedback: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(title: const Text('Interações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'O que está afetando seu relacionamento?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite aqui...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            if (_controller.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, descreva o problema antes de enviar.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            _generateFeedback(_controller.text);
                          },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Obter Feedback'),
                ),
              ),
              const SizedBox(height: 20),
              if (_noGoals &&
                  _feedback.isEmpty) // Exibe mensagem se não houver metas
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Você ainda não definiu metas. Que tal começar agora?',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoalsScreen(),
                            ),
                          );
                        },
                        child: const Text('Definir Metas'),
                      ),
                    ],
                  ),
                ),
              if (_feedback.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _feedback,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
