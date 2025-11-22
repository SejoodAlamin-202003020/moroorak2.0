import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investigator_auth_provider.dart';
import '../services/investigator_report_service.dart';
import '../models/report.dart';
import 'report_details_screen.dart';

class RejectedReportsScreen extends StatefulWidget {
  const RejectedReportsScreen({super.key});

  @override
  State<RejectedReportsScreen> createState() => _RejectedReportsScreenState();
}

class _RejectedReportsScreenState extends State<RejectedReportsScreen> {
  final InvestigatorReportService _reportService = InvestigatorReportService();
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRejectedReports();
  }

  Future<void> _loadRejectedReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getReportsByStatus('rejected');
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rejected reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Reports'),
        backgroundColor: const Color(0xFFEF5350),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(
                  child: Text('No rejected reports available'),
                )
              : RefreshIndicator(
                  onRefresh: _loadRejectedReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Report ${report.reportNumber}'),
                          subtitle: Text(
                            'Reporter: ${report.reporterName ?? 'Unknown'}\n'
                            'Date: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}\n'
                            'Location: ${report.location ?? 'Not specified'}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReportDetailsScreen(report: report),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
