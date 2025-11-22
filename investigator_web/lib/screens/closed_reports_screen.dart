import 'package:flutter/material.dart';
import '../services/investigator_report_service.dart';
import '../models/report.dart';
import 'report_details_screen.dart';

class ClosedReportsScreen extends StatefulWidget {
  const ClosedReportsScreen({super.key});

  @override
  State<ClosedReportsScreen> createState() => _ClosedReportsScreenState();
}

class _ClosedReportsScreenState extends State<ClosedReportsScreen> {
  final InvestigatorReportService _reportService = InvestigatorReportService();
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClosedReports();
  }

  Future<void> _loadClosedReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getReportsByStatus('closed');
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading closed reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closed Reports'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(
                  child: Text('No closed reports available'),
                )
              : RefreshIndicator(
                  onRefresh: _loadClosedReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          title: Text('Report #${report.reportNumber}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Reporter: ${report.reporterName ?? 'Unknown'}'),
                              Text(
                                  'Location: ${report.location ?? 'Not specified'}'),
                              Text(
                                  'Date: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportDetailsScreen(report: report),
                                ),
                              );
                            },
                            child: const Text('View Details'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
