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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1F2937),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),

      routes: {'/login': (context) => LoginPage(ticketService: ticketService)},

      home: FutureBuilder<bool>(
        future: ticketService.loadToken(),

        builder: (context, snapshot) {
          // ------------------------------------------
          // CHECKING TOKEN
          // ------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ------------------------------------------
          // TOKEN EXISTS
          // ------------------------------------------

          if (snapshot.data == true) {
            return MyHomePage(ticketService: ticketService);
          }

          // ------------------------------------------
          // NO TOKEN
          // ------------------------------------------

          return LoginPage(ticketService: ticketService);
        },
      ),
    );
  }
}
