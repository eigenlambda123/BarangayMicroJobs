import 'package:flutter/material.dart';

import 'app/barangay_microjobs_app.dart';
import 'services/offline_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineSyncService.instance.initialize();
  runApp(const BarangayMicrojobsApp());
}
