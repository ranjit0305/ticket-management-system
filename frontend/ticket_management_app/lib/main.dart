import 'package:flutter/material.dart';

import 'services/ticket_service.dart';
import 'widgets/home_page.dart';
import 'widgets/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketService = TicketService();

    return MaterialApp(
      title: 'Ticket Management System',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      routes: {
        '/login': (context) => LoginPage(
              ticketService: ticketService,
            ),
      },

      home: FutureBuilder<bool>(
        future: ticketService.loadToken(),

        builder: (context, snapshot) {
          // ------------------------------------------
          // CHECKING TOKEN
          // ------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // ------------------------------------------
          // TOKEN EXISTS
          // ------------------------------------------

          if (snapshot.data == true) {
            return MyHomePage(
              ticketService: ticketService,
            );
          }

          // ------------------------------------------
          // NO TOKEN
          // ------------------------------------------

          return LoginPage(
            ticketService: ticketService,
          );
        },
      ),
    );
  }
}