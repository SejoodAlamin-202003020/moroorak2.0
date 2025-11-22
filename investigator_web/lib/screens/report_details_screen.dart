import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/investigator_report_service.dart';
import '../services/investigator_notification_service.dart';
import '../providers/investigator_auth_provider.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Report report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final InvestigatorReportService _reportService = InvestigatorReportService();
  final InvestigatorNotificationService _notificationService =
      InvestigatorNotificationService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateStatus(String status,
      {String? notes, bool autoUpdate = false}) async {
    setState(() => _isUpdating = true);
    try {
      final oldStatus = widget.report.reportStatus;
      await _reportService.updateReportStatus(widget.report.id, status,
          notes: notes);

      // Try to create notification, but don't fail if it doesn't work
      try {
        // Get investigator name
        final investigator =
            context.read<InvestigatorAuthProvider>().investigator;
        final investigatorName = investigator?.name ?? 'Unknown Investigator';

        // Create status update notification for mobile app user
        String title;
        String message;

        switch (status) {
          case 'under_review':
            title = 'Report Under Review';
            message =
                'Your report ${widget.report.reportNumber} is now under review.';
            break;
          case 'approved':
            title = 'Report Approved';
            message =
                'Your report ${widget.report.reportNumber} has been approved by investigator $investigatorName.';
            break;
          case 'rejected':
            title = 'Report Rejected';
            message =
                'Your report ${widget.report.reportNumber} has been rejected by investigator $investigatorName.';
            break;
          default:
            title = 'Report Status Updated';
            message =
                'Your report ${widget.report.reportNumber} status has been updated.';
        }

        await _notificationService.createStatusUpdateNotification(
          widget.report.id,
          oldStatus,
          status,
          title: title,
          message: message,
        );
      } catch (e) {
        // Silently ignore notification creation errors
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report status updated successfully')),
        );
        if (!autoUpdate) {
          // Navigate back to refresh the list
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating report: $e')),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _dispatchPatrol() async {
    final locationController = TextEditingController();

    final location = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispatch Patrol'),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Enter patrol dispatch location',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(locationController.text),
            child: const Text('Dispatch'),
          ),
        ],
      ),
    );

    if (location != null && location.isNotEmpty) {
      setState(() => _isUpdating = true);
      try {
        await _reportService.dispatchPatrol(widget.report.id, location);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patrol dispatched successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error dispatching patrol: $e')),
          );
        }
      } finally {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showStatusUpdateDialog() {
    final notesController = TextEditingController(text: widget.report.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Report Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: widget.report.reportStatus,
              decoration: const InputDecoration(
                labelText: 'New Status',
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                DropdownMenuItem(
                    value: 'under_review', child: Text('Under Review')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updateStatus(value, notes: notesController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isUpdating
                ? null
                : () {
                    _updateStatus(widget.report.reportStatus,
                        notes: notesController.text);
                    Navigator.of(context).pop();
                  },
            child: _isUpdating
                ? const CircularProgressIndicator()
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Number: ${widget.report.reportNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_police, color: Color(0xFF556B2F)),
            tooltip: 'Dispatch Patrol',
            onPressed: _dispatchPatrol,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF556B2F)),
            onPressed: _showStatusUpdateDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildSection('User Information', [
              _buildInfoRow('Name', 'Not Available'),
              _buildInfoRow('Phone Number', 'Not Available'),
              _buildInfoRow('Email', 'Not Available'),
            ]),
            const SizedBox(height: 16),
            _buildSection('First Vehicle Information', [
              _buildInfoRow('Plate Number', widget.report.myPlateNumber),
              _buildInfoRow('Vehicle Type',
                  widget.report.myVehicleType ?? 'Not Specified'),
              _buildInfoRow('Vehicle Model',
                  widget.report.myVehicleModel ?? 'Not Specified'),
              _buildInfoRow('Vehicle Color',
                  widget.report.myVehicleColor ?? 'Not Specified'),
              _buildInfoRow('License Number',
                  widget.report.myLicenseNumber ?? 'Not Specified'),
              _buildInfoRow('Search Certificate',
                  widget.report.mySearchCertificate ?? 'Not Specified'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Second Vehicle Information', [
              _buildInfoRow('Plate Number', widget.report.otherPlateNumber),
              _buildInfoRow('Vehicle Type',
                  widget.report.otherVehicleType ?? 'Not Specified'),
              _buildInfoRow('Vehicle Model',
                  widget.report.otherVehicleModel ?? 'Not Specified'),
              _buildInfoRow('Vehicle Color',
                  widget.report.otherVehicleColor ?? 'Not Specified'),
              _buildInfoRow('License Number',
                  widget.report.otherLicenseNumber ?? 'Not Specified'),
              _buildInfoRow('Search Certificate',
                  widget.report.otherSearchCertificate ?? 'Not Specified'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Accident Details', [
              _buildInfoRow('Description', widget.report.description),
              _buildInfoRow(
                  'Location', widget.report.location ?? 'Not Specified'),
              _buildInfoRow(
                  'Are there injuries?', widget.report.injuries ? 'Yes' : 'No'),
              _buildInfoRow(
                  'Fault Percentage', '${widget.report.faultPercentage ?? 0}%'),
              _buildInfoRow(
                  'Are you the owner?', widget.report.isOwner ? 'Yes' : 'No'),
              if (!widget.report.isOwner)
                _buildInfoRow('Relation to Owner',
                    widget.report.relationToOwner ?? 'Not Specified'),
              _buildInfoRow(
                  'Are you at fault?', widget.report.isFaulty ? 'Yes' : 'No'),
              _buildInfoRow('Insurance Covered?',
                  widget.report.insuranceCovered ? 'Yes' : 'No'),
              if (widget.report.insuranceCovered)
                _buildInfoRow('Insurance Type',
                    widget.report.insuranceType ?? 'Not Specified'),
              if (widget.report.insuranceCovered)
                _buildInfoRow('Insurance Number',
                    widget.report.insuranceNumber ?? 'Not Specified'),
            ]),
            const SizedBox(height: 16),
            if (widget.report.photoUrls.isNotEmpty) _buildPhotosSection(),
            const SizedBox(height: 16),
            if (widget.report.notes != null && widget.report.notes!.isNotEmpty)
              _buildSection('Investigator Notes', [
                Text(widget.report.notes!),
              ]),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;

    switch (widget.report.reportStatus) {
      case 'pending':
        statusColor = const Color(0xFFFFA726);
        statusText = 'New';
        break;
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF5350);
        statusText = 'Rejected';
        break;
      case 'under_review':
        statusColor = const Color(0xFF42A5F5);
        statusText = 'Under Review';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Not Specified';
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info, color: statusColor),
            const SizedBox(width: 8),
            Text(
              'Status: $statusText',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _buildSection('Photos', [
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.report.photoUrls.length,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: const EdgeInsets.only(right: 8),
              child: Image.network(
                widget.report.photoUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildActionButtons() {
    final isUnderReview = widget.report.reportStatus == 'under_review';
    final isApproved = widget.report.reportStatus == 'approved';

    // If report is approved, show no action buttons
    if (isApproved) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investigator Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            const SizedBox(height: 16),
            if (!isUnderReview)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('under_review'),
                      icon: const Icon(Icons.hourglass_top),
                      label: const Text('Under Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('approved'),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            if (!isUnderReview) const SizedBox(height: 8),
            if (isUnderReview)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('approved'),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('rejected'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('rejected'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _dispatchPatrol,
                      icon: const Icon(Icons.local_police),
                      label: const Text('Dispatch Patrol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
