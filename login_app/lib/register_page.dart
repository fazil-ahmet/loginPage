import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _message = 'Şifreler uyuşmuyor!';
      });
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      setState(() {
        _message = 'Kayıt Başarılı! Giriş ekranına dön.';
      });
    } catch (e) {
      setState(() {
        _message = 'Kayıt Hatası: ${e.toString()}';
      });
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Kayıt Ol'), centerTitle: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.person_add, size: 80),
                const SizedBox(height: 32),
                _buildTextField(_nameController, 'İsim', false), 
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', false),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Şifre', true),
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, 'Şifre Tekrar', true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Kayıt Ol'),
                ),
                TextButton(
                  onPressed: _goBack,
                  child: const Text('Giriş ekranına dön'),
                ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}