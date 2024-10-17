import 'package:get/get.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class PrinterController extends GetxService {
  var connected = false.obs;
  Future<bool> connectToPrinter() async {
    try {
      connected.value = await SunmiPrinter.bindingPrinter() ?? false;
      return connected.value;
    } catch (e) {
      print(e);
      connected.value = false;
      return false;
    }
    // Retrieve the list of bonded (paired) devices
  }

  // void disconnectFromPrinter() {
  //   if (connected.value) {
  //     bluetooth.disconnect();
  //     connected.value = false;
  //   }
  // }

  // Add a function for printing if needed
  // void printReceipt() {
  //   // Your printing logic here
  // }
}

// void main() async {
//   final printerController = PrinterController();
//   await printerController.connectToPrinter();

//   if (printerController.connected.value) {
//     // Use the printer for printing
//     printerController.printReceipt();
//   }

//   // Don't forget to disconnect when done
//   printerController.disconnectFromPrinter();
// }
