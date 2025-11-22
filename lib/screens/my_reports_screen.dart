import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import '../models/report.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _reportService = ReportService();
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.id;
      _reports = await _reportService.getUserReports(userId);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load reports: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReports,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reports.isEmpty
                  ? Center(
                      child: Text(
                        'No reports found',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(
                                'Report ${report.reportNumber}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${report.createdAt.toLocal().toString().split(' ')[0]}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    'Status: ${report.reportStatus}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color:
                                          _getStatusColor(report.reportStatus),
                                    ),
                                  ),
                                  if (report.notes != null &&
                                      report.notes!.isNotEmpty)
                                    Text(
                                      'Notes: ${report.notes}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showReportDetails(report),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'under review':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Details',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Report Number', report.reportNumber),
              _buildDetailRow(
                  'Date & Time', report.createdAt.toLocal().toString()),
              _buildDetailRow('Status', report.reportStatus),
              _buildDetailRow('Your Car Plate', report.myPlateNumber),
              _buildDetailRow('Other Car Plate', report.otherPlateNumber),
              _buildDetailRow('Fault',
                  report.isFaulty ? 'Your fault' : 'Other driver\'s fault'),
              _buildDetailRow(
                  'Insurance', report.insuranceCovered ? 'Yes' : 'No'),
              _buildDetailRow('Injuries', report.injuries ? 'Yes' : 'No'),
              _buildDetailRow('Description', report.description),
              _buildDetailRow('Location', report.location ?? 'N/A'),
              if (report.notes != null && report.notes!.isNotEmpty)
                _buildDetailRow('Notes', report.notes!),
              if (report.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Photos',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: report.photoUrls
                      .map((url) => Image.network(url, width: 100, height: 100))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
