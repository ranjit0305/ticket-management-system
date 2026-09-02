import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'ticket_details.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  final Function(Ticket) onTicketUpdated;

  final VoidCallback onTicketDeleted;

  final String? userRole;

  final TicketService ticketService;
  final VoidCallback onTicketAssigned;
  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTicketUpdated,
    required this.onTicketDeleted,
    required this.onTicketAssigned,
    required this.userRole,
    required this.ticketService,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetails(
              ticket: ticket,
              userRole: userRole,
              ticketService: ticketService,
            ),
          ),
        );

        // -----------------------------------------------
        // TICKET UPDATED
        // -----------------------------------------------

        if (result is Ticket) {
          onTicketUpdated(result);
        }
        // -----------------------------------------------
        // TICKET DELETED
        // -----------------------------------------------
        else if (result == true) {
          onTicketDeleted();
        } else if (result == 'assigned') {
          onTicketUpdated(ticket);
        }
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // -------------------------------------------
            // TICKET ID
            // -------------------------------------------

            Text(
              'Ticket #${ticket.id}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // -------------------------------------------
            // TITLE
            // -------------------------------------------
            Text(ticket.title, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            // -------------------------------------------
            // PRIORITY + STATUS
            // -------------------------------------------
            Row(
              children: [
                Text(
                  ticket.priority,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                Text(
                  ticket.status,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------------------------------
            // ASSIGNED USER
            // -------------------------------------------
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),

                const SizedBox(width: 6),

                Text(
                  ticket.assignedUsername != null
                      ? 'Assigned to: ${ticket.assignedUsername}'
                      : 'Not assigned',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // -------------------------------------------
            // ROLE INFORMATION
            // -------------------------------------------
            if (userRole != null)
              Text(
                'Role: $userRole',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
