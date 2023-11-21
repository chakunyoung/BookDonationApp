import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class GetIsbn extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      // print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'ISBN을 조회할 수 없습니다';
    }
    state = barcodeScanRes;
    // state = '테스트임';
  }
}

final getIsbnProvider = NotifierProvider<GetIsbn, String>(GetIsbn.new);
