import 'package:flutter/material.dart';

import '../services/ticket_service.dart';
import 'app_ui.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final TicketService ticketService;
  const LoginPage({super.key, required this.ticketService});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  Future<void> login() async {
    final username = usernameController.text.trim();
    if (username.isEmpty || passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter username and password');
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await widget.ticketService.login(username, passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MyHomePage(ticketService: widget.ticketService),
        ),
      );
    } catch (_) {
      if (mounted)
        setState(() => errorMessage = 'Invalid username or password');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppUi.canvas,
    appBar: const TicketFlowAppBar(title: 'TicketFlow'),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppUi.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_outline, color: AppUi.primary),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppUi.title,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to manage your support tickets.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: AppUi.input(
                    label: 'Username',
                    hint: 'Enter your username',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onSubmitted: (_) {
                    if (!isLoading) login();
                  },
                  decoration: AppUi.input(
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SIGN IN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
