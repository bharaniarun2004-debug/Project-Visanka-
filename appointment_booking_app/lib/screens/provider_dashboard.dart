import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/appointment.dart';
import 'role_selection_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _providerName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAppointments();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _providerName = user.name;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await _apiService.getProviderRequests();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(int appointmentId, String status) async {
    try {
      final result = await _apiService.updateAppointmentStatus(appointmentId, status);
      
      if (result['success']) {
        String message = status == 'accepted' 
            ? 'Appointment accepted! Meeting ID: ${result['meeting_id']}'
            : 'Appointment rejected';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _loadAppointments();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Requests'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_providerName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage your appointment requests',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _appointments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No appointment requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAppointments,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return _buildAppointmentCard(appointment);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final date = DateFormat('MMM dd, yyyy').format(DateTime.parse(appointment.date));
    final time = appointment.time.substring(0, 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.userName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.userEmail ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${appointment.reason}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (appointment.meetingId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Meeting ID: ${appointment.meetingId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (appointment.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(appointment.appointmentId, 'accepted'),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(appointment.appointmentId, 'rejected'),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}