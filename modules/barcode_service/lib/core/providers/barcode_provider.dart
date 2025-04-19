import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../models/book_model.dart';
import '../services/barcode_services.dart';

enum BarcodeScanStatus { initializing, scanning, found, notFound, error }

class BarcodeProvider extends ChangeNotifier {
  final BarcodeServices _barcodeService;

  CameraController? _cameraController;
  BarcodeScanStatus _status = BarcodeScanStatus.initializing;
  String _scannedBarcode = '';
  Book? _bookDetails;
  String? _errorMessage;

  BarcodeProvider(this._barcodeService) {
    _initializeCamera();
  }

  BarcodeScanStatus get status => _status;
  CameraController? get cameraController => _cameraController;
  String get scannedBarcode => _scannedBarcode;
  Book? get bookDetails => _bookDetails;
  String? get errorMessage => _errorMessage;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await _barcodeService.getAvailableCameras();
      if (cameras.isEmpty) {
        _status = BarcodeScanStatus.error;
        _errorMessage = 'No cameras available';
        notifyListeners();
        return;
      }

      _cameraController = await _barcodeService.initializeCamera(cameras.first);
      _status = BarcodeScanStatus.scanning;
      notifyListeners();

      _startBarcodeScanning();
    } catch (e) {
      _status = BarcodeScanStatus.error;
      _errorMessage = 'Error initializing camera: ${e.toString()}';
      notifyListeners();
    }
  }

  void _startBarcodeScanning() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((image) async {
      final barcode = await _barcodeService.processImage(image);

      if (barcode != null && barcode != _scannedBarcode) {
        _scannedBarcode = barcode;
        _status = BarcodeScanStatus.scanning;
        notifyListeners();

        _fetchBookDetails(barcode);
      }
    });
  }

  Future<void> _fetchBookDetails(String barcode) async {
    try {
      final book = await _barcodeService.fetchBookDetails(barcode);

      if (book != null) {
        _bookDetails = book;
        _status = BarcodeScanStatus.found;
      } else {
        _status = BarcodeScanStatus.notFound;
      }

      notifyListeners();
    } catch (e) {
      _status = BarcodeScanStatus.error;
      _errorMessage = 'Error fetching book details: ${e.toString()}';
      notifyListeners();
    }
  }

  void reset() {
    _scannedBarcode = '';
    _bookDetails = null;
    _status = BarcodeScanStatus.scanning;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}