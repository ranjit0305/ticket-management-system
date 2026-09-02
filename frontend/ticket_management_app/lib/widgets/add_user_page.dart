import 'package:flutter/material.dart';

import '../services/ticket_service.dart';
import 'app_ui.dart';

class AddUserPage extends StatefulWidget {
  final TicketService service;

  const AddUserPage({super.key, required this.service});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // CREATE USER
  // --------------------------------------------------

  Future<void> createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await widget.service.createUser(
        usernameController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      // Return to UsersPage and tell it
      // that the user was created successfully.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.canvas,
      appBar: const TicketFlowAppBar(title: 'Add User'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const PageIntro(
                title: 'Create a user',
                subtitle: 'Add a team member who can receive support tickets.',
              ),

              const SizedBox(height: 22),

              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ----------------------------------------
                    // USERNAME
                    // ----------------------------------------

                    TextFormField(
                      controller: usernameController,
                      enabled: !isLoading,

                      decoration: AppUi.input(
                        label: 'Username',
                        hint: 'Enter a username',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter username';
                        }

                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ----------------------------------------
                    // PASSWORD
                    // ----------------------------------------
                    TextFormField(
                      controller: passwordController,
                      enabled: !isLoading,

                      obscureText: obscurePassword,

                      decoration: AppUi.input(
                        label: 'Password',
                        hint: 'Enter a temporary password',
                        prefixIcon: const Icon(Icons.lock_outline),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // ----------------------------------------
                    // CREATE BUTTON
                    // ----------------------------------------
                    SizedBox(
                      height: 50,

                      child: ElevatedButton(
                        onPressed: isLoading ? null : createUser,

                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create User',

                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
