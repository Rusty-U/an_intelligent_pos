import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool keepLoggedIn = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool("keepLoggedIn");
    if (loggedIn == true && _auth.currentUser != null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // Login
        await _auth.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );

        if (!_auth.currentUser!.emailVerified) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email first")),
          );
          await _auth.signOut();
          setState(() => isLoading = false);
          return;
        }
      } else {
        // SignUp
        UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
        await user.user!.sendEmailVerification();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Verification email sent. Please check inbox.")),
        );
      }

      if (keepLoggedIn) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("keepLoggedIn", true);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Auth error")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isLogin ? _buildLogin() : _buildSignup(),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return _authCard(
      title: "Login",
      buttonText: "Login",
      toggleText: "Don’t have an account? Sign Up",
      onToggle: () => setState(() => isLogin = false),
      showKeepLoggedIn: true,
    );
  }

  Widget _buildSignup() {
    return _authCard(
      title: "Sign Up",
      buttonText: "Sign Up",
      toggleText: "Already have an account? Login",
      onToggle: () => setState(() => isLogin = true),
      showKeepLoggedIn: false,
    );
  }

  Widget _authCard({
    required String title,
    required String buttonText,
    required String toggleText,
    required VoidCallback onToggle,
    bool showKeepLoggedIn = false,
  }) {
    return Card(
      key: ValueKey(title),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            if (showKeepLoggedIn)
              CheckboxListTile(
                value: keepLoggedIn,
                title: const Text("Keep me logged in"),
                onChanged: (v) => setState(() => keepLoggedIn = v ?? false),
              ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 50),
                    ),
                    onPressed: _submit,
                    child: Text(buttonText),
                  ),
            TextButton(onPressed: onToggle, child: Text(toggleText))
          ],
        ),
      ),
    );
  }
}
