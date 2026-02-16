import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/provider.dart';
import 'provider_profile_screen.dart';
import 'my_appointments_screen.dart';
import 'role_selection_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Provider> _providers = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProviders();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.name;
      });
    }
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await _apiService.getProviders();
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading providers: $e')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Providers'),
        backgroundColor: Colors.blue,
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
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_userName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Book an appointment with our providers',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _providers.isEmpty
                      ? const Center(
                          child: Text('No providers available'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProviders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _providers.length,
                            itemBuilder: (context, index) {
                              final provider = _providers[index];
                              return _buildProviderCard(provider);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyAppointmentsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('My Appointments'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderProfileScreen(provider: provider),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.serviceName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}