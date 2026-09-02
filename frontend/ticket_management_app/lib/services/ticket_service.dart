import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ticket.dart';
import '../models/user.dart';

class TicketService {
  // --------------------------------------------------
  // BASE URL
  // --------------------------------------------------

  // Android emulator -> Mac localhost
  final String baseUrl = 'https://ticket-management-system-1-fy3y.onrender.com';

  String? accessToken;
  String? userRole;

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    final data = jsonDecode(response.body);

    accessToken = data['access_token'];
    userRole = data['role'];

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('access_token', accessToken!);

    await prefs.setString('user_role', userRole!);
  }

  // --------------------------------------------------
  // LOAD TOKEN
  // --------------------------------------------------

  Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString('access_token');

    userRole = prefs.getString('user_role');

    return accessToken != null;
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> logout() async {
    accessToken = null;
    userRole = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('user_role');
  }

  // --------------------------------------------------
  // GET ALL TICKETS
  // --------------------------------------------------

  Future<List<Ticket>> getTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tickets: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  // --------------------------------------------------
  // GET USERS
  // --------------------------------------------------

  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load users: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) => User.fromJson(json)).toList();
  }

  // --------------------------------------------------
  // ASSIGN TICKET
  // --------------------------------------------------

  Future<void> assignTicket(String ticketId, int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tickets/$ticketId/assign/$userId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign ticket: ${response.body}');
    }
  }

  // --------------------------------------------------
  // CREATE TICKET
  // --------------------------------------------------

  Future<Ticket> createTicket(Ticket ticket) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $accessToken',
      },

      // IMPORTANT:
      // Do NOT send ticket.id.
      // Backend will generate the ID.
      body: jsonEncode({
        'title': ticket.title,
        'description': ticket.description,
        'priority': ticket.priority,
        'status': ticket.status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create ticket: ${response.body}');
    }

    return Ticket.fromJson(jsonDecode(response.body));
  }

  // --------------------------------------------------
  // UPDATE TICKET
  // --------------------------------------------------

  Future<Ticket> updateTicket(Ticket ticket) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tickets/${ticket.id}'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $accessToken',
      },

      body: jsonEncode(ticket.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ticket: ${response.body}');
    }

    return Ticket.fromJson(jsonDecode(response.body));
  }

  // --------------------------------------------------
  // DELETE TICKET
  // --------------------------------------------------

  Future<void> deleteTicket(String ticketId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tickets/$ticketId'),

      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete ticket: ${response.body}');
    }
  }
  // --------------------------------------------------
  // CREATE USER - ADMIN ONLY
  // --------------------------------------------------

  Future<void> createUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user: ${response.body}');
    }
  }
}
