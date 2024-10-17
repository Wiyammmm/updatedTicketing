// ignore_for_file: unused_import

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/connectToPrinter.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

///Test printing
class TestPrinttt extends GetxService {
  fetchServices fetchservice = fetchServices();
  HiveService hiveService = HiveService();
  int fontSize = 23;
  PrinterController printerController = Get.put(PrinterController());

  Future<void> printHeader() async {
    final coopData = fetchservice.fetchCoopData();
    await printText("${coopData['cooperativeName']}", 1);

    if (coopData['telephoneNumber'] != null) {
      await printText("Contact Us: ${coopData['telephoneNumber']}", 1);
    }
    await printText("POWERED BY: FILIPAY", 1);
  }

  Future<void> printLeftRight(String label, String value,
      [int maxright = 22]) async {
    int excessLabelLength = 0;
    int labelLength = 0;
    if (label.length > 9) {
      excessLabelLength = label.length - 9;
    }
    // if (label.length < 9) {
    //   labelLength = 9 - label.length;
    //   print('labelLength: $labelLength, label: $label');
    //   // label = label.padRight(labelLength);
    // }
    await SunmiPrinter.bold();
    await SunmiPrinter.setCustomFontSize(fontSize);
    await SunmiPrinter.printText(
        '${label.padRight(9)}${newText(value, maxright - excessLabelLength)}');
  }

  Future<void> printText(String label, int align, [int size = 23]) async {
    // align
    // 0 = left
    // 1 = center
    // 2 = right
    await SunmiPrinter.bold();
    await SunmiPrinter.setCustomFontSize(size);
    switch (align) {
      case 0:
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
        break;
      case 1:
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        break;
      case 2:
        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        break;
      default:
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    }
    await SunmiPrinter.printText(label);
  }

  String newText(String text, [int maxright = 22]) {
    if (text.length > maxright) {
      // Trim the text to 20 characters and add '..'
      return text.substring(0, maxright - 2) + '..';
    } else if (text.length < maxright) {
      // Add spaces at the start to make the text length 22
      return text.padLeft(maxright);
    }
    return text;
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample() async {
    await SunmiPrinter.startTransactionPrint(true);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT); // Right align
    await SunmiPrinter.printText('Align right');

    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT); // Left align
    await SunmiPrinter.printText('Align left');

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER); // Center align
    await SunmiPrinter.printText('Align center');

    await SunmiPrinter.lineWrap(2); // Jump 2 lines

    await SunmiPrinter.setFontSize(SunmiFontSize.XL); // Set font to very large
    await SunmiPrinter.printText('Very Large font!');
    await SunmiPrinter.resetFontSize(); // Reset font to medium size

    await SunmiPrinter.setCustomFontSize(fontSize); // SET CUSTOM FONT 12
    await SunmiPrinter.bold();
    await SunmiPrinter.printText('Custom font size!!!');
    await SunmiPrinter.resetFontSize(); // Reset font to medium size

    await SunmiPrinter.lineWrap(4);
    await SunmiPrinter.submitTransactionPrint(); // SUBMIT and cut paper
    await SunmiPrinter.exitTransactionPrint(true); // Close the transaction
  }

  printDispatch(
      String torNo,
      String driverName,
      String conductorName,
      String dispatcherName,
      String trip,
      int tripNo,
      String vehicleNo,
      String route,
      String bound) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    final formattedDate = formatDateNow();
    if (printerController.connected.value) {
      if (driverName.length > 14) {
        driverName = driverName.substring(0, 14) + "..";
      }
      if (conductorName.length > 14) {
        conductorName = conductorName.substring(0, 14) + "..";
      }
      if (dispatcherName.length > 14) {
        dispatcherName = dispatcherName.substring(0, 14) + "..";
      }
      await printText("${coopData['cooperativeName']}", 1);

      if (coopData['telephoneNumber'] != null) {
        printText("Contact Us: ${coopData['telephoneNumber']}", 1);
      }
      await printText("POWERED BY: FILIPAY", 1);
      await printText("DISPATCH REPORT", 1);
      await printText("TOR#: $torNo", 1);
      await printText("DATE: $formattedDate", 1);

      await printLeftRight("TRIP NO.:", "$tripNo");
      await printLeftRight(
          "${coopData['coopType'].toString().toUpperCase()} NO.:",
          "$vehicleNo");

      await printText("---ROUTE NAME--", 1);
      await printText("$route", 1);

      await printLeftRight("PASS. COUNT.:", "$driverName");

      await printLeftRight("PASS. COUNT.:", "$driverName");
      await printLeftRight("COND. NAME.:", "$conductorName");
      await printLeftRight("DISP. NAME.:", "$dispatcherName");
      await printLeftRight("TYPE:    ", "${trip.toUpperCase()} TRIP");

      await printText("- - - - - - - - - - - - - - - -", 1);
      await printText("NOT AN OFFICIAL RECEIPT", 1);
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.cut();
    }
  }

  String breakString(String input, int maxLength) {
    List<String> words = input.split(' ');

    String firstLine = '';
    String secondLine = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if ((firstLine.length + 1 + word.length) <= maxLength) {
        // Add the word to the first line
        firstLine += (firstLine == "" ? '' : ' ') + word;
      } else if (secondLine == "") {
        // If the second line is empty, add the word to it
        secondLine += word;
      } else {
        // Truncate the word if it exceeds the maxLength
        int remainingSpace = maxLength - secondLine.length - 1;
        secondLine += ' ' +
            (word.length > remainingSpace
                ? word.substring(0, remainingSpace) + '..'
                : word);
        break;
      }
    }
    // Return the concatenated lines
    if (secondLine.trim() == "") {
      return "$firstLine";
    } else {
      return '$firstLine\n$secondLine';
    }
  }

  printTicket(
      String ticketNo,
      String cardType,
      double amount,
      double subtotal,
      double kmrun,
      String origin,
      String destination,
      String passengerType,
      bool isDiscounted,
      String vehicleNo,
      String from,
      String to,
      String route,
      double discountPercent,
      int pax,
      double newBalance,
      String sNo,
      String idNo,
      String mop) async {
    bool isDltb = false;
    bool isJeepney = false;
    final coopData = fetchservice.fetchCoopData();
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }

    if (coopData['coopType'] != "Bus") {
      isJeepney = true;
    }

    double discount = 0.0;
    if (cardType == 'mastercard' || cardType == 'cash') {
      cardType = 'CASH';
    } else {
      cardType = 'FILIPAY CARD';
    }
    if (isDiscounted) {
      discount = amount * discountPercent;
      // subtotal = subtotal - discount;
    }

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    // try {
    final formattedDate = formatDateNow();
    // if (route.length <= 16) {
    //   // route = route.substring(0, 12) + "..";
    //   isrouteLong = true;
    // } else if (route.length > 25) {
    //   isrouteLong = true;
    //   route = route.substring(0, 23) + "..";
    // }
    if (origin.length > 16) {
      origin = origin.substring(0, 13) + "..";
    }
    if (destination.length > 16) {
      destination = destination.substring(0, 13) + "..";
    }

    if (printerController.connected.value) {
      await printHeader();
      await printText('PASSENGER RECEIPT', 1);
      await printLeftRight('Ticket#: ', '$ticketNo');

      await printLeftRight("MOP:", mop);
      await printLeftRight("PASS TYPE:", "${passengerType.toUpperCase()}");

      if (passengerType != "regular" && passengerType != "baggage") {
        await printLeftRight("ID NO:   ", idNo);
      }
      await printLeftRight(
          "${coopData['coopType'].toString().toUpperCase()} NO:  ",
          "$vehicleNo");

      await printLeftRight("Discount:",
          "${coopData['coopType'] == "Bus" ? discount.round() : discount.toStringAsFixed(2)}");
      await printLeftRight(
        "Amount:  ",
        "${coopData['coopType'] == "Bus" ? amount.round() : amount.toStringAsFixed(2)}",
      );
      if (isJeepney) {
        await printLeftRight("Pax:     ", "$pax");
      }
      if (cardType == 'FILIPAY CARD') {
        await printLeftRight("SN:      ", "$sNo");
        await printLeftRight("REM BAL: ", "${newBalance.toStringAsFixed(2)}");
      }
      await printText('TOTAL AMOUNT', 1, 28);
      await printText(
          '${coopData['coopType'] == "Bus" ? subtotal.round() : subtotal.toStringAsFixed(2)}',
          1,
          28);
      await printText('- - - - - - - - - - - - - - -', 1);

      if (!fetchservice.getIsNumeric()) {
        await printLeftRight("ORIGIN:  ", "$origin");
        await printLeftRight("DESTINATION:", "$destination");

        await printLeftRight("KM Run:  ", "${kmrun.toInt()}");
      }

      await printLeftRight("DATE:    ", "$formattedDate");
      await printText("PASSENGER'S COPY", 1);
      await printText("- - - - - - - - - - - - - - -", 1);
      await printText("NOT AN OFFICIAL RECEIPT", 1);
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.cut();
    }

    // } catch (e) {
    //   print(e);
    // }
  }

  Future<bool> printListticket(List<Map<String, dynamic>> tickets) async {
    try {
      bool isDltb = false;
      final coopData = fetchservice.fetchCoopData();
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      for (int i = 0; i < tickets.length; i++) {
        print('ticket-$i: ${tickets[i]}');
        String origin = tickets[i]['from_place'];
        String destination = tickets[i]['to_place'];
        String ticketNo = tickets[i]['ticket_no'];
        String cardType = tickets[i]['cardType'];
        String passengerType = tickets[i]['passengerType'];
        String kmrun = tickets[i]['km_run'].toString();
        String dateString = tickets[i]['created_on'].toString();
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDate = DateFormat('MMM dd, yyyy EEE').format(dateTime);
        double discount = double.parse(tickets[i]['discount'].toString());

        double amount = double.parse(tickets[i]['fare'].toString()) +
            double.parse(tickets[i]['discount'].toString()) -
            double.parse(tickets[i]['baggage'].toString());
        double subtotal = double.parse(tickets[i]['fare'].toString()) -
            double.parse(tickets[i]['baggage'].toString());

        double baggageAmount = double.parse(tickets[i]['baggage'].toString());

        if (origin.length > 16) {
          origin = origin.substring(0, 13) + "..";
        }
        if (destination.length > 16) {
          destination = destination.substring(0, 13) + "..";
        }

        if (printerController.connected.value) {
          await printHeader();
          await printText("RECEIPT", 1);
          await printLeftRight("Ticket#:", "$ticketNo");

          await printLeftRight("MOP:", "$cardType");
          await printLeftRight("PASS TYPE:", "${passengerType.toUpperCase()}");

          await printLeftRight("ORIGIN:", "$origin");
          await printLeftRight("DESTINATION:", "$destination");
          await printLeftRight("KM Run:", "$kmrun");

          await printLeftRight("DATE:", "$formattedDate");

          await printText("- - - - - - - - - - - - - - -", 1);

          await printLeftRight("Discount:",
              "${coopData['coopType'] == "Bus" ? discount.round() : discount}");
          await printLeftRight("Amount:",
              "${coopData['coopType'] == "Bus" ? amount.round() : amount}");
          await printText("TOTAL AMOUNT", 1, 28);
          await printText("${subtotal.toStringAsFixed(2)}", 1, 28);

          await printText("- - - - - - - - - - - - - - -", 1);

          if (baggageAmount > 0) {
            await printHeader();
            await printText("BAGGAGE RECEIPT", 1);
            await printLeftRight("Ticket#:", "$ticketNo");

            await printLeftRight("ORIGIN:", "$origin");
            await printLeftRight("DESTINATION:", "$destination");
            await printLeftRight("KM Run:", "$kmrun");

            await printLeftRight("DATE:", "$formattedDate");

            await printText("- - - - - - - - - - - - - - -", 1);
            await printLeftRight("Baggage:",
                "${coopData['coopType'] == "Bus" ? baggageAmount.round() : baggageAmount}");

            await printText("- - - - - - - - - - - - - - -", 1);
            await printText("NOT AN OFFICIAL RECEIPT", 1);
            await SunmiPrinter.lineWrap(3);
            await SunmiPrinter.cut();
          }
        }
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  printBaggage(
      String ticketNo,
      String cardType,
      double baggageAmount,
      double kmrun,
      String origin,
      String destination,
      String vehicleNo,
      String from,
      String to,
      String route) async {
    bool isDltb = false;
    final coopData = fetchservice.fetchCoopData();
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
    if (cardType == 'mastercard' || cardType == 'cash') {
      cardType = 'CASH';
    } else {
      cardType = 'FILIPAY CARD';
    }
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }
      if (origin.length > 16) {
        origin = origin.substring(0, 13) + "..";
      }
      if (destination.length > 16) {
        destination = destination.substring(0, 13) + "..";
      }

      if (printerController.connected.value) {
        await printHeader();

        await printText('BAGGAGE RECEIPT', 1);
        await printLeftRight("TICKET#: ", "$ticketNo");
        await printLeftRight("MOP:", "$cardType");

        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo");

        if (!fetchservice.getIsNumeric()) {
          await printLeftRight("ORIGIN:", "$origin");
          await printLeftRight("DESTINATION:", "$destination");
        }

        await printLeftRight("KM Run:", "$kmrun");

        await printLeftRight("DATE:", "$formattedDate");
        // printText("- - - - - - - - - - - - - - -", 1);
        await printLeftRight(
          "Baggage:",
          "${coopData['coopType'] == "Bus" ? baggageAmount.round() : baggageAmount}",
        );

        await printText("PASSENGER'S COPY", 1);

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);

        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }
    } catch (e) {
      print(e);
    }
  }

  printExpenses(
      List<Map<String, dynamic>> expensesList, String vehicleNo) async {
    final coopData = fetchservice.fetchCoopData();
    bool isDltb = false;
    if (coopData['_id'] == "655321a339c1307c069616e9") {
      isDltb = true;
    }
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("EXPENSES", 1);

        await printLeftRight("DATE:", "$formattedDate");
        if (vehicleNo != "") {
          await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo",
          );
        }

        List<Map<String, dynamic>> othersExpenses = [];
        await printText("- - - - - - - - - - - - - - -", 1);
        await printLeftRight("PARTICULAR:", "AMOUNT");
        double totalExpenses = 0;
        for (var expense in expensesList) {
          totalExpenses += expense['amount'];
          String expenseDescription = expense['particular'];
          double expenseAmount = double.parse(expense['amount'].toString());
          // await printLeftRight(
          //     "PARTICULAR:", "${expenseDescription.toUpperCase()}", 1);
          if (expense['particular'] == "SERVICES" ||
              expense['particular'] == "CALLER'S FEE" ||
              expense['particular'] == "EMPLOYEE BENEFITS" ||
              expense['particular'] == "MATERIALS" ||
              expense['particular'] == "REPRESENTATION" ||
              expense['particular'] == "REPAIR") {
            othersExpenses.add(expense);
          } else {
            await printLeftRight(
              "$expenseDescription",
              "${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
            );
          }
        }

        if (othersExpenses.isNotEmpty) {
          await printLeftRight("OTHERS", "");
          for (var expense in othersExpenses) {
            String expenseDescription = expense['particular'];
            if (expenseDescription == "EMPLOYEE BENEFITS") {
              expenseDescription = "EMP BENEFITS";
            }
            double expenseAmount = double.parse(expense['amount'].toString());

            await printLeftRight(
              " ${expenseDescription}",
              "${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
            );
          }
        }
        await printLeftRight(
            "TOTAL EXPENSES", "${totalExpenses.toStringAsFixed(2)}");
        await printText("- - - - - - - - - - - - - - -", 1);

        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> printArrival(
      String opening,
      String closing,
      int totalPassenger,
      int totalBaggage,
      double totalPassengerAmount,
      double totalBaggageAmount,
      int tripNo,
      String vehicleNo,
      String conductorName,
      String driverName,
      String dispatcherName,
      String route,
      String torNo,
      String tripType,
      double totalExpenses) async {
    final _myBox = Hive.box('myBox');
    // final SESSION = _myBox.get('SESSION');
    final coopData = fetchservice.fetchCoopData();
    final session = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    final torTicket = _myBox.get('torTicket');
    String control_no = "";
    try {
      control_no = torTrip[session['currentTripIndex'] - 1]['control_no'];
    } catch (e) {
      control_no = torTrip[session['currentTripIndex']]['control_no'];
    }
    double getTotalTopUpperTrip() {
      double total = 0;
      final topUpList = _myBox.get('topUpList');

      if (topUpList.isNotEmpty) {
        for (var element in topUpList) {
          if (element['response']['control_no'].toString() == "$control_no") {
            total += double.parse((element['response']['mastercard']
                        ['previousBalance'] -
                    element['response']['mastercard']['newBalance'])
                .toString());
          }
        }
      }
      return total;
    }

    // int baggageWithPassengerCount = fetchservice.baggageWithPassengerCount();
    int baggageWithPassengerCount() {
      final torTicket = _myBox.get('torTicket');
      final session = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] > 0))
          .length;
      return totalBaggageCount;
    }

    int baggageOnlyCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['baggage'] is num && item['baggage'] > 0) &&
              item['control_no'] == control_no &&
              (item['fare'] is num && item['fare'] == 0))
          .length;
      return totalBaggageCount;
    }

    double totalTripBaggageOnly() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] == 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    double totalTripBaggagewithPassenger() {
      final fareList = _myBox.get('torTicket');

      // String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              // fare['cardType'] == cardTypeToFilter &&
              fare['baggage'] > 0 &&
              fare['fare'] > 0)
          .map<num>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    int cardSalesCount() {
      final torTicket = _myBox.get('torTicket');

      int totalBaggageCount = torTicket
          .where((item) =>
              (item['cardType'] != 'mastercard' &&
                  item['cardType'] != 'cash') &&
              item['control_no'] == control_no)
          .length;
      return totalBaggageCount;
    }

    double totalBaggageperTrip() {
      final torTicket = _myBox.get('torTicket');

      double sumOfBaggage = torTicket
          .where((fare) => fare['control_no'] == control_no)
          .map<double>((fare) => (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, baggage) => prev + baggage);

      return sumOfBaggage;
    }

    double totalPrepaidPassengerRevenueperTrip() {
      double total = 0;

      final prePaidList = _myBox.get('prepaidTicket');
      for (var element in prePaidList) {
        if (element['control_no'] == control_no) {
          total += element['totalAmount'];
        }
      }

      return total;
    }

    double totalPrepaidBaggageRevenueperTrip() {
      double total = 0;

      final prePaidList = _myBox.get('prepaidBaggage');
      for (var element in prePaidList) {
        if (element['control_no'] == control_no) {
          total += element['totalAmount'];
        }
      }

      return total;
    }

    double totalTripCardSales() {
      final fareList = _myBox.get('torTicket');

      // String controlNumberToFilter = fetchservice.getCurrentControlNumber();

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] != "mastercard" && fare['cardType'] != "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] != "mastercard" &&
                  fare['additionalFareCardType'] != "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount;
    }

    double totalTripCashReceived() {
      final fareList = _myBox.get('torTicket');

      String cardTypeToFilter = 'mastercard';

      double totalAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['cardType'] == cardTypeToFilter ||
                  fare['cardType'] == "cash"))
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      double totaladdFareAmount = fareList
          .where((fare) =>
              fare['control_no'] == control_no &&
              (fare['additionalFareCardType'] == cardTypeToFilter ||
                  fare['additionalFareCardType'] == "cash"))
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);
      return totalAmount + totaladdFareAmount + getTotalTopUpperTrip();
    }

    double totalTripGrandTotal() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) =>
              ((fare['fare'] as num).toDouble() * fare['pax']) +
              (fare['baggage'] as num).toDouble() +
              (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount +
          getTotalTopUpperTrip() +
          totalPrepaidPassengerRevenueperTrip() +
          totalPrepaidBaggageRevenueperTrip() -
          totalExpenses;
    }

    double totalAddFare() {
      final fareList = _myBox.get('torTicket');

      double totalAmount = fareList
          .where((fare) => fare['control_no'] == control_no)
          .map<num>((fare) => (fare['additionalFare'] as num).toDouble())
          .fold(0.0, (prev, amount) => prev + amount);

      return totalAmount;
    }

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd,yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (conductorName.length > 16) {
      conductorName = conductorName.substring(0, 13) + "..";
    }
    if (driverName.length > 16) {
      driverName = driverName.substring(0, 13) + "..";
    }
    if (dispatcherName.length > 16) {
      dispatcherName = dispatcherName.substring(0, 13) + "..";
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (printerController.connected.value) {
        await printHeader();
        await printText("ARRIVAL", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printLeftRight("TOR#:", "$torNo");
        await printLeftRight("TRIP TYPE:", "${tripType.toUpperCase()}");
        if (tripType == "special") {
          await printText("- - - - - - - - - - - - - - -", 1);
          await printLeftRight("PASSENGER COUNT:", "$totalPassenger");
          await printLeftRight("PASS REVENUE:", "$totalPassengerAmount");
          await printLeftRight("TRIP NO:", "$tripNo");
          await printLeftRight(
              "${coopData['coopType'].toString().toUpperCase()} NO:",
              "$vehicleNo");
          await printLeftRight("CONDUCTOR:", "$conductorName");
          await printLeftRight("DRIVER:", "$driverName");
          await printLeftRight("DISPATCHER:", "$dispatcherName");
          await printLeftRight("ROUTE:", "$route");
          await printLeftRight("SN:", "${session['serialNumber']}");
          await printText("- - - - - - - - - - - - - - -", 1);
          await printText("NOT AN OFFICIAL RECEIPT", 1);

          await SunmiPrinter.lineWrap(3);
          await SunmiPrinter.cut();
          return true;
        }
        await printLeftRight("OPENING:", "$opening");
        await printLeftRight("CLOSING:", "$closing");

        await printLeftRight("TOTAL PASS:", "$totalPassenger");

        await printLeftRight("TOTAL BAGGAGE:", "${totalBaggage}");

        await printLeftRight("CS ISSUED:", "${cardSalesCount()}");

        await printLeftRight("BAGGAGE AMOUNT:", "${totalBaggageperTrip()}");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight(
              "PREPAID PASS:", "${totalPrepaidPassengerRevenueperTrip()}");
        }
        await printLeftRight("TOTAL FARE:",
            "${fetchservice.totalTripFare().toStringAsFixed(2)}");

        await printLeftRight(
            "ADD FARE:", "${totalAddFare().toStringAsFixed(2)}");
        await printLeftRight(
            "CASH RECEIVED:", "${totalTripCashReceived().toStringAsFixed(2)}");
        await printLeftRight("CARD SALES:", "${totalTripCardSales()}");

        await printLeftRight(
            "TOTAL EXPENSES:", "${totalExpenses.toStringAsFixed(2)}");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight(
              "TOPUP TOTAL:", "${getTotalTopUpperTrip().toStringAsFixed(2)}");
        }
        await printLeftRight(
            "GRAND TOTAL:", "${totalTripGrandTotal().toStringAsFixed(2)}");

        await printText("- - - - - - - - - - - - - - -", 1);
        await printLeftRight("TRIP NO:", "$tripNo");
        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo");
        await printLeftRight("CONDUCTOR:", "$conductorName");
        await printLeftRight("DRIVER:", "$driverName");
        await printLeftRight("DISPATCHER:", "$dispatcherName");
        await printText("ROUTE:     $route", 1);
        await printLeftRight("SN:", "${session['serialNumber']}");

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);

        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTripReportGATC(
      double totalTransaction, double totalAmount, String vehicleNo) async {
    try {
      final coopData = fetchservice.fetchCoopData();
      if (printerController.connected.value) {
        String formatDateNow() {
          final now = DateTime.now();
          final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
          return formattedDate;
        }

        String dateConverter(String dateString) {
          DateTime dateTime = DateTime.parse(dateString);
          String formattedDateTime =
              DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
          return formattedDateTime;
        }

        final formattedDate = formatDateNow();

        await printHeader();

        await printText("TRIP SUMMARY", 1, 1);
        await printLeftRight("DATE:", "$formattedDate");
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText('Number of Transaction', 1, 28);
        await printText('${totalTransaction.toInt()}', 1, 28);
        await printText('Total Amount of Collections', 28);
        await printText('${NumberFormat('#,###').format(totalAmount)}', 1, 28);

        await printText(
            '${coopData['coopType'].toString().toUpperCase()} #$vehicleNo',
            1,
            28);

        await printText("- - - - - - - - - - - - - - -", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print('error printTripReportGATC: $e');
      return false;
    }
  }

  Future<bool> printTripReportFinal(
      String totalTrip,
      String torNo,
      String totalBaggage,
      String prepaidPass,
      // String prepaidBagg,
      String puncherTR,
      String puncherTC,
      String puncherBR,
      String puncherBC,
      String passengerTR,
      String passengerTC,
      String waybillrevenue,
      String waybillcount,
      String baggageTR,
      String baggageTC,
      String charterPR,
      String charterPC,
      String finalRemitt,
      String shortOver,
      String cashReceived,
      String cardSales,
      String addFare,
      String topupTotal,
      String grandTotal,
      String netCollection) async {
    try {
      final expensesList = fetchservice.fetchExpensesList();
      final coopData = fetchservice.fetchCoopData();
      bool isDltb = false;
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        isDltb = true;
      }
      List<Map<String, dynamic>> othersExpenses = [];

      if (printerController.connected.value) {
        String formatDateNow() {
          final now = DateTime.now();
          final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
          return formattedDate;
        }

        String dateConverter(String dateString) {
          DateTime dateTime = DateTime.parse(dateString);
          String formattedDateTime =
              DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
          return formattedDateTime;
        }

        final formattedDate = formatDateNow();
        await printHeader();

        await printText("TRIP SUMMARY", 1);
        await printText("DATE: $formattedDate", 1);
        await printLeftRight("TOTAL TRIPS", "$totalTrip");
        await printLeftRight("TOR#:", "$torNo");
        await printText("- - - - - - - - - - - - - - -", 1);
        if (expensesList.isNotEmpty) {
          await printText("EXPENSES", 1);
          await printLeftRight("PARTICULAR:", "AMOUNT");
          double totalExpenses = 0;
          for (var expense in expensesList) {
            totalExpenses += expense['amount'];
            String expenseDescription = expense['particular'];
            double expenseAmount = double.parse(expense['amount'].toString());
            // await printLeftRight(
            //     "PARTICULAR:", "${expenseDescription.toUpperCase()}", 1);
            if (expense['particular'] == "SERVICES" ||
                expense['particular'] == "CALLER'S FEE" ||
                expense['particular'] == "EMPLOYEE BENEFITS" ||
                expense['particular'] == "MATERIALS" ||
                expense['particular'] == "REPRESENTATION" ||
                expense['particular'] == "REPAIR") {
              othersExpenses.add(expense);
            } else {
              await printLeftRight(
                "$expenseDescription",
                "${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
              );
            }
          }
          if (othersExpenses.isNotEmpty) {
            await printLeftRight("OTHERS", "", 1);
            for (var expense in othersExpenses) {
              String expenseDescription = expense['particular'];
              if (expenseDescription == "EMPLOYEE BENEFITS") {
                expenseDescription = "EMP BENEFITS";
              }
              double expenseAmount = double.parse(expense['amount'].toString());

              await printLeftRight(
                " ${expenseDescription}",
                "${coopData['coopType'] == "Bus" ? expenseAmount.round() : expenseAmount.toStringAsFixed(2)}",
              );
            }
          }
          await printLeftRight(
              "TOTAL EXPENSES", "${totalExpenses.toStringAsFixed(2)}");
          await printText("- - - - - - - - - - - - - - -", 1);
        }
        await printLeftRight("TOTAL BAGGAGE:", "$totalBaggage");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("PREPAID PASS:", "$prepaidPass");

          // await printLeftRight("PREPAID BAGG:", "$prepaidBagg", 1);
          await printLeftRight("PUNCHER TR:", "$puncherTR");
          await printLeftRight("PUNCHER TC:", "$puncherTC");
          await printLeftRight("PUNCHER BR:", "$puncherBR");
          await printLeftRight("PUNCHER BC:", "$puncherBC");
        }
        await printLeftRight("PASSENGER TR:", "$passengerTR");
        await printLeftRight("PASSENGER TC:", "$passengerTC");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("WAYBILL TR:", "$waybillrevenue");
          await printLeftRight("WAYBILL TC:", "$waybillcount");
        }
        await printLeftRight("BAGGAGE TR:", "$baggageTR");
        await printLeftRight("BAGGAGE TC:", "$baggageTC");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("CHARTER PR:", "$charterPR");
          await printLeftRight("CHARTER PC:", "$charterPC");
        }
        await printLeftRight("FINAL REMITT:", "$finalRemitt");
        await printLeftRight("SHORT/OVER:", "$shortOver");
        await printLeftRight("CASH RECEIVED:", "$cashReceived");
        await printLeftRight("CARD SALES:", "$cardSales");
        await printLeftRight("ADD FARE:", "$addFare");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("TOPUP TOTAL:", "$topupTotal");
        }
        await printLeftRight("GROSS REVENUE:", "$grandTotal");
        await printLeftRight("NET COLLECTION:", "$netCollection");
        await printText("- - - - - - - - - - - - - - -", 1);

        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print("printTripReportFinal error: $e");
      return false;
    }
  }

  Future<bool> printTripReport(
      // String torNo,
      // String vehicleNo,
      // String conductorName,
      // String driverName,
      // String dispatcherName,
      String cashierName,
      // int regularCount,
      // int discountedCount,
      // int baggageCount,
      // String route,
      // int totalTickets,
      // double totalAmount,
      List<Map<String, dynamic>> torTrip,
      List<Map<String, dynamic>> torTicket,
      List<Map<String, dynamic>> prePaidPassenger,
      List<Map<String, dynamic>> prePaidBaggage,
      double finalRemitt,
      double shortOver,
      double puncherTR,
      double puncherTC,
      double puncherBR,
      double puncherBC,
      double passengerRevenue,
      double passengerCount,
      double baggageRevenue,
      double baggageCount,
      double charterTicketRevenue,
      double charterTicketCount) async {
    try {
      final expensesList = fetchservice.fetchExpensesList();

      final coopData = fetchservice.fetchCoopData();

      if (printerController.connected.value) {
        // final myBox = Hive.box('myBox');
        // final ticketList = myBox.get('torTicket');

        bool isPrinterReady = false;

        isPrinterReady = true;

        double grandTotal = 0;
        double grandBaggage = 0;
        double grandPrepaidPassengerTotal = 0;
        double grandPrepaidBaggageTotal = 0;
        double grandTotalCashRecived = 0;
        double additionalFare = 0;

        String formatDateNow() {
          final now = DateTime.now();
          final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
          return formattedDate;
        }

        String dateConverter(String dateString) {
          DateTime dateTime = DateTime.parse(dateString);
          String formattedDateTime =
              DateFormat('MMM dd, yyyy EEE hh:mm:ss a').format(dateTime);
          return formattedDateTime;
        }

        final formattedDate = formatDateNow();
        await printHeader();

        await printText("TRIP SUMMARY", 1, 1);
        await printText("DATE: $formattedDate", 1, 1);
        // await printText("- - - - - - - - - - - - - - -", 1);
        //         await printText("OT#: 123-456-789-910", 1, 1);
        // await printText("CT#: 123-456-789-910", 1, 1);

        for (int i = 0; i < torTrip.length; i++) {
          print('tortrip[$i]: ${torTrip[i]}');
          String conductorName = torTrip[i]['conductor'].toString();
          String dispatcherName1 = torTrip[i]['departed_dispatcher'].toString();
          String dispatcherName2 = torTrip[i]['arrived_dispatcher'].toString();
          String driverName = torTrip[i]['driver'].toString();
          String control_no = torTrip[i]['control_no'].toString();
          String torNo = torTrip[i]['tor_no'].toString();
          String departed_date =
              dateConverter(torTrip[i]['departure_timestamp'].toString());
          String arrived_date =
              dateConverter(torTrip[i]['arrival_timestamp'].toString());
          String vehicleNo = torTrip[i]['bus_no'].toString();

          int regularCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['discount'] == 0)
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          print('ticketList: $torTicket');
          print('regularCount: $regularCount');
          int discountedCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['discount'] > 0)
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);
          int pwdCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "pwd")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int studentCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "student")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int seniorCount = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no &&
                  (ticket['fare'] ?? 0) > 0 &&
                  ticket['passengerType'] == "senior")
              .fold<int>(0, (sum, ticket) => sum + (ticket['pax'] ?? 1) as int);

          int baggageCounter = torTicket
              .where((ticket) =>
                  ticket['control_no'] == control_no && ticket['baggage'] > 0)
              .length;

          int prePaidPassengerCount = prePaidPassenger
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0,
                (sum, entry) => sum + (entry['totalPassenger'] ?? 0) as int,
              );
          int prePaidBaggageCount = prePaidBaggage
              .where((ticket) => ticket['control_no'] == control_no)
              .length;

          double prePaidPassengerAmount = prePaidPassenger
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0.0,
                (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
              );
          double cardSales = torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['cardType'] != "mastercard" &&
                      entry['cardType'] != "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      (double.parse(entry['fare'].toString() ?? "0.0") *
                          entry['pax']) +
                      double.parse(entry['baggage'].toString() ?? "0.0"));

          cardSales += torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['additionalFareCardType'] != "mastercard" &&
                      entry['additionalFareCardType'] != "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      double.parse(
                          entry['additionalFare'].toString() ?? "0.0"));
          double cashR = torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['cardType'] == "mastercard" ||
                      entry['cardType'] == "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      (double.parse(
                          entry['fare'].toString() ?? "0.0" * entry['pax'])) +
                      double.parse(entry['baggage'].toString() ?? "0.0"));

          cashR += torTicket
              .where((entry) =>
                  entry['control_no'] == control_no &&
                  (entry['additionalFareCardType'] == "mastercard" ||
                      entry['additionalFareCardType'] == "cash"))
              .fold(
                  0.0,
                  (sum, entry) =>
                      sum +
                      double.parse(
                          entry['additionalFare'].toString() ?? "0.0"));
          double prePaidBaggageAmount = prePaidBaggage
              .where((entry) => entry['control_no'] == control_no)
              .fold(
                0.0,
                (sum, entry) => sum + (entry['totalAmount'] ?? 0.0) as double,
              );
          grandPrepaidPassengerTotal += prePaidPassengerAmount;
          grandPrepaidBaggageTotal += prePaidBaggageAmount;

          double tripTotalbaggage = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(0.0,
                  (sum, ticket) => sum + (ticket['baggage'] as num).toDouble());

          int totalTickets = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .length;
          double totalAmount = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(
                  0.0,
                  (sum, ticket) =>
                      sum +
                      ((ticket['fare'] as num).toDouble() * ticket['pax']) +
                      (ticket['baggage'] as num).toDouble() +
                      (ticket['additionalFare'] as num).toDouble());

          additionalFare = torTicket
              .where((ticket) => ticket['control_no'] == control_no)
              .fold(
                  0.0,
                  (sum, ticket) =>
                      sum + (ticket['additionalFare'] as num).toDouble());

          grandTotal +=
              totalAmount += prePaidBaggageAmount + prePaidPassengerAmount;

          grandBaggage += tripTotalbaggage;
          grandTotalCashRecived += totalAmount;
          String route = '${torTrip[i]['route']}';
          String tripType = '${torTrip[i]['tripType']}';

          if (conductorName.length > 16) {
            conductorName = conductorName.substring(0, 13) + "..";
          }
          if (dispatcherName1.length > 16) {
            dispatcherName1 = dispatcherName1.substring(0, 13) + "..";
          }
          if (dispatcherName2.length > 16) {
            dispatcherName2 = dispatcherName2.substring(0, 13) + "..";
          }
          if (driverName.length > 16) {
            driverName = driverName.substring(0, 13) + "..";
          }
          if (cashierName.length > 16) {
            cashierName = cashierName.substring(0, 13) + "..";
          }

          // if (route.length <= 16) {
          //   // route = route.substring(0, 12) + "..";
          //   isrouteLong = true;
          // } else if (route.length > 25) {
          //   isrouteLong = true;
          //   route = route.substring(0, 23) + "..";
          // }

          // await printNewLine();

          if (isPrinterReady) {
            // await printText("- - - - - - - - - - - - - - -", 1);
            // if (coopData['coopType'] == 'Bus') {
            //   await printText("TRIP No ${i + 1}", 1, 1);
            // }
            // await printText("TOR#: $torNo", 1, 1);
            // await printText(
            //     "TRIP TYPE: ${tripType.toUpperCase()}", 1, 1);
            // // await printLeftRight("ATM:", "1", 1);
            // await printLeftRight("DISPATCHED:", "$departed_date", 1);
            // await printLeftRight("ARRIVED:", "$arrived_date", 1);
            // await printLeftRight("VEHICLE NO:", "$vehicleNo", 1);
            // await printLeftRight("CONDUCTOR:", "$conductorName", 1);
            // await printLeftRight("DRIVER:", "$driverName", 1);
            // await printLeftRight("DISPATCHER 1:", "$dispatcherName1", 1);
            // await printLeftRight("DISPATCHER 2:", "$dispatcherName2", 1);
            // await printLeftRight("CASHIER:", "$cashierName", 1);
            // if (coopData['coopType'] == 'Bus') {
            // await printText("- - - - - - - - - - - - - - -", 1);
            // await printLeftRight("TYPE:", "", 1);
            // await printLeftRight("Regular:", "$regularCount", 1);

            // await printLeftRight("PWD:", "$pwdCount", 1);
            // await printLeftRight("STUDENT:", "$studentCount", 1);
            // await printLeftRight("SENIOR:", "$seniorCount", 1);
            // await printLeftRight("Discounted:", "$discountedCount", 1);
            // await printLeftRight(
            //     "Baggage Issued:", "$baggageCounter", 1);
            // await printLeftRight("Total Baggage:",
            //     "${tripTotalbaggage.toStringAsFixed(2)}", 1);
            // await printLeftRight(
            //     "CS:", "${cardSales.toStringAsFixed(2)}", 1);
            // await printLeftRight(
            //     "CASH RECEIVED:", "${cashR.toStringAsFixed(2)}", 1);
            // await printLeftRight(
            //     "PREPAID PASS:", "$prePaidPassengerCount", 1);
            // await printLeftRight(
            //     "PREPAID BAGG:", "$prePaidBaggageCount", 1);
            // await printText("- - - - - - - - - - - - - - -", 1);

            // await printText("TRIP", 1, 1);
            // await printText("$route", 1, 1);

            // await printText("- - - - - - - - - - - - - - -", 1);

            // await printLeftRight(
            //     "TOTAL TICKETS:", "${totalTickets.toStringAsFixed(2)}", 1);
            // await printLeftRight(
            //     "SUBTOTAL AMOUNT:", "${totalAmount.toStringAsFixed(2)}", 1);
            // await printText("- - - - - - - - - - - - - - -", 1);
            // await printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
            List<Map<String, dynamic>> othersExpenses = [];
            try {
              if (torTrip[i]['control_no'] == expensesList[i]['control_no']) {
                double totalExpenses = 0;
                List<Map<String, dynamic>> filteredExpenses = expensesList
                    .where((expenses) =>
                        expenses['control_no'] == torTrip[i]['control_no'])
                    .toList();
                if (coopData['coopType'] == 'Bus') {
                  await printLeftRight("TRIP No ", "${i + 1}");
                }
                await printLeftRight("TOR#:", "$torNo");
                await printLeftRight("TRIP TYPE:", "${tripType.toUpperCase()}");
                await printText("EXPENSES", 1);
                await printLeftRight("PARTICULAR:", "AMOUNT");
                for (var element in filteredExpenses) {
                  totalExpenses += double.parse(element['amount'].toString());
                  if (element['particular'] == "SERVICES" ||
                      element['particular'] == "CALLER'S FEE" ||
                      element['particular'] == "EMPLOYEE BENEFITS" ||
                      element['particular'] == "MATERIALS" ||
                      element['particular'] == "REPRESENTATION" ||
                      element['particular'] == "REPAIR") {
                    othersExpenses.add(element);
                  } else {
                    await printLeftRight(
                        "${element['particular']}", "${element['amount']}");
                  }
                }
                if (othersExpenses.isNotEmpty) {
                  await printLeftRight("OTHERS", "");
                  for (var element in othersExpenses) {
                    // if ("${element['particular']}".length > 16) {
                    //   element['particular'] =
                    //       element['particular'].substring(0, 13) + ".";
                    // }
                    if (element['particular'] == "EMPLOYEE BENEFITS") {
                      element['particular'] = "EMP BENEFITS";
                    }
                    await printLeftRight(
                        " ${element['particular']}", "${element['amount']}");
                  }
                }

                await printLeftRight("TOTAL EXPENSES:", "$totalExpenses");
              }
            } catch (e) {
              print(e);
            }
          }
        }
        await printText("- - - - - - - - - - - - - - -", 1);
        grandTotalCashRecived += puncherTR + puncherBR;
        await printLeftRight("TOTAL BAGGAGE:",
            "${fetchservice.grandTotalBaggage().toStringAsFixed(2)}");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("PREPAID PASS:",
              "${grandPrepaidPassengerTotal.toStringAsFixed(2)}");
        }
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("PUNCHER TR:", "${puncherTR}");
          await printLeftRight("PUNCHER TC:", "${puncherTC}");

          await printLeftRight("PUNCHER BR:", "${puncherBR}");
          await printLeftRight("PUNCHER BC:", "${puncherBC}");
        }

        // NEW
        await printLeftRight("PASSENGER TR:", "${passengerRevenue}");
        await printLeftRight("PASSENGER TC:", "${passengerCount}");

        await printLeftRight("BAGAGGE TR:", "${baggageRevenue}");
        await printLeftRight("BAGGAGE TC:", "${baggageCount}");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("CHARTER PR:", "${charterTicketRevenue}");
          await printLeftRight("CHARTER PC:", "${charterTicketCount}");
        }
        // END NEW

        await printLeftRight("FINAL REMITT:", "$finalRemitt");
        await printLeftRight("SHORT/OVER:", "$shortOver");

        await printLeftRight("CASH RECEIVED:",
            "${fetchservice.getAllCashRecevied().toStringAsFixed(2)}");
        await printLeftRight("CARD SALES:",
            "${fetchservice.grandTotalCardSales().toStringAsFixed(2)}");
        await printLeftRight(
            "ADD FARE:", "${fetchservice.grandTotalAddFare()}");
        if (coopData['coopType'] == "Bus") {
          await printLeftRight("TOPUP TOTAL:",
              "${fetchservice.getTotalTopUpper().toStringAsFixed(2)}");
        }
        await printLeftRight(
            "GRAND TOTAL:",
            "${(fetchservice.getAllCashRecevied() + fetchservice.grandTotalCardSales() + fetchservice.totalPrepaidPassengerRevenue() + fetchservice.totalPrepaidBaggageRevenue()).toStringAsFixed(2)}",
            1);

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print('print report error: $e');
      return false;
    }
  }

  // bool printTripSummary() {
  //   final coopData = fetchservice.fetchCoopData();
  //   String formatDateNow() {
  //     final now = DateTime.now();
  //     final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
  //     return formattedDate;
  //   }

  //   try {
  //     final formattedDate = formatDateNow();
  //     // if (route.length <= 16) {
  //     //   // route = route.substring(0, 12) + "..";
  //     //   isrouteLong = true;
  //     // } else if (route.length > 25) {
  //     //   isrouteLong = true;
  //     //   route = route.substring(0, 23) + "..";
  //     // }

  //     if(printerController.connected.value){

  //   await printHeader();

  //         await printText("TRIP SUMMARY", 1);
  //         await printCustom("TOR#: 123-456-789-910", 1, 1);
  //         await printCustom("OT#: 123-456-789-910", 1, 1);
  //         await printCustom("CT#: 123-456-789-910", 1, 1);
  //         await printCustom("- - - - - - - - - - - - - - -", 1, 1);
  //         // await printLeftRight("ATM:", "1", 1);
  //         await printLeftRight("DISPATCHED:", "$formattedDate", 1);
  //         await printLeftRight(
  //             "${coopData['coopType'].toString().toUpperCase()} NO:", "103", 1);
  //         await printLeftRight("CONDUCTOR:", "Juan Dela Cruz", 1);
  //         await printLeftRight("DRIVER:", "Juan Dela Cruz", 1);
  //         await printLeftRight("DISPATCHER:", "Juan Dela Cruz", 1);
  //         await printCustom("ROUTE:     DISTRICT - STAR MALL", 1, 1);
  //         // await printLeftRight("ROUTE:", "DISTRICT - STAR MALL", 1);
  //         await printNewLine();
  //         await printNewLine();
  //         await printCustom("- - - - - - - - - - - - - - -", 1, 1);
  //         await printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);

  //      await SunmiPrinter.lineWrap(3);
  //      await SunmiPrinter.cut();
  //     }

  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  num convertNumToIntegerOrDecimal(num number) {
    // Convert the number to a string
    String numberString = number.toString();
    int decimalIndex = numberString.indexOf('.');
    // Check if the number contains a decimal point or is greater than 0 as a double
    if (decimalIndex != -1 && decimalIndex < numberString.length - 1) {
      // If it contains a decimal or is greater than 0, return it as a double
      String decimalPart = numberString.substring(decimalIndex + 1);
      if (double.parse(decimalPart) > 0) {
        return double.parse(numberString);
      } else {
        return number.toInt();
      }
    } else {
      // If it doesn't contain a decimal and is not greater than 0, return it as an integer
      return number.toInt();
    }
  }

  Future<bool> printInspectionSummary(
      String type,
      String torNo,
      String passenger,
      String baggage,
      String headCount,
      String kmPost,
      String driverName,
      String conductorName,
      String vehicleNo,
      String route,
      String inspectorName,
      List<Map<String, dynamic>> tickets,
      bool isTicket,
      int discrepancy,
      int passengerTransfer,
      int PassengerWithPass,
      int PassengerPrepaid,
      int baggageCount) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      // if (route.length <= 16) {
      //   // route = route.substring(0, 12) + "..";
      //   isrouteLong = true;
      // } else if (route.length > 25) {
      //   isrouteLong = true;
      //   route = route.substring(0, 23) + "..";
      // }

      if (printerController.connected.value) {
        await printHeader();

        await printText("INSPECTION SUMMARY", 1);
        await printText("${type.toUpperCase()}", 1);
        await printText("TOR#: $torNo", 1);

        await printText("- - - - - - - - - - - - - - -", 1);

        await printText("DATE: $formattedDate", 1);
        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo");
        await printLeftRight("INSPECTOR:", "$inspectorName");
        await printLeftRight("CONDUCTOR:", "$conductorName");
        await printLeftRight("DRIVER:", "$driverName");
        await printLeftRight("ROUTE:", "$route");
        await printLeftRight("OPENING:", "${tickets[0]['ticket_no']}");
        await printLeftRight(
            "CLOSING:", "${tickets[tickets.length - 1]['ticket_no']}");

        await printText("- - - - - - - - - - - - - - -", 1);
        await printLeftRight("PASSENGER:", "$passenger");

        await printLeftRight("BAGGAGE:", "$baggage");
        if (!fetchservice.getIsNumeric()) {
          await printLeftRight("HEAD COUNT:", "$headCount");
          await printLeftRight("BAGGAGE COUNT:", "${baggageCount}");
          await printLeftRight("DISCREPANCY:", "${discrepancy}");
        }

        if (!fetchservice.getIsNumeric()) {
          await printLeftRight("TRANSFER:", "$passengerTransfer");
          await printLeftRight("PASSED:", "$PassengerWithPass");
          await printLeftRight("PREPAID:", "$PassengerPrepaid");
        }
        if (!fetchservice.getIsNumeric()) {
          await printLeftRight("KM POST:", "$kmPost");
        }

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("INSPECTION TICKET REPORT", 1);

        await printText("TN   TIME   FR TO   FARE   PAX", 1);

        double grandtotal = 0;
        double grandbaggage = 0;
        double grandcardsales = 0;
        double grandcashreceived = 0;

        double grandbaggageonly = 0;
        double grandbaggagewithpassenger = 0;

        int pwdcount = 0;
        int studentcount = 0;
        int seniorcount = 0;
        int cardsalescount = 0;
        int regularcount = 0;
        int baggagecount = 0;
        int discountedcount = 0;
        int totalticketcount = 0;
        double addfare = 0;

        bool havebaggage = false;
        bool havepwd = false;
        bool havestudent = false;
        bool havesenior = false;
        bool havecardsales = false;
        bool havebaggageonly = false;
        bool havebaggagewithpassenger = false;
        bool haveAddFare = false;
        bool haveCsAddfare = false;
        bool havecardsalesbaggage = false;
        for (int i = 0; i < tickets.length; i++) {
          num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
          // print('inspection tickets $i: ${tickets}');
          grandtotal +=
              (double.parse(tickets[i]['fare'].toString()) * tickets[i]['pax']);

          grandtotal += double.parse(tickets[i]['baggage'].toString());
          addfare += double.parse(tickets[i]['additionalFare'].toString());

          totalticketcount += 1;
          if (tickets[i]['cardType'] == "mastercard" ||
              tickets[i]['cardType'] == "cash") {
            grandcashreceived += (double.parse(tickets[i]['fare'].toString()) *
                    tickets[i]['pax']) +
                double.parse(tickets[i]['baggage'].toString());
          }
          if (tickets[i]['additionalFareCardType'] == "mastercard" ||
              tickets[i]['additionalFareCardType'] == "cash") {
            grandcashreceived +=
                double.parse(tickets[i]['additionalFare'].toString());
          }
          if (tickets[i]['cardType'] != "mastercard" &&
              tickets[i]['cardType'] != "cash") {
            grandcardsales += (double.parse(tickets[i]['fare'].toString()) *
                    tickets[i]['pax']) +
                double.parse(tickets[i]['baggage'].toString());
          }
          if (tickets[i]['additionalFareCardType'] != "mastercard" &&
              tickets[i]['additionalFareCardType'] != "cash") {
            grandcardsales +=
                double.parse(tickets[i]['additionalFare'].toString());
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              (tickets[i]['passengerType'] == 'regular' ||
                  tickets[i]['passengerType'] == 'FULL FARE')) {
            regularcount += tickets[i]['pax'] as int;

            DateTime dateTime =
                DateTime.parse(tickets[i]['created_on'].toString());
            String timeOnly = "${dateTime.hour}:${dateTime.minute}";

            await printText(
                "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-${toKm}     ${tickets[i]['fare'].toStringAsFixed(2)}   ${tickets[i]['pax']}",
                0);
          }

          if (tickets[i]['baggage'] > 0) {
            havebaggage = true;
          }
          if (tickets[i]['additionalFare'] > 0 &&
              (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                  tickets[i]['additionalFareCardType'] == 'cash')) {
            haveAddFare = true;
          }
          if (tickets[i]['additionalFare'] > 0 &&
              tickets[i]['additionalFareCardType'] != 'mastercard' &&
              tickets[i]['additionalFareCardType'] != 'cash') {
            haveCsAddfare = true;
          }

          if (tickets[i]['baggage'] > 0 && tickets[i]['fare'] > 0) {
            havebaggagewithpassenger = true;
          }

          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'student') {
            havestudent = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'pwd') {
            havepwd = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] == 'mastercard' ||
                  tickets[i]['cardType'] == 'cash') &&
              tickets[i]['passengerType'] == 'senior') {
            havesenior = true;
          }
          if (tickets[i]['fare'] > 0 &&
              (tickets[i]['cardType'] != 'mastercard' &&
                  tickets[i]['cardType'] != 'cash')) {
            havecardsales = true;
          }
          if (tickets[i]['fare'] == 0 &&
              tickets[i]['cardType'] != 'mastercard' &&
              tickets[i]['cardType'] != 'cash') {
            havecardsalesbaggage = true;
          }
        }

        grandtotal += addfare;
        if (havebaggage) {
          await printLeftRight("BAGGAGE", "", 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['baggage'] > 0) {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              grandbaggageonly +=
                  double.parse(tickets[i]['baggage'].toString());
              baggagecount += 1;
              grandbaggage += double.parse(tickets[i]['baggage'].toString());

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['baggage']}",
                  0);
            }
          }
        }

        if (havestudent) {
          await printLeftRight("STUDENT", "");

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'student') {
              studentcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['fare'].toStringAsFixed(2)}   ${tickets[i]['pax']}  ",
                  0);
            }
          }
        }

        if (havesenior) {
          await printLeftRight("SENIOR", "", 1);
          // await printText("SENIOR", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'senior') {
              seniorcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['fare'].toStringAsFixed(2)}   ${tickets[i]['pax']}",
                  0);
            }
          }
        }
        if (havepwd) {
          await printLeftRight("PWD", "", 1);
          // await printText("PWD", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['fare'] > 0 &&
                (tickets[i]['cardType'] == 'mastercard' ||
                    tickets[i]['cardType'] == 'cash') &&
                tickets[i]['passengerType'] == 'pwd') {
              pwdcount += tickets[i]['pax'] as int;
              discountedcount += tickets[i]['pax'] as int;

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['fare'].toStringAsFixed(2)}   ${tickets[i]['pax']}",
                  0);
            }
          }
        }
        if (havecardsales) {
          await printLeftRight("CS TICKET", "", 1);
          // await printText("CARD SALES", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if ((tickets[i]['cardType'] != 'mastercard' &&
                    tickets[i]['cardType'] != 'cash') &&
                tickets[i]['fare'] > 0) {
              cardsalescount += tickets[i]['pax'] as int;
              if (tickets[i]['passengerType'] == "regular" ||
                  tickets[i]['passengerType'] == "FULL FARE") {
                regularcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "student") {
                studentcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "senior") {
                seniorcount += tickets[i]['pax'] as int;
              }
              if (tickets[i]['passengerType'] == "pwd") {
                pwdcount += tickets[i]['pax'] as int;
              }

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['fare'].toStringAsFixed(2)}   ${tickets[i]['pax']}",
                  0);
            }
          }
        }
        if (havecardsalesbaggage) {
          await printLeftRight("CS BAGGAGE", "", 1);
          // await printText("CARD SALES", 1, 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if ((tickets[i]['cardType'] != 'mastercard' &&
                    tickets[i]['cardType'] != 'cash') &&
                tickets[i]['fare'] == 0) {
              cardsalescount += tickets[i]['pax'] as int;

              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['baggage']}",
                  0);
            }
          }
        }
        if (haveAddFare) {
          await printLeftRight("ADD FARE", "", 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['additionalFare'] > 0 &&
                (tickets[i]['additionalFareCardType'] == 'mastercard' ||
                    tickets[i]['additionalFareCardType'] == 'cash')) {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";
              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['additionalFare']}",
                  0);
            }
          }
        }
        if (haveCsAddfare) {
          await printLeftRight("CS ADD FARE", "", 1);

          for (int i = 0; i < tickets.length; i++) {
            num toKm = convertNumToIntegerOrDecimal(tickets[i]['to_km']);
            if (tickets[i]['additionalFare'] > 0 &&
                tickets[i]['additionalFareCardType'] != 'mastercard' &&
                tickets[i]['additionalFareCardType'] != 'cash') {
              DateTime dateTime =
                  DateTime.parse(tickets[i]['created_on'].toString());
              String timeOnly = "${dateTime.hour}:${dateTime.minute}";

              await printText(
                  "${tickets[i]['ticket_no'].toString().substring(tickets[i]['ticket_no'].length - 4)}  $timeOnly  ${tickets[i]['from_km']}-$toKm     ${tickets[i]['additionalFare']}",
                  0);
            }
          }
        }

        await printText("- - - - - - - - - - - - - - -", 1);
        await printLeftRight("TICKET ISSUED:", "$totalticketcount");
        await printLeftRight("BAGGAGE ISSUED:", "$baggage");
        await printLeftRight("REGULAR ISSUED:", "$regularcount");
        await printLeftRight("STUDENT ISSUED:", "$studentcount");
        await printLeftRight("PWD ISSUED:", "$pwdcount");
        await printLeftRight("SENIOR ISSUED:", "$seniorcount");

        await printLeftRight("DISC ISSUED:", "$discountedcount");
        await printLeftRight("CS ISSUED:", "$cardsalescount");
        await printLeftRight("CARD SALES:", "$grandcardsales");
        await printLeftRight("CASH RECEIVED:", "$grandcashreceived");

        await printLeftRight("BAGGAGE TOTAL:", "$grandbaggage");
        await printLeftRight("ADD FARE:", "$addfare");
        await printLeftRight("GRAND TOTAL:", "$grandtotal");
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);

        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpPassengerReceipt(
      String sNo,
      String MCsNo,
      String vehicleNo,
      double amount,
      double previousBalance,
      double newBalance,
      double conductorpreviousBalance,
      double conductornewBalance,
      String referenceNumber) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("TOP-UP CONDUCTOR'S COPY RECEIPT", 1);

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("REF NO:", "$referenceNumber");
        await printLeftRight("SN:", "$MCsNo");
        await printLeftRight("DATE:", "$formattedDate");
        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo");
        await printLeftRight("AMOUNT:", "${amount.toStringAsFixed(2)}");
        await printLeftRight(
            "PREV BALANCE:", "${conductorpreviousBalance.toStringAsFixed(2)}");
        await printLeftRight(
            "NEW BALANCE:", "${conductornewBalance.toStringAsFixed(2)}");
        await printText("- - - - - - - - - - - - - - -", 1);

        await printHeader();

        await printText("TOP-UP PASSENGER'S COPY RECEIPT", 1);

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("REF NO:", "$referenceNumber");
        await printLeftRight("DATE:", "$formattedDate");
        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()} NO:",
            "$vehicleNo");
        await printLeftRight("AMOUNT:", "${amount.toStringAsFixed(2)}");
        await printLeftRight(
            "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}");
        await printLeftRight(
            "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}");
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTopUpMasterCard(
      String sNo,
      String cardOwner,
      double amount,
      double previousBalance,
      double newBalance,
      String referenceNumber,
      String cashierName) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    if (cardOwner.length > 16) {
      cardOwner = cardOwner.substring(0, 15);
    }
    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("TOP-UP CASHIER'S COPY RECEIPT", 1);

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("REF NO:", "$referenceNumber");

        await printLeftRight("DATE:", "$formattedDate");
        await printLeftRight("SN:", "$sNo");
        await printLeftRight("CARD OWNER:", "$cardOwner");
        await printLeftRight("CASHIER:", "$cashierName");
        await printLeftRight("AMOUNT:", "${amount.toStringAsFixed(2)}");
        await printLeftRight(
            "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}");
        await printLeftRight(
            "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}");
        await printText("- - - - - - - - - - - - - - -", 1);

        await printHeader();

        await printText("TOP-UP COPY RECEIPT", 1);

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("REF NO:", "$referenceNumber");
        await printLeftRight("DATE:", "$formattedDate");
        await printLeftRight("SN:", "$sNo");
        await printLeftRight("CARD OWNER:", "$cardOwner");
        await printLeftRight("CASHIER:", "$cashierName");
        await printLeftRight("AMOUNT:", "$amount");
        await printLeftRight(
            "PREV BALANCE:", "${previousBalance.toStringAsFixed(2)}");
        await printLeftRight(
            "NEW BALANCE:", "${newBalance.toStringAsFixed(2)}");
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print('printTopUpMasterCard error: $e');
      return false;
    }
  }

  Future<bool> printCheckingBalance(
    String cardId,
    double amount,
  ) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      String formattedNumber = NumberFormat("#,##0", "en_US")
          .format(double.parse(amount.toStringAsFixed(2)));
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("CHECKING BALANCE RECEIPT", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("SN:", "$cardId");

        await printText("BALANCE: ${amount.toStringAsFixed(2)}", 1, 28);

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printTrouble(
      String torNo,
      String route,
      String dateoftrip,
      String vehicleNo,
      String bound,
      String inspectorName,
      String trouble,
      String kmPost,
      String onboardPlace) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("TROUBLE REPORT", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("TOR NO:", "$torNo");
        await printLeftRight("ROUTE:", "$route");
        await printLeftRight("DATE OF TRIP:", "$dateoftrip");
        await printLeftRight(
            '${coopData['coopType'].toString().toUpperCase()} No',
            '$vehicleNo');
        await printLeftRight('Bound', '$bound');

        await printLeftRight('INSP NAME:', '$inspectorName');
        if (!fetchservice.getIsNumeric()) {
          await printLeftRight('KM POST', '$kmPost');
          await printLeftRight('ONBOARD PLACE', '$onboardPlace');
        }

        await printText("TROUBLE DESC", 1);
        await printText("$trouble", 1);
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printViolation(
      String torNo,
      String route,
      String dateoftrip,
      String vehicleNo,
      String bound,
      String inspectorName,
      String employeeName,
      String violation,
      String kmpost,
      String onboardplace) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("VIOLATION REPORT", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("TOR NO:", "$torNo");
        await printLeftRight("ROUTE:", "$route");
        await printLeftRight("DATE OF TRIP:", "$dateoftrip");
        await printLeftRight(
            '${coopData['coopType'].toString().toUpperCase()} No',
            '$vehicleNo');
        await printLeftRight('BOUND', '$bound');
        if (!fetchservice.getIsNumeric()) {
          await printLeftRight('KM POST', '$kmpost');
          await printLeftRight('ONBOARD PLACE', '$onboardplace');
        }

        await printLeftRight('INSP NAME:', '$inspectorName');
        await printLeftRight('EMP NAME:', '$employeeName');
        await printText("VIOLATION", 1);
        await printText("$violation", 1);

        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printAdditionalFare(
      Map<String, dynamic> item, double amount) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      if (printerController.connected.value) {
        await printHeader();

        await printText("ADDITIONAL FARE", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight("Ticket No:", "${item['ticket_no']}");
        await printLeftRight("ROUTE:", "${item['route']}");
        if (!fetchservice.getIsNumeric()) {
          await printLeftRight('FROM', '${item['from_place']}');
          await printLeftRight('TO', '${item['to_place']}');
        }

        await printLeftRight('ADDITIONAL FARE', '$amount');
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> printFuel(Map<String, dynamic> item) async {
    final coopData = fetchservice.fetchCoopData();
    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();

      if (printerController.connected.value) {
        await printHeader();

        await printText("FUEL RECEIPT", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()}#:",
            "${item['bus_no']}");
        await printLeftRight("ROUTE:", "${item['route']}");
        await printLeftRight("ATTENDANT:", "${item['fuel_attendant']}");
        await printLeftRight('STATION', '${item['fuel_station']}');
        await printLeftRight('FULL TANK', '${item['full_tank']}');
        await printLeftRight('LITERS', '${item['fuel_liters']}');
        await printLeftRight(
            'PRICE PER LITER', '${item['fuel_price_per_liter']}');
        await printLeftRight('AMOUNT', '${item['fuel_amount']}');
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print("$e");
      return false;
    }
  }

  Future<bool> printPrepaid(Map<String, dynamic> item) async {
    final coopData = fetchservice.fetchCoopData();

    String formatDateNow() {
      final now = DateTime.now();
      final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
      return formattedDate;
    }

    try {
      final formattedDate = formatDateNow();
      if (printerController.connected.value) {
        await printHeader();

        await printText("PREPAID RECEIPT", 1);
        await printLeftRight("DATE:", "$formattedDate");

        await printText("- - - - - - - - - - - - - - -", 1);

        await printLeftRight(
            "${coopData['coopType'].toString().toUpperCase()}#:",
            "${item['bus_no']}");

        await printLeftRight("ROUTE:", "${item['route']}");
        await printLeftRight('FROM:', '${item['from']}');
        await printLeftRight('TO:', '${item['to']}');
        await printLeftRight('PAX:', '${item['pax']}');
        await printLeftRight('PASSENGERS:', '');
        await printText("- - - - - - - - - - - - - - -", 1);
        for (var element in item['passengers']) {
          await printLeftRight(
              "  NAME:", "${element['fieldData']['nameOfPassenger']}");
          await printLeftRight("  SEAT#:", "${element['fieldData']['seatNo']}");
          await printLeftRight("  FARE#:", "${element['fieldData']['amount']}");
          await printText("- - - - - - - - - - - - - - -", 1);
        }

        await printLeftRight('TOTAL FARE', '${item['fare']}');
        await printLeftRight('BAGGAGE', '${item['baggage']}');

        await printLeftRight('TOTAL AMOUNT', '${item['total']}');
        await printText("- - - - - - - - - - - - - - -", 1);
        await printText("NOT AN OFFICIAL RECEIPT", 1);
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.cut();
      }

      return true;
    } catch (e) {
      print("prepaid error: $e");
      return false;
    }
  }
}
