import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/kanban_controller.dart';
import '../utils/constants.dart';
import 'widgets/waiting_scan_widget.dart';
import 'widgets/kanban_display_widget.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  KanbanController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = Provider.of<KanbanController>(context, listen: false);
      _controller?.configureScannerSettings(
        enableBeep: true,
        enableVibrate: true,
        scanTimeout: 5000,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.resumed) {
      _controller!.enableScanner(true);
    } else if (state == AppLifecycleState.paused) {
      _controller!.enableScanner(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KanbanController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Constants.primaryColor,
          appBar: _buildAppBar(controller),
          body: _buildBody(controller),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(KanbanController controller) {
    return AppBar(
      title: const Row(
        children: [
          Icon(Icons.qr_code_2, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Text('eKANBAN Scanner', style: TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Constants.primaryDarkColor,
      elevation: 0,
      actions: [
        // Clear/Reset button - แสดงเฉพาะเมื่อมีข้อมูล
        if (controller.kanbanData != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _showResetConfirmation(context, controller);
            },
            tooltip: 'Clear data',
          ),
      ],
    );
  }

  Widget _buildBody(KanbanController controller) {
    // Show loading indicator
    if (controller.isLoading) {
      return _buildLoadingScreen(controller);
    }

    // Show error if exists and no data
    if (controller.errorMessage != null && controller.kanbanData == null) {
      return _buildErrorScreen(controller);
    }

    // Show waiting screen with scan button
    if (controller.kanbanData == null) {
      return WaitingScanWidget(
        onScanPressed: controller.isScannerReady
            ? () => controller.triggerScan()
            : null,
        onTestPressed: () => _testScannerWithMockData(controller),
        showTestButton: !controller.isScannerReady,
      );
    }

    // Show kanban data - ลบ Stack และ FloatingActionButton ออก
    return Column(
      children: [
        // Show error as banner if data exists
        if (controller.errorMessage != null)
          _buildErrorBanner(controller),

        // Kanban display
        Expanded(
          child: KanbanDisplayWidget(
            kanbanData: controller.kanbanData!,
            currentPage: controller.currentPage,
            onPageChanged: controller.changePage,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(KanbanController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern loading animation
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Processing barcode...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          if (controller.scanResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.scanResult,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(KanbanController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.orangeAccent,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                controller.errorMessage ?? 'Unknown error occurred',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.clearError();
                    controller.resetData();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Constants.primaryDarkColor,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                if (controller.scanResult.isNotEmpty) ...[
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.reprocessLastScan();
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(KanbanController controller) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              controller.errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            onPressed: controller.clearError,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, KanbanController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.refresh_rounded, color: Constants.primaryDarkColor),
              SizedBox(width: 10),
              Text('Clear Data?'),
            ],
          ),
          content: const Text('This will clear the current scan data and return to the main screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.resetData();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryDarkColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _testScannerWithMockData(KanbanController controller) {
    String testBarcode = "42140-0KR51 AUS -2";
    print('[TEST MODE] Testing with mock barcode: $testBarcode');
    controller.fetchKanbanData("AUS");
  }
}