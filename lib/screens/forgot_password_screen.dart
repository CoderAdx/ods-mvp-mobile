import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _securityWordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _recoverPassword() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final securityWord = _securityWordController.text.trim();

    if (securityWord.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira sua palavra de segurança'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.19:3000/api/users/verify-security-word'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'security_word': securityWord}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Palavra de segurança verificada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Redireciona para a tela de redefinição de senha, passando o userId
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: {'userId': userId},
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['error'] ??
                  'Palavra de segurança incorreta ou não encontrada',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _securityWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(color: Color(0xFF4A4A4A)),
        ),
        backgroundColor: const Color(0xFFA7C7E7),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: RichText(
                  text: const TextSpan(
                    text: 'Às vezes a memória falha, mas o',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: ' amor',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: ' não.',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/logoo.jpeg'),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text(
                  'Informe sua palavra de segurança para recuperar sua senha.',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _securityWordController,
                decoration: const InputDecoration(
                  labelText: 'Palavra de Segurança',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: Icon(Icons.security),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _recoverPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA7C7E7),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Recuperar Senha',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF4A4A4A),
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
