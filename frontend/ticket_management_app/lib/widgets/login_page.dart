import 'package:flutter/material.dart';

import '../services/ticket_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final TicketService ticketService;

  const LoginPage({
    super.key,
    required this.ticketService,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<void> login() async {
    final username =
        usernameController.text.trim();

    final password =
        passwordController.text;

    // -----------------------------------------------
    // VALIDATION
    // -----------------------------------------------

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage =
            'Please enter username and password';
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await widget.ticketService.login(
        username,
        password,
      );

      if (!mounted) return;

      // ---------------------------------------------
      // LOGIN SUCCESS
      // ---------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            ticketService: widget.ticketService,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Invalid username or password';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            // ----------------------------------------
            // TITLE
            // ----------------------------------------

            const Text(
              'Ticket Management System',

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // ----------------------------------------
            // USERNAME
            // ----------------------------------------

            TextField(
              controller: usernameController,

              textInputAction:
                  TextInputAction.next,

              decoration:
                  const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------
            // PASSWORD
            // ----------------------------------------

            TextField(
              controller: passwordController,

              obscureText: true,

              onSubmitted: (_) {
                if (!isLoading) {
                  login();
                }
              },

              decoration:
                  const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.lock,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------
            // ERROR MESSAGE
            // ----------------------------------------

            if (errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),

                child: Text(
                  errorMessage!,

                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),

            // ----------------------------------------
            // LOGIN BUTTON
            // ----------------------------------------

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    isLoading ? null : login,

                child: Padding(
                  padding:
                      const EdgeInsets.all(14),

                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'LOGIN',

                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}