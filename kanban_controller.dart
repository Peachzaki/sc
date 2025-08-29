import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kanban_model.dart';
import '../services/api_service.dart';

class KanbanController extends ChangeNotifier {
  static const platform = MethodChannel('com.example.ekanban/scanner');
  final ApiService _apiService = ApiService();

  // State variables
  String _scanResult = '';
  bool _isLoading = false;
  bool _isScannerReady = false;
  KanbanModel? _kanbanData;
  int _currentPage = 0;
  String? _errorMessage;
  bool _isProcessing = false;
  final bool _isDebugMode = true;

  // Getters
  String get scanResult => _scanResult;
  bool get isLoading => _isLoading;
  bool get isScannerReady => _isScannerReady;
  KanbanModel? get kanbanData => _kanbanData;
  int get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;

  // Initialize scanner on controller creation
  KanbanController() {
    _debugLog('KanbanController: Initializing...');
    initializeScanner();
  }

  void _debugLog(String message) {
    if (_isDebugMode) {
      print('[DEBUG] $message');
    }
  }

  // Setup Zebra Scanner listener
  void initializeScanner() {
    _debugLog('Setting up method call handler...');
    platform.setMethodCallHandler(_handleMethodCall);
    _checkScannerStatus();
  }

  // Check if scanner is available
  Future<void> _checkScannerStatus() async {
    try {
      _debugLog('Checking scanner status...');
      final bool isAvailable = await platform.invokeMethod('checkScanner');
      _isScannerReady = isAvailable;
      _debugLog('Scanner status: ${isAvailable ? "Ready" : "Not Ready"}');
      notifyListeners();
    } catch (e) {
      _debugLog('Scanner check failed: $e');
      _isScannerReady = false;

      // For testing purposes, set scanner as ready if it's debug mode
      if (_isDebugMode) {
        _debugLog('Debug mode: Setting scanner as ready for testing');
        _isScannerReady = true;
      }

      notifyListeners();
    }
  }

  // Handle all method calls from native side
  Future<void> _handleMethodCall(MethodCall call) async {
    _debugLog('Received method call: ${call.method} with args: ${call.arguments}');

    switch (call.method) {
      case 'barcodeScan':
        await _handleBarcodeScan(call.arguments);
        break;
      case 'scannerStatus':
        _handleScannerStatus(call.arguments);
        break;
      case 'scanError':
        _handleScanError(call.arguments);
        break;
      default:
        _debugLog('Unknown method: ${call.method}');
    }
  }

  // Process barcode data from Zebra scanner
  Future<void> _handleBarcodeScan(String barcode) async {
    _debugLog('Processing barcode: $barcode');

    // Prevent processing if already processing
    if (_isProcessing) {
      _debugLog('Already processing, ignoring scan');
      return;
    }

    _isProcessing = true;
    _errorMessage = null;

    // Validate barcode
    if (barcode.isEmpty) {
      _errorMessage = 'Invalid barcode received';
      _isProcessing = false;
      _debugLog('Invalid barcode: empty string');
      notifyListeners();
      return;
    }

    try {
      _scanResult = barcode;
      _isLoading = true;
      notifyListeners();

      // Extract product code from barcode
      String productCode = _extractProductCode(barcode);
      _debugLog('Extracted product code: $productCode');

      // Fetch data from API
      await fetchKanbanData(productCode);
    } catch (e) {
      _errorMessage = 'Error processing barcode: $e';
      _debugLog('Scan processing error: $e');
    } finally {
      _isProcessing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle scanner status changes
  void _handleScannerStatus(bool isReady) {
    _debugLog('Scanner status changed: $isReady');
    _isScannerReady = isReady;
    if (!isReady) {
      _errorMessage = 'Scanner disconnected';
    } else {
      _errorMessage = null;
    }
    notifyListeners();
  }

  // Handle scan errors
  void _handleScanError(String error) {
    _debugLog('Scan error: $error');
    _errorMessage = 'Scan error: $error';
    _isLoading = false;
    _isProcessing = false;
    notifyListeners();
  }

  // Extract product code from barcode
  String _extractProductCode(String barcode) {
    _debugLog('Extracting product code from: $barcode');

    // Remove any whitespace
    barcode = barcode.trim();

    // Handle different barcode formats
    // Format 1: "42140-0KR51 AUS -2" -> extract "AUS"
    if (barcode.contains(' ')) {
      List<String> parts = barcode.split(' ');
      _debugLog('Barcode parts: $parts');

      if (parts.length >= 2) {
        // Return the second part if it's valid
        String code = parts[1].trim();
        if (code.isNotEmpty && !code.startsWith('-')) {
          _debugLog('Using part code: $code');
          return code;
        }
      }
    }

    // Format 2: Direct product code
    _debugLog('Using full barcode as product code: $barcode');
    return barcode;
  }

  // Fetch data from API
  Future<void> fetchKanbanData(String productCode) async {
    _debugLog('Fetching data for product code: $productCode');

    try {
      _debugLog('Fetching from API...');
      _kanbanData = await _apiService.fetchKanbanData(productCode);

      _currentPage = 0;
      _errorMessage = null;
      _debugLog('Data fetched successfully');
    } catch (e) {
      _debugLog('Failed to fetch data: $e');
      _errorMessage = 'Failed to fetch data: $e';

      // Try to get mock data as fallback
      try {
        _debugLog('Trying mock data as fallback...');
        _kanbanData = _apiService.getMockData(productCode);
        _errorMessage = 'Using offline data';
        _debugLog('Mock data loaded successfully');
      } catch (mockError) {
        _debugLog('Mock data failed: $mockError');
        _errorMessage = 'No data available for code: $productCode';
      }
    }
  }

  // Manual trigger scan (for soft trigger button)
  Future<void> triggerScan() async {
    _debugLog('Trigger scan requested');

    if (!_isScannerReady) {
      _debugLog('Scanner not ready, cannot trigger scan');
      _errorMessage = 'Scanner not ready';
      notifyListeners();
      return;
    }

    if (_isProcessing) {
      _debugLog('Already processing, ignoring trigger');
      return;
    }

    try {
      _errorMessage = null;
      notifyListeners();

      _debugLog('Invoking native startScan method...');
      await platform.invokeMethod('startScan');
      _debugLog('startScan method called successfully');
    } catch (e) {
      _debugLog('Failed to trigger scan: $e');
      _errorMessage = 'Failed to trigger scan: $e';
      notifyListeners();
    }
  }

  // Configure scanner settings
  Future<void> configureScannerSettings({
    bool? enableBeep,
    bool? enableVibrate,
    int? scanTimeout,
  }) async {
    try {
      Map<String, dynamic> settings = {};
      if (enableBeep != null) settings['enableBeep'] = enableBeep;
      if (enableVibrate != null) settings['enableVibrate'] = enableVibrate;
      if (scanTimeout != null) settings['scanTimeout'] = scanTimeout;

      _debugLog('Configuring scanner with settings: $settings');
      await platform.invokeMethod('configureScanner', settings);
      _debugLog('Scanner configured successfully');
    } catch (e) {
      _debugLog('Configure scanner error: $e');
    }
  }

  // Enable/Disable scanner
  Future<void> enableScanner(bool enable) async {
    try {
      _debugLog('${enable ? "Enabling" : "Disabling"} scanner...');
      await platform.invokeMethod('enableScanner', enable);
      _isScannerReady = enable;
      _debugLog('Scanner ${enable ? "enabled" : "disabled"} successfully');
      notifyListeners();
    } catch (e) {
      _debugLog('Enable scanner error: $e');
    }
  }

  // Change display page
  void changePage(int page) {
    _debugLog('Changing to page: $page');
    _currentPage = page;
    notifyListeners();
  }

  // Reset all data
  void resetData() {
    _debugLog('Resetting all data');
    _kanbanData = null;
    _scanResult = '';
    _currentPage = 0;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _debugLog('Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }

  // Re-process last scan
  void reprocessLastScan() {
    if (_scanResult.isNotEmpty) {
      _debugLog('Re-processing last scan: $_scanResult');
      _handleBarcodeScan(_scanResult);
    } else {
      _debugLog('No last scan to reprocess');
    }
  }

  @override
  void dispose() {
    _debugLog('KanbanController disposing...');
    super.dispose();
  }
}