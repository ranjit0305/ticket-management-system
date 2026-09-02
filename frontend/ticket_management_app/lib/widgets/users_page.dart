import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/ticket_service.dart';
import 'add_user_page.dart';
import 'app_ui.dart';

class UsersPage extends StatefulWidget {
  final TicketService ticketService;

  const UsersPage({super.key, required this.ticketService});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // --------------------------------------------------
  // LOAD USERS
  // --------------------------------------------------

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedUsers = await widget.ticketService.getUsers();

      if (!mounted) return;

      setState(() {
        users = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load users';
      });
    }
  }

  // --------------------------------------------------
  // OPEN ADD USER PAGE
  // --------------------------------------------------

  Future<void> openAddUserPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserPage(service: widget.ticketService),
      ),
    );

    // If a user was successfully created,
    // reload the users list.
    if (result == true && mounted) {
      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Users',
          style: TextStyle(color: AppUi.ink, fontWeight: FontWeight.bold),
        ),

        actions: [
          // ------------------------------------------
          // ADD USER - ADMIN ONLY
          // ------------------------------------------

          if (widget.ticketService.userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Add User',
              onPressed: openAddUserPage,
            ),
        ],
      ),

      // ------------------------------------------------
      // BODY
      // ------------------------------------------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: loadUsers,
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            )
          : users.isEmpty
          ? const Center(child: Text('No users found'))
          : RefreshIndicator(
              onRefresh: loadUsers,

              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                itemCount: users.length + 1,

                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 22),
                      child: PageIntro(
                        title: 'Team members',
                        subtitle: 'People who can access and work on tickets.',
                      ),
                    );
                  }
                  final user = users[index - 1];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: AppUi.surface(),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                          ),
                        ),

                        title: Text(user.username),

                        subtitle: Text('User ID: ${user.id}'),

                        trailing: Text(
                          user.role.toUpperCase(),

                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color: user.role == 'admin'
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
