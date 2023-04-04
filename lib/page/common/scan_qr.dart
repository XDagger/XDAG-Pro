import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:xdag/widget/modal_frame.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalFrame(
        title: "",
        child: MobileScanner(
          fit: BoxFit.cover,
          controller: MobileScannerController(returnImage: true),
          onDetect: (barcodes) {},
        ));
  }
}
