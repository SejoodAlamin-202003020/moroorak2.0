import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investigator_auth_provider.dart';
import '../services/investigator_report_service.dart';
import '../models/report.dart';
import 'report_details_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'new_reports_screen.dart';
import 'under_review_reports_screen.dart';
import 'closed_reports_screen.dart';
import 'rejected_reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Report> _reports = [];
  List<Report> _allReports = [];
  final InvestigatorReportService _reportService = InvestigatorReportService();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isSearching = true);
    try {
      final reports = await _reportService.getAllReports();
      setState(() {
        _allReports = reports;
        _reports = reports;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  Future<void> _searchReports(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _reports = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _reportService.searchReports(query);
      setState(() {
        _reports = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching reports: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboardContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    final reports = _reports.isNotEmpty ? _reports : _allReports;
    final newReports = reports.where((r) => r.reportStatus == 'pending').length;
    final underReviewReports =
        reports.where((r) => r.reportStatus == 'under_review').length;
    final approvedReports =
        reports.where((r) => r.reportStatus == 'approved').length;
    final rejectedReports =
        reports.where((r) => r.reportStatus == 'rejected').length;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investigator Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to Moroorak Traffic Investigation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search reports by report number, plate number, license, or name...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF556B2F)),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchReports('');
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _searchReports,
            ),
            const SizedBox(height: 32),
            // Status Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'New Reports',
                    newReports.toString(),
                    const Color(0xFFFFA726),
                    Icons.new_releases,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewReportsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Under Review',
                    underReviewReports.toString(),
                    const Color(0xFF42A5F5),
                    Icons.hourglass_top,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UnderReviewReportsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Approved',
                    approvedReports.toString(),
                    const Color(0xFF4CAF50),
                    Icons.done_all,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClosedReportsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Rejected',
                    rejectedReports.toString(),
                    const Color(0xFFEF5350),
                    Icons.cancel,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RejectedReportsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTable() {
    final displayReports = _reports.isNotEmpty ? _reports : _allReports;

    if (displayReports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No reports available'),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Report Number',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Reporter Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Report Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Location',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Report Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('View Details',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: displayReports.map((report) {
            return DataRow(
              cells: [
                DataCell(Text(report.reportNumber ?? 'Not specified')),
                DataCell(Text(report.reporterName ?? 'Not specified')),
                DataCell(Text(
                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                )),
                DataCell(Text(report.location ?? 'Not specified')),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.reportStatus ?? 'pending'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(report.reportStatus ?? 'pending'),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReportDetailsScreen(report: report),
                        ),
                      );
                    },
                    child: const Text('View'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'under_review':
        return const Color(0xFF42A5F5);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'New';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not specified';
    }
  }

  @override
  Widget build(BuildContext context) {
    final investigator = context.watch<InvestigatorAuthProvider>().investigator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moroorak - Traffic Investigation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<InvestigatorAuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboardContent()
          : _selectedIndex == 1
              ? const NotificationsScreen()
              : ProfileScreen(investigator: investigator!),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
