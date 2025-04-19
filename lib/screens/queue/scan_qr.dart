import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:queue_app/config/routes.dart';
import 'package:queue_app/config/theme.dart';
import 'package:queue_app/services/auth_service.dart';
import 'package:queue_app/services/qr_service.dart';
import 'package:queue_app/services/queue_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  final QrService _qrService = QrService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканування QR-коду'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                _buildQrOverlay(),
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
    );
  }

  Widget _buildQrOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppTheme.primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Наведіть камеру на QR-код',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.joinQueue);
                },
                icon: const Icon(Icons.text_fields),
                label: const Text('Ввести код вручну'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    _isProcessing = true;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final queueService = Provider.of<QueueService>(context, listen: false);
        final user = authService.userModel;

        if (user == null) {
          setState(() {
            _errorMessage = 'Для приєднання до черги необхідно авторизуватися';
          });
          _isProcessing = false;
          return;
        }

        setState(() {
          _isLoading = true;
        });

        // Декодуємо QR-код
        final qrData = await _qrService.decodeQrCode(barcode.rawValue!);

        // Отримуємо ID черги
        final queueId = qrData['id'];

        if (queueId == null) {
          setState(() {
            _errorMessage = 'Невірний QR-код';
            _isLoading = false;
          });
          _isProcessing = false;
          return;
        }

        // Перевіряємо тип QR-коду
        final qrType = qrData['type'];

        if (qrType == 'championship') {
          // Якщо це QR-код чемпіонату, переходимо на сторінку чемпіонату
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.championshipDetails,
              arguments: queueId,
            );
          }
          _isProcessing = false;
          return;
        } else if (qrType == 'team') {
          // Якщо це QR-код команди, переходимо на сторінку команди
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.teamManagement,
              arguments: queueId,
            );
          }
          _isProcessing = false;
          return;
        }

        // Приєднуємося до черги
        final result = await queueService.joinQueue(
          queueId: queueId,
          user: user,
        );

        if (result) {
          if (mounted) {
            // Переходимо на сторінку деталей черги
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.queueDetails,
              arguments: queueId,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Не вдалося приєднатися до черги';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Помилка: ${e.toString()}';
            _isLoading = false;
          });
        }
      } finally {
        _isProcessing = false;
      }
    }
  }
}

// Клас для створення рамки над QR-кодом
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color(0x80000000),
    this.borderRadius = 10.0,
    this.borderLength = 30.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final center = Offset(rect.width / 2, rect.height / 2);
    final size = Size(cutOutSize, cutOutSize);
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final center = Offset(rect.width / 2, rect.height / 2);
    final size = Size(cutOutSize, cutOutSize);
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    // Малюємо затемнений фон
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect)
        ..addRRect(borderRect),
      backgroundPaint,
    );

    // Малюємо кути
    final width = cutOutRect.width;
    final height = cutOutRect.height;
    final borderOffset = borderWidth / 2;

    // Верхній лівий кут
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top - borderOffset)
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset),
      borderPaint,
    );

    // Верхній правий кут
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right + borderOffset, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top - borderOffset)
        ..lineTo(
            cutOutRect.right - borderLength, cutOutRect.top - borderOffset),
      borderPaint,
    );

    // Нижній лівий кут
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left - borderOffset, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom + borderOffset)
        ..lineTo(
            cutOutRect.left + borderLength, cutOutRect.bottom + borderOffset),
      borderPaint,
    );

    // Нижній правий кут
    canvas.drawPath(
      Path()
        ..moveTo(
            cutOutRect.right + borderOffset, cutOutRect.bottom - borderLength)
        ..lineTo(
            cutOutRect.right + borderOffset, cutOutRect.bottom + borderOffset)
        ..lineTo(
            cutOutRect.right - borderLength, cutOutRect.bottom + borderOffset),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}