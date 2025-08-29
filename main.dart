import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/kanban_controller.dart';
import 'views/scanner_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eKANBAN Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // ไปตรงหน้าสแกนเลย ไม่ต้อง login
      home: ChangeNotifierProvider(
        create: (_) => KanbanController(),
        child: const ScannerView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}