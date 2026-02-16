import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';

class ApiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  Future<List<Provider>> getProviders() async {
    final token = await _getToken();
    print('Fetching providers...');
    try {
      final response = await http.get(
        Uri.parse(Constants.providersUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('getProviders response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> providersJson = data['data'];
          return providersJson.map((json) => Provider.fromJson(json)).toList();
        }
      }
      print('getProviders failed: ${response.body}');
    } catch (e) {
      print('getProviders error: $e');
    }
    throw Exception('Failed to load providers');
  }

  Future<List<Appointment>> myAppointments() async {
    final token = await _getToken();
    print('Fetching my appointments...');
    try {
      final response = await http.get(
        Uri.parse(Constants.myAppointmentsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('myAppointments response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> appointmentsJson = data['data'];
          return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        }
      }
      print('myAppointments failed: ${response.body}');
    } catch (e) {
       print('myAppointments error: $e');
    }
    throw Exception('Failed to load appointments');
  }

  Future<List<Appointment>> getProviderRequests() async {
    final token = await _getToken();
    print('Fetching provider requests...');
    try {
      final response = await http.get(
        Uri.parse(Constants.providerRequestsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('getProviderRequests response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> appointmentsJson = data['data'];
          return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('getProviderRequests error: $e');
    }
    throw Exception('Failed to load requests');
  }

  Future<Map<String, dynamic>> bookAppointment(int providerId, String date, String time, String reason) async {
    final token = await _getToken();
    print('Booking appointment...');
    try {
      final response = await http.post(
        Uri.parse(Constants.appointmentsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider_id': providerId,
          'date': date,
          'time': time,
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 10));

      print('bookAppointment response: ${response.statusCode}');
      return jsonDecode(response.body);
    } catch (e) {
      print('bookAppointment error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(int appointmentId, String status) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(Constants.updateStatusUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'appointment_id': appointmentId,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      print('updateAppointmentStatus error: $e');
      throw e;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(Constants.updateStatusUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'appointment_id': appointmentId,
          'status': 'cancelled',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      print('cancelAppointment error: $e');
    }
    return false;
  }
}