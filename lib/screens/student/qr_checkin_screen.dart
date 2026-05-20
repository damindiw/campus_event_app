import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCheckInScreen extends StatelessWidget {
  final String eventId;
  final String userId;
  const QRCheckInScreen({super.key, required this.eventId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket"),
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminScannerScreen())))]
      ),
      body: Center(
        child: QrImageView(data: "$userId|$eventId", version: QrVersions.auto, size: 250.0),
      ),
    );
  }
}

class AdminScannerScreen extends StatelessWidget {
  final controller = MobileScannerController();
  AdminScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Attendance")),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) async {
          if (capture.barcodes.isNotEmpty) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null && code.contains('|')) {
              controller.stop();
              List<String> details = code.split('|');
              var reg = await FirebaseFirestore.instance.collection('Registrations')
                  .where('userId', isEqualTo: details[0])
                  .where('eventId', isEqualTo: details[1]).get();
              for (var doc in reg.docs) {
                await doc.reference.update({'attendanceStatus': 'present'});
              }
              if (context.mounted) Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}