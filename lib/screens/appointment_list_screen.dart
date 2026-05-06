import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import '../widgets/appointment_card.dart';

/// Appointment list screen with tab filters (Today, Upcoming, Past)
class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  int _selectedTab = 0;
  final _searchController = TextEditingController();
  String _localSearch = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppointmentProvider>(
          builder: (context, provider, _) {
            // Get appointments based on selected tab
            List appointments;
            switch (_selectedTab) {
              case 0:
                appointments = provider.todayAppointments;
                break;
              case 1:
                appointments = provider.upcomingAppointments;
                break;
              case 2:
                appointments = provider.pastAppointments;
                break;
              default:
                appointments = provider.todayAppointments;
            }

            // Apply local search
            if (_localSearch.isNotEmpty) {
              appointments = appointments.where((a) {
                return a.name
                        .toLowerCase()
                        .contains(_localSearch.toLowerCase()) ||
                    a.id.toLowerCase().contains(_localSearch.toLowerCase());
              }).toList();
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _localSearch = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or service...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tab filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTab('Today', 0),
                      const SizedBox(width: 8),
                      _buildTab('Upcoming', 1),
                      const SizedBox(width: 8),
                      _buildTab('Past', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Appointment list
                Expanded(
                  child: appointments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appt = appointments[index];
                            return AppointmentCard(
                              appointment: appt,
                              actions: _buildCardActions(appt, provider),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildCardActions(dynamic appt, AppointmentProvider provider) {
    if (appt.status == AppointmentStatus.scheduled) {
      return [
        OutlinedButton(
          onPressed: () => provider.markCancelled(appt.id),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cancelled,
            side: const BorderSide(color: AppColors.cancelled),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 13)),
        ),
      ];
    }
    return [];
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined,
              size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Book a new appointment to get started',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
