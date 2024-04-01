import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/checkcards/checkCards.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/nfcreader.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/dashboard.dart';
import 'package:dltb/pages/dispatchMenu/arrivalPage.dart';
import 'package:dltb/pages/dispatchMenu/specialArrivalPage.dart';
import 'package:dltb/pages/dispatcherPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SpecialTripPage extends StatefulWidget {
  const SpecialTripPage({super.key});

  @override
  State<SpecialTripPage> createState() => _SpecialTripPageState();
}

class _SpecialTripPageState extends State<SpecialTripPage> {
  final _myBox = Hive.box('myBox');

  TextEditingController passengerCountController = TextEditingController();
  TextEditingController passengerRevenueController = TextEditingController();
  fetchServices fetchService = fetchServices();
  NFCReaderBackend backend = NFCReaderBackend();
  checkCards isCardExisting = checkCards();
  timeServices timeservice = timeServices();
  List<Map<String, dynamic>> selectedRoute = [];
  dynamic torTrip = [];
  Map<String, dynamic> coopData = {};
  Map<dynamic, dynamic> SESSION = {};
  List<Map<String, dynamic>> routes = [];
  String vehicleNo = '';
  String driverName = '';
  String conductorName = '';
  bool isnfcOn = true;
  String route = "";
  String routeid = '';
  String formatDateNow() {
    final now = DateTime.now();
    final formattedDate = DateFormat("d MMM y, HH:mm").format(now);
    return formattedDate;
  }

  Map<String, dynamic> torDispatch = {};
  List<Map<String, dynamic>> employeeList = [];
  List<Map<String, dynamic>> getRouteById(
      List<Map<String, dynamic>> routeList, String id) {
    return routeList.where((route) => route['_id'].toString() == id).toList();
  }

  @override
  void initState() {
    super.initState();
    coopData = fetchService.fetchCoopData();
    torTrip = _myBox.get('torTrip');
    torDispatch = _myBox.get('torDispatch');
    employeeList = fetchService.fetchEmployeeList();
    SESSION = _myBox.get('SESSION');
    routes = fetchService.fetchRouteList();
    routeid = SESSION['routeID'];
    selectedRoute = getRouteById(routes, routeid);
    if (SESSION['isViceVersa']) {
      route =
          '${selectedRoute[0]['destination']} - ${selectedRoute[0]['origin']}';
    } else {
      route =
          '${selectedRoute[0]['origin']} - ${selectedRoute[0]['destination']}';
    }
    vehicleNo = torDispatch['vehicleNo'];
    final driverData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() == torDispatch['driverEmpNo'].toString(),
    );
    driverName =
        '${driverData['firstName']} ${driverData['middleName'] != "" ? "${driverData['middleName'][0]}." : ""} ${driverData['lastName']}';
    final conductorData = employeeList.firstWhere(
      (employee) =>
          employee['empNo'].toString() ==
          torDispatch['conductorEmpNo'].toString(),
    );
    conductorName =
        '${conductorData['firstName']} ${conductorData['middleName'] != "" ? "${conductorData['middleName'][0]}." : ""} ${conductorData['lastName']}';

    _startNFCReaderDashboard();
  }

  @override
  void dispose() {
    passengerCountController.dispose();
    passengerRevenueController.dispose();
    super.dispose();
  }

  void _startNFCReaderDashboard() async {
    if (!isnfcOn) {
      return;
    }
    try {
      final result =
          await backend.startNFCReader().timeout(Duration(seconds: 30));
      if (result != null) {
        final isCardExistingResult = isCardExisting.isCardExisting(result);
        if (isCardExistingResult != null) {
          String emptype = isCardExistingResult['designation'];
          if (emptype.toLowerCase().contains("dispatcher")) {
            int passengerCount = 0;
            double passengerRevenue = 0;
            try {
              passengerCount = int.parse(passengerCountController.text);
            } catch (e) {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "INVALID",
                      text: "INVALID PASSENGER COUNT VALUE"));
              return;
            }
            try {
              passengerRevenue = double.parse(passengerRevenueController.text);
            } catch (e) {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "INVALID",
                      text: "INVALID PASSENGER REVENUE VALUE"));
              return;
            }
            setState(() {
              isnfcOn = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SpecialArrivalPage(
                          dispatcherData: isCardExistingResult,
                          passengerCount: passengerCount,
                          passengerRevenue: passengerRevenue,
                        )));
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) =>
            //             DispatcherPage(dispatcherData: isCardExistingResult)));
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateNow();
    return WillPopScope(
        onWillPop: () async {
          // Handle the back button press here, or return false to prevent it
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _startNFCReaderDashboard();
          },
          child: Scaffold(
            body: SafeArea(
                child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                      opacity: 0.5, child: Image.asset("assets/citybg.png")),
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 20,
                    child: Column(
                      children: [
                        appbar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'DATE',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                              "${timeservice.dateofTrip2()}")),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColors.primaryColor),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'ROUTE',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                                "${route}")),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${coopData['coopType'].toString().toUpperCase()} NO',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                              "$vehicleNo")),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'TOR NO.',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                                "${torTrip.length > SESSION['currentTripIndex'] ? torTrip[SESSION['currentTripIndex']]['tor_no'] ?? "" : ""}")),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  'DRIVER',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '$driverName',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  'CONDUCTOR',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight: Radius
                                                                .circular(20),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '$conductorName',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Center(
                                                child: Text(
                                                  'PASSENGER COUNT',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    20))),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: TextFormField(
                                                        controller:
                                                            passengerCountController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            border: InputBorder
                                                                .none,
                                                            hintText: '****',
                                                            hintStyle: TextStyle(
                                                                color:
                                                                    Colors.grey[
                                                                        600])),
                                                      ),
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Center(
                                                child: Text(
                                                  'PASSENGER REVENUE',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: TextFormField(
                                                        controller:
                                                            passengerRevenueController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            border: InputBorder
                                                                .none,
                                                            hintText: '****',
                                                            hintStyle: TextStyle(
                                                                color:
                                                                    Colors.grey[
                                                                        600])),
                                                      ),
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'SPECIAL TRIP',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.07),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),
        ));
  }
}
