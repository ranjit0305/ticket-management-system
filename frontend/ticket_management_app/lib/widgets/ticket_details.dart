import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../models/user.dart';
import '../services/ticket_service.dart';
import 'app_ui.dart';

class TicketDetails extends StatefulWidget {
  final Ticket ticket;
  final String? userRole;
  final TicketService ticketService;

  const TicketDetails({
    super.key,
    required this.ticket,
    required this.userRole,
    required this.ticketService,
  });

  @override
  State<TicketDetails> createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String selectedPriority;
  late String selectedStatus;

  bool isSaving = false;
  bool isDeleting = false;
  bool isAssigning = false;
  bool isLoadingUsers = false;

  List<User> users = [];

  int? selectedUserId;

  final List<String> priorities = ['LOW', 'MEDIUM', 'HIGH'];

  final List<String> statuses = ['OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED'];

  bool get isAdmin => widget.userRole == 'admin';

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.ticket.title);

    descriptionController = TextEditingController(
      text: widget.ticket.description,
    );

    selectedPriority = widget.ticket.priority;
    selectedStatus = widget.ticket.status;

    selectedUserId = widget.ticket.assignedTo;

    // Make sure existing database values
    // don't cause DropdownButton errors.
    if (!priorities.contains(selectedPriority)) {
      priorities.add(selectedPriority);
    }

    if (!statuses.contains(selectedStatus)) {
      statuses.add(selectedStatus);
    }

    if (isAdmin) {
      loadUsers();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // LOAD USERS
  // --------------------------------------------------

  Future<void> loadUsers() async {
    setState(() {
      isLoadingUsers = true;
    });

    try {
      final loadedUsers = await widget.ticketService.getUsers();

      if (!mounted) return;

      setState(() {
        users = loadedUsers;
        isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingUsers = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  // --------------------------------------------------
  // UPDATE TICKET
  // --------------------------------------------------

  Future<void> saveTicket() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title cannot be empty')));

      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedTicket = Ticket(
      id: widget.ticket.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      priority: selectedPriority,
      status: selectedStatus,
      assignedTo: widget.ticket.assignedTo,
      assignedUsername: widget.ticket.assignedUsername,
    );

    try {
      final savedTicket = await widget.ticketService.updateTicket(
        updatedTicket,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket updated successfully')),
      );

      Navigator.pop(context, savedTicket);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update ticket: $e')));
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  // --------------------------------------------------
  // DELETE TICKET
  // --------------------------------------------------

  Future<void> deleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Ticket'),
          content: const Text('Are you sure you want to delete this ticket?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await widget.ticketService.deleteTicket(widget.ticket.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket deleted successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete ticket: $e')));

      setState(() {
        isDeleting = false;
      });
    }
  }

  // --------------------------------------------------
  // ASSIGN TICKET
  // --------------------------------------------------

  Future<void> assignTicket() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a user')));

      return;
    }

    setState(() {
      isAssigning = true;
    });

    try {
      await widget.ticketService.assignTicket(
        widget.ticket.id,
        selectedUserId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket assigned successfully')),
      );

      // Reload the ticket list so the new
      // assignment is reflected.
      Navigator.pop(context, 'assigned');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to assign ticket: $e')));
    }

    if (mounted) {
      setState(() {
        isAssigning = false;
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
      appBar: TicketFlowAppBar(title: 'Ticket #${widget.ticket.id}'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ------------------------------------------
            // TICKET ID
            // ------------------------------------------

            PageIntro(
              title: 'Ticket #${widget.ticket.id}',
              subtitle: 'Review the details and update its progress.',
            ),

            const SizedBox(height: 25),

            // ------------------------------------------
            // TITLE
            // ------------------------------------------
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------
                  // PRIORITY
                  // ------------------------------------------
                  DropdownButtonFormField<String>(
                    value: selectedPriority,

                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),

                    items: priorities.map((priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedPriority = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------
                  // STATUS
                  // ------------------------------------------
                  DropdownButtonFormField<String>(
                    value: selectedStatus,

                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),

                    items: statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------
                  // ASSIGNED USER INFORMATION
                  // ------------------------------------------
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          widget.ticket.assignedUsername != null
                              ? 'Assigned to: ${widget.ticket.assignedUsername}'
                              : 'Not assigned',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  // ------------------------------------------
                  // ADMIN ASSIGNMENT
                  // ------------------------------------------
                  if (isAdmin) ...[
                    const SizedBox(height: 25),

                    const Text(
                      'Assign Ticket',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (isLoadingUsers)
                      const Center(child: CircularProgressIndicator())
                    else if (users.isEmpty)
                      const Text('No users available')
                    else
                      DropdownButtonFormField<int>(
                        value: users.any((user) => user.id == selectedUserId)
                            ? selectedUserId
                            : null,

                        decoration: const InputDecoration(
                          labelText: 'Select User',
                          border: OutlineInputBorder(),
                        ),

                        items: users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text('${user.username} (${user.role})'),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                          });
                        },
                      ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: isAssigning ? null : assignTicket,

                        icon: isAssigning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.person_add),

                        label: Text(
                          isAssigning ? 'ASSIGNING...' : 'ASSIGN TICKET',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ------------------------------------------
                  // SAVE BUTTON
                  // ------------------------------------------
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : saveTicket,

                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),

                      label: Text(isSaving ? 'SAVING...' : 'SAVE CHANGES'),
                    ),
                  ),

                  // ------------------------------------------
                  // DELETE BUTTON - ADMIN ONLY
                  // ------------------------------------------
                  if (isAdmin) ...[
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: isDeleting ? null : deleteTicket,

                        icon: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete),

                        label: Text(
                          isDeleting ? 'DELETING...' : 'DELETE TICKET',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ------------------------------------------
                  // ROLE
                  // ------------------------------------------
                  Center(
                    child: Text(
                      'Logged in as: ${widget.userRole ?? 'user'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
