import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'app_ui.dart';

class EditTicket extends StatefulWidget {
  final Ticket ticket;

  const EditTicket({super.key, required this.ticket});

  @override
  State<EditTicket> createState() => _EditTicketState();
}

class _EditTicketState extends State<EditTicket> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String selectedPriority;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.ticket.title);

    descriptionController = TextEditingController(
      text: widget.ticket.description,
    );

    selectedPriority = widget.ticket.priority;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveTicket() {
    final updatedTicket = Ticket(
      id: widget.ticket.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      priority: selectedPriority,
      status: widget.ticket.status,
    );

    Navigator.pop(context, updatedTicket);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.canvas,
      appBar: const TicketFlowAppBar(title: 'Edit Ticket'),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: titleController,

              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,

              maxLines: 4,

              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedPriority,

              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
                DropdownMenuItem(value: 'LOW', child: Text('LOW')),
              ],

              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: saveTicket,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
