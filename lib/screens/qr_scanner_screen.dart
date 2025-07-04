import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/responsive_helper.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? scannedCode;

  @override
  void reassemble() {
    super.reassemble();
    controller.stop();
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _buildDesktopFallback();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Escáner QR'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () async {
              await controller.toggleTorch();
            },
          ),
        ],
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopFallback() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escáner QR'),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(32),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 24),
                Text(
                  'Escáner QR no disponible',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'El escáner QR no está disponible en esta plataforma.\nPuede introducir el código manualmente en la pantalla anterior.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _buildQRView(),
        ),
        Expanded(
          flex: 1,
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveHelper.isLandscape(context)
        ? Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildQRView(),
              ),
              Expanded(
                flex: 1,
                child: _buildControls(),
              ),
            ],
          )
        : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildQRView(),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.all(32),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: _buildControls(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRView() {
    final cutOutSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 250.0,
      tablet: 300.0,
      desktop: 350.0,
    );

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onQRViewCreated,
        ),
        Center(
          child: Container(
            width: cutOutSize,
            height: cutOutSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: ResponsiveHelper.getResponsiveValue(
                  context,
                  mobile: 3.0,
                  tablet: 4.0,
                  desktop: 5.0,
                ),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final buttonPadding = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scannedCode != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Escaneado: $scannedCode',
                style: TextStyle(fontSize: fontSize),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Text(
              'Posiciona el código QR en el marco',
              style: TextStyle(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 24),
          SizedBox(
            width: ResponsiveHelper.isDesktop(context) ? 200 : double.infinity,
            child: ElevatedButton(
              onPressed: scannedCode != null
                  ? () => Navigator.pop(context, scannedCode)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(buttonPadding),
              ),
              child: Text(
                'Usar Código',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && scannedCode != barcode.rawValue) {
        setState(() {
          scannedCode = barcode.rawValue;
        });
        
        controller.stop();
        
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, scannedCode);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}