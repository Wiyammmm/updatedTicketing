import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/ticketingMenu/prepaidPage.dart';
import 'package:dltb/pages/ticketingMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, required this.bookingData});
  final Map<String, dynamic> bookingData;
  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _myBox = Hive.box('myBox');
  TestPrinttt printService = TestPrinttt();
  HiveService hiveServices = HiveService();
  LoadingModal loadingmodal = LoadingModal();
  Map<String, dynamic> bookingData = {};
  List<Map<String, dynamic>> torTrip = [];
  Map<dynamic, dynamic> sessionBox = {};
  TextEditingController baggageAmountController = TextEditingController();
  fetchServices fetchService = fetchServices();
  String travelDate = '';
  double totalAmount = 0;
  String ticketNo = '';

  String controlNo = '';
  Map<String, dynamic> coopData = {};
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    sessionBox = _myBox.get('SESSION');
    torTrip = _myBox.get('torTrip');
    controlNo = torTrip[sessionBox['currentTripIndex']]['control_no'];
    bookingData = widget.bookingData;
    DateTime date = DateFormat('MM/dd/yyyy')
        .parse(bookingData['response']['data'][0]['fieldData']['travelDate']);
    for (int i = 0; i < bookingData['response']['data'].length; i++) {
      totalAmount += bookingData['response']['data'][i]['fieldData']['amount'];
      print('booking data $i: ${bookingData['response']['data']}');
    }
    travelDate = DateFormat('MMMM d, yyyy').format(date);
    ticketNo = bookingData['response']['data'][0]['fieldData']['ticketNo'];
    print("bookingData checkin: $bookingData");
    print('data length: ${bookingData['response']['data'].length}');
  }

  @override
  void dispose() {
    baggageAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Opacity(opacity: 0.5, child: Image.asset("assets/citybg.png")),
          ),
          SingleChildScrollView(
              child: Column(
            children: [
              appbar(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Center(
                            child: Text(
                          'CHECK-IN MENU',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            border: Border.all(
                                color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('TOTAL AMOUNT:')),
                                      )),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            '₱${totalAmount.toStringAsFixed(2)}')),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Text('Ticket No:')),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('$ticketNo')),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('FROM:')),
                                      )),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            '${bookingData['response']['data'][0]['fieldData']['from']}')),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('TO:')),
                                      )),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            '${bookingData['response']['data'][0]['fieldData']['to']}')),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('BUS TYPE:')),
                                      )),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            '${bookingData['response']['data'][0]['fieldData']['busType']}')),
                                  )),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('TRAVEL DATE:')),
                                      )),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('$travelDate')),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: ListView.builder(
                              itemCount: bookingData['response']['data'].length,
                              itemBuilder: (context, index) {
                                var currentData = bookingData['response']
                                    ['data'][index]['fieldData'];
                                String name = currentData['nameOfPassenger'];
                                int seatNo = currentData['seatNo'];
                                double amount = double.parse(
                                    currentData['amount'].toString());
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text('NAME:')),
                                              Expanded(
                                                  child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text('$name')),
                                              )),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text('SEAT NO:')),
                                              Expanded(
                                                  child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text('$seatNo')),
                                              )),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text('AMOUNT:')),
                                              Expanded(
                                                  child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                        '₱${amount.toStringAsFixed(2)}')),
                                              )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })),
                      SizedBox(
                        height: 10,
                      ),
                      // Container(
                      //     width: MediaQuery.of(context).size.width,
                      //     decoration: BoxDecoration(
                      //         color: AppColors.secondaryColor,
                      //         border: Border.all(
                      //             width: 2, color: AppColors.primaryColor),
                      //         borderRadius: BorderRadius.circular(10)),
                      //     child: TextField(
                      //       controller: baggageAmountController,
                      //       textAlign: TextAlign.center,
                      //       keyboardType: TextInputType.number,
                      //       decoration: InputDecoration(
                      //           border: InputBorder.none,
                      //           hintText: "INPUT BAGGAGE AMOUNT",
                      //           labelText: 'PREPAID BAGGAGE',
                      //           floatingLabelAlignment:
                      //               FloatingLabelAlignment.center,
                      //           labelStyle: TextStyle(color: Colors.grey[600])),
                      //     )),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PrepaidPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .primaryColor, // Background color of the button

                                padding: EdgeInsets.symmetric(horizontal: 24.0),

                                shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(width: 1, color: Colors.black),

                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'BACK',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final stationList = _myBox.get('stationList');

                                bool ischeckStationExist1 = stationList.any(
                                    (station) => station['stationName']
                                        .toString()
                                        .contains(bookingData['response']
                                                ['data'][0]['fieldData']['from']
                                            .toString()));
                                bool ischeckStationExist2 = stationList.any(
                                    (station) => station['stationName']
                                        .toString()
                                        .contains(bookingData['response']
                                                ['data'][0]['fieldData']['to']
                                            .toString()));

                                if (!ischeckStationExist1 ||
                                    !ischeckStationExist2) {
                                  ArtDialogResponse noStationAlert =
                                      await ArtSweetAlert.show(
                                          context: context,
                                          barrierDismissible: false,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.warning,
                                              title: "ERROR",
                                              showCancelBtn: true,
                                              confirmButtonText: "YES",
                                              confirmButtonColor:
                                                  Color(0xFF00adee),
                                              text:
                                                  "THERE IS NO AREAS/STATION MATCHED IN THIS TRIP\nWOULD YOU LIKE TO CONTINUE?"));
                                  if (noStationAlert == null) {
                                    return;
                                  }
                                  if (noStationAlert.isTapCancelButton) {
                                    return;
                                  }
                                }
                                loadingmodal.showProcessing(context);
                                // bool isCheckin = true;
                                bool isCheckin =
                                    await hiveServices.addPrepaidTicket({
                                  "ticketNo": "$ticketNo",
                                  "totalAmount": totalAmount,
                                  "totalPassenger":
                                      bookingData['response']['data'].length,
                                  "control_no": controlNo,
                                  "from": bookingData['response']['data'][0]
                                      ['fieldData']['from'],
                                  "to": bookingData['response']['data'][0]
                                      ['fieldData']['to'],
                                  "data": bookingData['response']['data'],
                                });
                                if (baggageAmountController.text.trim() != "") {
                                  bool isAddPrepaidBaggage =
                                      await hiveServices.addPrepaidBaggage({
                                    "ticketNo": "$ticketNo",
                                    "totalAmount": double.parse(
                                        baggageAmountController.text),
                                    "control_no": controlNo,
                                    "from": bookingData['response']['data'][0]
                                        ['fieldData']['from'],
                                    "to": bookingData['response']['data'][0]
                                        ['fieldData']['to'],
                                  });
                                  if (!isAddPrepaidBaggage) {
                                    Navigator.of(context).pop();
                                    ArtSweetAlert.show(
                                        context: context,
                                        artDialogArgs: ArtDialogArgs(
                                            type: ArtSweetAlertType.danger,
                                            title: "ERROR",
                                            text:
                                                "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
                                  }
                                }
                                if (isCheckin) {
                                  double baggagePrice = 0;
                                  try {
                                    baggagePrice = double.parse(
                                        baggageAmountController.text);
                                  } catch (e) {}
                                  Navigator.of(context).pop();
                                  bool isprintPrepaid =
                                      await printService.printPrepaid({
                                    "route":
                                        "${torTrip[sessionBox['currentTripIndex']]['route']}",
                                    "bus_no": coopData['coopType'] == "Jeepney"
                                        ? "${torTrip[sessionBox['currentTripIndex']]['bus_no']}:${torTrip[sessionBox['currentTripIndex']]['plate_number']} "
                                        : "${torTrip[sessionBox['currentTripIndex']]['bus_no']}",
                                    "from":
                                        "${bookingData['response']['data'][0]['fieldData']['from']}",
                                    "to":
                                        "${bookingData['response']['data'][0]['fieldData']['to']}",
                                    "pax":
                                        bookingData['response']['data'].length,
                                    "passengers": bookingData['response']
                                        ['data'],
                                    "fare": totalAmount.toStringAsFixed(2),
                                    "baggage": baggagePrice.toStringAsFixed(2),
                                    "total": double.parse(
                                            (totalAmount + baggagePrice)
                                                .toString())
                                        .toStringAsFixed(2),
                                  });
                                  ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.success,
                                              title: "SUCCESS",
                                              text: "SUCCESSFULLY CHECK IN"))
                                      .then((alertresult) {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TicketingMenuPage()));
                                  });
                                } else {
                                  Navigator.of(context).pop();
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          title: "ERROR",
                                          text:
                                              "SOMETHING WENT WRONG, PLEASE TRY AGAIN LATER"));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .primaryColor, // Background color of the button

                                padding: EdgeInsets.symmetric(horizontal: 24.0),

                                shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(width: 1, color: Colors.black),

                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'CHECK-IN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
        ],
      )),
    );
  }
}
