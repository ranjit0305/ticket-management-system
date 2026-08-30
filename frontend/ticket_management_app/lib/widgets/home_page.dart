import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'create_ticket.dart';
import 'ticket_card.dart';
import 'users_page.dart';

class MyHomePage extends StatefulWidget {
  final TicketService ticketService;

  const MyHomePage({
    super.key,
    required this.ticketService,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ticket> tickets = [];

  bool isLoading = false;

  String? errorMessage;

  // ==================================================
  // TICKET STATISTICS
  // ==================================================

  int get totalTickets => tickets.length;

  int get openTickets =>
      tickets.where(
        (ticket) => ticket.status == 'OPEN',
      ).length;

  int get inProgressTickets =>
      tickets.where(
        (ticket) => ticket.status == 'IN PROGRESS',
      ).length;

  int get completedTickets =>
      tickets.where(
        (ticket) => ticket.status == 'COMPLETED',
      ).length;

  // ==================================================
  // STATISTIC CARD
  // ==================================================

  Widget buildStatCard(
    String title,
    int value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
              ),

              const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value.toString(),

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // INIT
  // ==================================================

  @override
  void initState() {
    super.initState();

    loadTickets();
  }

  // ==================================================
  // LOAD TICKETS
  // ==================================================

  Future<void> loadTickets() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final loadedTickets =
          await widget.ticketService.getTickets();

      if (!mounted) return;

      setState(() {
        tickets = loadedTickets;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load tickets';
      });
    }
  }

  // ==================================================
  // LOGOUT
  // ==================================================

  Future<void> logout() async {
    await widget.ticketService.logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ==================================================
      // APP BAR
      // ==================================================

      appBar: AppBar(
        title: const Text(
          'Ticket Management System',
        ),

        actions: [
          // ----------------------------------------------
          // ROLE
          // ----------------------------------------------

          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),

              child: Text(
                widget.ticketService.userRole ?? 'user',

                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ----------------------------------------------
          // USERS - ADMIN ONLY
          // ----------------------------------------------

          if (widget.ticketService.userRole == 'admin')
            IconButton(
              icon: const Icon(
                Icons.people,
              ),

              tooltip: 'Users',

              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => UsersPage(
                      ticketService:
                          widget.ticketService,
                    ),
                  ),
                );
              },
            ),

          // ----------------------------------------------
          // LOGOUT
          // ----------------------------------------------

          IconButton(
            icon: const Icon(
              Icons.logout,
            ),

            tooltip: 'Logout',

            onPressed: logout,
          ),
        ],
      ),

      // ==================================================
      // BODY
      // ==================================================

      body: isLoading

          // ------------------------------------------------
          // LOADING
          // ------------------------------------------------

          ? const Center(
              child: CircularProgressIndicator(),
            )

          // ------------------------------------------------
          // ERROR
          // ------------------------------------------------

          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Text(
                        errorMessage!,

                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      ElevatedButton(
                        onPressed: loadTickets,

                        child: const Text(
                          'RETRY',
                        ),
                      ),
                    ],
                  ),
                )

              // ------------------------------------------------
              // MAIN CONTENT
              // ------------------------------------------------

              : Column(
                  children: [

                    // ==========================================
                    // DASHBOARD
                    // ==========================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        4,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Dashboard',

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // ------------------------------------
                          // FIRST ROW
                          // ------------------------------------

                          Row(
                            children: [
                              buildStatCard(
                                'Total',
                                totalTickets,
                                Icons.confirmation_number,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              buildStatCard(
                                'Open',
                                openTickets,
                                Icons.lock_open,
                              ),
                            ],
                          ),

                          // ------------------------------------
                          // SECOND ROW
                          // ------------------------------------

                          Row(
                            children: [
                              buildStatCard(
                                'In Progress',
                                inProgressTickets,
                                Icons.pending_actions,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              buildStatCard(
                                'Completed',
                                completedTickets,
                                Icons.check_circle,
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Tickets',

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // TICKET LIST
                    // ==========================================

                    Expanded(
                      child: tickets.isEmpty

                          // ------------------------------------
                          // NO TICKETS
                          // ------------------------------------

                          ? RefreshIndicator(
                              onRefresh: loadTickets,

                              child: ListView(
                                children: const [
                                  SizedBox(
                                    height: 250,

                                    child: Center(
                                      child: Text(
                                        'No tickets found',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )

                          // ------------------------------------
                          // TICKETS
                          // ------------------------------------

                          : RefreshIndicator(
                              onRefresh: loadTickets,

                              child: ListView.builder(
                                itemCount: tickets.length,

                                itemBuilder:
                                    (context, index) {
                                  final ticket =
                                      tickets[index];

                                  return TicketCard(
                                    ticket: ticket,

                                    // --------------------------
                                    // USER ROLE
                                    // --------------------------

                                    userRole: widget
                                        .ticketService
                                        .userRole,

                                    // --------------------------
                                    // TICKET SERVICE
                                    // --------------------------

                                    ticketService:
                                        widget
                                            .ticketService,

                                    // --------------------------
                                    // UPDATE
                                    // --------------------------

                                    onTicketUpdated:
                                        (updatedTicket) async {
                                      try {
                                        final savedTicket =
                                            await widget
                                                .ticketService
                                                .updateTicket(
                                          updatedTicket,
                                        );

                                        if (!mounted) {
                                          return;
                                        }

                                        setState(() {
                                          tickets[index] =
                                              savedTicket;
                                        });

                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ticket updated successfully',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        print(e);

                                        if (!mounted) {
                                          return;
                                        }

                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to update ticket: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },

                                    // --------------------------
                                    // DELETE
                                    // --------------------------

                                    onTicketDeleted:
                                        () async {
                                      try {
                                        await widget
                                            .ticketService
                                            .deleteTicket(
                                          ticket.id,
                                        );

                                        if (!mounted) {
                                          return;
                                        }

                                        setState(() {
                                          tickets.removeWhere(
                                            (t) =>
                                                t.id ==
                                                ticket.id,
                                          );
                                        });

                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ticket deleted successfully',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        print(e);

                                        if (!mounted) {
                                          return;
                                        }

                                        ScaffoldMessenger
                                            .of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete ticket: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },

                                    // --------------------------
                                    // ASSIGN
                                    // --------------------------

                                    onTicketAssigned:
                                        () async {
                                      await loadTickets();
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),

      // ==================================================
// CREATE TICKET
// ==================================================

floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final newTicket =
        await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateTicket(),
      ),
    );

    // ----------------------------------------------
    // CANCELLED
    // ----------------------------------------------

    if (newTicket == null) {
      return;
    }

    // ----------------------------------------------
    // CREATE
    // ----------------------------------------------

    try {
      final createdTicket =
          await widget.ticketService.createTicket(
        newTicket,
      );

      if (!mounted) return;

      setState(() {
        tickets.add(createdTicket);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ticket created successfully',
          ),
        ),
      );
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create ticket: $e',
          ),
        ),
      );
    }
  },

  child: const Icon(
    Icons.add,
  ),
),
    );
  }
}