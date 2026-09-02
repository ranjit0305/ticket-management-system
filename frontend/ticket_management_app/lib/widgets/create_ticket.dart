import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'app_ui.dart';

class CreateTicket extends StatefulWidget {
  const CreateTicket({super.key});
  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedPriority = 'HIGH';
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void createTicket() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Ticket(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority,
        status: 'OPEN',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppUi.canvas,
    appBar: const TicketFlowAppBar(title: 'New Ticket'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageIntro(
              title: 'Create a ticket',
              subtitle: 'Share the details and we will help get it resolved.',
            ),
            const SizedBox(height: 22),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: AppUi.input(
                      label: 'Title',
                      hint: 'What do you need help with?',
                      prefixIcon: const Icon(Icons.subject_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: AppUi.input(
                      label: 'Description',
                      hint: 'Describe the issue',
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: AppUi.input(
                      label: 'Priority',
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'HIGH', child: Text('High')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    ],
                    onChanged: (v) => setState(() => selectedPriority = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: createTicket,
                      icon: const Icon(Icons.add),
                      label: const Text('CREATE TICKET'),
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
