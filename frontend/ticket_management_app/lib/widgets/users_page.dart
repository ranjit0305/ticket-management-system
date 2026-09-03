import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/ticket_service.dart';
import 'add_user_page.dart';

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
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserPage(ticketService: widget.ticketService),
      ),
    );

    if (created == true && mounted) {
      await loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          if (widget.ticketService.userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Add User',
              onPressed: openAddUserPage,
            ),
        ],
      ),

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
                itemCount: users.length,

                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.username.substring(0, 1).toUpperCase(),
                        ),
                      ),

                      title: Text(user.fullName ?? user.username),

                      subtitle: Text(
                        [
                          '@${user.username}',
                          if (user.department != null &&
                              user.department!.isNotEmpty)
                            user.department!,
                          if (user.email != null && user.email!.isNotEmpty)
                            user.email!,
                        ].join(' • '),
                      ),

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
                  );
                },
              ),
            ),
    );
  }
}
