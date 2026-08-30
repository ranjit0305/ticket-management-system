import 'package:flutter/material.dart';
import '../models/ticket.dart';

class CreateTicket extends StatefulWidget {
  const CreateTicket({
    super.key,
  });

  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  // --------------------------------------------------
  // FORM KEY
  // --------------------------------------------------

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  // --------------------------------------------------
  // CONTROLLERS
  // --------------------------------------------------

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // --------------------------------------------------
  // DEFAULT PRIORITY
  // --------------------------------------------------

  String selectedPriority = 'HIGH';

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // CREATE TICKET
  // --------------------------------------------------

  void createTicket() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final newTicket = Ticket(
      // Backend will generate the actual ID.
      id: '',

      title: titleController.text.trim(),

      description:
          descriptionController.text.trim(),

      priority: selectedPriority,

      status: 'OPEN',
    );

    Navigator.pop(
      context,
      newTicket,
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Ticket',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            children: [

              // ----------------------------------------
              // TITLE
              // ----------------------------------------

              TextFormField(
                controller: titleController,

                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter ticket title',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ----------------------------------------
              // DESCRIPTION
              // ----------------------------------------

              TextFormField(
                controller:
                    descriptionController,

                maxLines: 4,

                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ----------------------------------------
              // PRIORITY
              // ----------------------------------------

              DropdownButtonFormField<String>(
                initialValue:
                    selectedPriority,

                decoration:
                    const InputDecoration(
                  labelText: 'Priority',
                  border:
                      OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'HIGH',
                    child: Text('HIGH'),
                  ),

                  DropdownMenuItem(
                    value: 'MEDIUM',
                    child: Text('MEDIUM'),
                  ),

                  DropdownMenuItem(
                    value: 'LOW',
                    child: Text('LOW'),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // ----------------------------------------
              // CREATE BUTTON
              // ----------------------------------------

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: createTicket,

                  child: const Text(
                    'Create Ticket',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}