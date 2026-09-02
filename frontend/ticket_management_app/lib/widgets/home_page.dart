import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'create_ticket.dart';
import 'ticket_details.dart';
import 'users_page.dart';

class MyHomePage extends StatefulWidget {
  final TicketService ticketService;

  const MyHomePage({super.key, required this.ticketService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ticket> tickets = [];

  bool isLoading = false;
  String? errorMessage;

  // ==========================================================
  // STATISTICS
  // ==========================================================

  int get totalTickets => tickets.length;

  int get openTickets =>
      tickets.where((ticket) => ticket.status.toUpperCase() == 'OPEN').length;

  int get inProgressTickets => tickets
      .where(
        (ticket) =>
            ticket.status.toUpperCase() == 'IN_PROGRESS' ||
            ticket.status.toUpperCase() == 'IN PROGRESS',
      )
      .length;

  int get resolvedTickets => tickets
      .where((ticket) => ticket.status.toUpperCase() == 'RESOLVED')
      .length;

  int get closedTickets =>
      tickets.where((ticket) => ticket.status.toUpperCase() == 'CLOSED').length;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  // ==========================================================
  // LOAD TICKETS
  // ==========================================================

  Future<void> loadTickets() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final loadedTickets = await widget.ticketService.getTickets();

      if (!mounted) return;

      setState(() {
        tickets = loadedTickets;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load tickets';
      });
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await widget.ticketService.logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 23),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
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

  // ==========================================================
  // STATUS CHIP
  // ==========================================================

  Widget buildStatusChip(String status) {
    final normalized = status.toUpperCase().replaceAll('_', ' ');

    Color color;
    IconData icon;

    switch (normalized) {
      case 'OPEN':
        color = Colors.blue;
        icon = Icons.radio_button_checked;
        break;

      case 'IN PROGRESS':
        color = Colors.orange;
        icon = Icons.timelapse;
        break;

      case 'RESOLVED':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;

      case 'CLOSED':
        color = Colors.grey;
        icon = Icons.lock_outline;
        break;

      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),

          const SizedBox(width: 5),

          Text(
            normalized,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.ticketService.userRole == 'admin';

    final role = widget.ticketService.userRole ?? 'user';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'TicketFlow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),

        actions: [
          // ------------------------------------------------------
          // ROLE
          // ------------------------------------------------------

          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colors.deepPurple.withOpacity(0.10)
                  : Colors.blue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isAdmin
                      ? Icons.admin_panel_settings_outlined
                      : Icons.person_outline,
                  size: 16,
                  color: isAdmin ? Colors.deepPurple : Colors.blue,
                ),

                const SizedBox(width: 5),

                Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? Colors.deepPurple : Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // ADMIN USERS
          // ------------------------------------------------------
          if (isAdmin)
            IconButton(
              tooltip: 'Manage Users',
              icon: const Icon(Icons.people_outline, color: Color(0xFF374151)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UsersPage(ticketService: widget.ticketService),
                  ),
                );

                if (!mounted) return;

                await loadTickets();
              },
            ),

          // ------------------------------------------------------
          // LOGOUT
          // ------------------------------------------------------
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF374151)),
            onPressed: logout,
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: loadTickets,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),

                children: [
                  // ==================================================
                  // DASHBOARD TITLE
                  // ==================================================

                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isAdmin
                        ? 'Overview of all support tickets'
                        : 'Overview of your assigned tickets',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // STATISTICS
                  // ==================================================
                  Row(
                    children: [
                      buildStatCard(
                        title: 'Total',
                        value: totalTickets,
                        icon: Icons.confirmation_number_outlined,
                        color: Colors.indigo,
                      ),

                      const SizedBox(width: 12),

                      buildStatCard(
                        title: 'Open',
                        value: openTickets,
                        icon: Icons.radio_button_checked,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      buildStatCard(
                        title: 'In Progress',
                        value: inProgressTickets,
                        icon: Icons.timelapse,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 12),

                      buildStatCard(
                        title: 'Resolved',
                        value: resolvedTickets,
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      buildStatCard(
                        title: 'Closed',
                        value: closedTickets,
                        icon: Icons.lock_outline,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 12),

                      const Expanded(child: SizedBox()),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // RECENT TICKETS HEADER
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Tickets',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),

                      Text(
                        '${tickets.length} total',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // EMPTY STATE
                  // ==================================================
                  if (tickets.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 50,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 52,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'No tickets found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Create a ticket to get started.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                  // ==================================================
                  // TICKETS
                  // ==================================================
                  ...tickets.map((ticket) => _buildTicketPreview(ticket)),
                ],
              ),
            ),

      // ========================================================
      // CREATE TICKET
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 5,

        onPressed: () async {
          final newTicket = await Navigator.push<Ticket>(
            context,
            MaterialPageRoute(builder: (context) => const CreateTicket()),
          );

          if (newTicket == null) return;

          try {
            final createdTicket = await widget.ticketService.createTicket(
              newTicket,
            );

            if (!mounted) return;

            setState(() {
              tickets.insert(0, createdTicket);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket created successfully')),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create ticket: $e')),
            );
          }
        },

        icon: const Icon(Icons.add),

        label: const Text(
          'New Ticket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================================
  // TICKET PREVIEW
  // ==========================================================

  Widget _buildTicketPreview(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5E7EB)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetails(
                ticket: ticket,
                userRole: widget.ticketService.userRole,
                ticketService: widget.ticketService,
              ),
            ),
          );

          if (!mounted) return;

          await loadTickets();
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // TOP ROW
              // --------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Ticket #${ticket.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          ticket.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  buildStatusChip(ticket.status),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // DESCRIPTION
              // --------------------------------------------------
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // BOTTOM ROW
              // --------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    ticket.priority,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 80,
              width: 80,

              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_outlined,
                color: Colors.red,
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Unable to load tickets',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadTickets,

              icon: const Icon(Icons.refresh),

              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
