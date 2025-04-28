import 'dart:async'; 

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;
  String _apiResponse = '';
  DateTime? _loginTime;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _loadTokenAndStartSession();
  }

  Future<void> _loadTokenAndStartSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    setState(() {
      _token = storedToken;
      _loginTime = DateTime.now(); 
    });

    _startSessionTimer(); 
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel(); 
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) { 
      _checkSessionValidity();
    });
  }

  Future<void> _checkSessionValidity() async {
    if (_loginTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_loginTime!);

    if (difference.inSeconds >= 30) { 
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _goToLoginPage(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _deleteToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token başarıyla silindi!')),
    );

    setState(() {
      _token = null;
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Kullanıcı';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ana Sayfa'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 32),
                Text(
                  'Hoşgeldin, $userName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  _token != null ? ,
                  style: TextStyle(fontSize: 16, color: _token != null ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  _apiResponse,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _goToLoginPage(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Giriş Menüsüne Dön'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _deleteToken(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Tokenı Sil', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}