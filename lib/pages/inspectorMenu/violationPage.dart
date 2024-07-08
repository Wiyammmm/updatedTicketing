import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/hiveServices/hiveServices.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:dltb/components/appbar.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/components/loadingModal.dart';
import 'package:dltb/pages/inspectorMenuPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ViolationPage extends StatefulWidget {
  const ViolationPage({super.key, required this.inspectorData});
  final inspectorData;
  @override
  State<ViolationPage> createState() => _ViolationPageState();
}

class _ViolationPageState extends State<ViolationPage> {
  final _myBox = Hive.box('myBox');
  Map<String, dynamic> inspectorData = {};
  fetchServices fetchservice = fetchServices();
  timeServices dateservice = timeServices();
  httprequestService httprequestServices = httprequestService();
  GeneratorServices generatorServices = GeneratorServices();
  LoadingModal loadingModal = LoadingModal();
  TestPrinttt printservice = TestPrinttt();
  HiveService hiveservice = HiveService();

  TextEditingController kmPostController = TextEditingController();
  TextEditingController onboardplaceController = TextEditingController();
  String? selectedOnboardPlace;
  String routeid = "";

  List<Map<String, dynamic>> torTrip = [];
  List<Map<String, dynamic>> stations = [];
  Map<String, dynamic> SESSION = {};
  TextEditingController employeeNameController = TextEditingController();
  Map<String, dynamic> coopData = {};
  final List<String> items = [
    'Passengers Overload',
    'OVER/UNDERCHARGING PASSENGER/BAGGAGE FARE',
    'DELAYING SUBMISSION OF COLLECTION',
    'SHORTENING DISTANCE FARE NOT YET COLLECTED',
    'DELAYED ISSUANCE OF TICKET',
    'SHORTENING DISTANCE FULL FARE PASSENGER',
    'ISSUING HALF FARE 70 FULL FARE COLLECTED',
    'ACT OF DEFRAUDING',
    'DRIVING EXPIRED LICENSE',
    'DISCOURTESY TO PASSENGERS',
    'DISCOURTESY TO SUPERIOR',
    'INSUBORDINATION',
    'NOT WEARING SHOES',
    'NOT/IMPROPER UNIFORM',
    'STOPPING BUS ON PROHIBITED/DANGEROUS ZONES',
    'SPEEDING',
    'DISREGARDING SAFETY TRAFFIC SIGNS',
    'OVERTAKING ON PROHIBITED ZONES',
    'FOLLOWING CLOSE',
    'OVERTAKING WITHOUT SUFFICIENT CLEARANCE',
    'OVER SPEEDING',
    'OTHER'
  ];
  List<Map<String, dynamic>> stationNames = [];
  List<Map<String, dynamic>> filteredStations = [];
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController otherViolationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    coopData = fetchservice.fetchCoopData();
    inspectorData = widget.inspectorData;
    torTrip = _myBox.get('torTrip');
    SESSION = _myBox.get('SESSION');
    stations = fetchservice.fetchStationList();
    routeid = SESSION['routeID'];
    filteredStations = stations
        .where((station) => station['routeId'].toString() == routeid)
        .toList();
    stationNames = filteredStations;
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    textEditingController.dispose();
    otherViolationController.dispose();
    super.dispose();
  }

  String findNearestStation(
      List<Map<String, dynamic>> thisstations, double targetKm) {
    if (thisstations.isEmpty) {
      return ''; // Handle the case where the list is empty
    }
    setState(() {
      selectedOnboardPlace = null;
    });

    List<Map<String, dynamic>> tempstationNames = [];

    // updateStationName(stations);
    // if (coopData['coopType'] != "Bus") {
    for (var station in thisstations) {
      double km = station['km']?.toDouble() ?? 0.0;
      // int numrow = station['rowNo'].toInt();

      if (targetKm.toDouble() == km) {
        tempstationNames.add(station);
      }
    }

    if (tempstationNames.isEmpty) {
      print('stationNames no stations');
      setState(() {
        stationNames = thisstations;
      });
    } else {
      setState(() {
        stationNames = tempstationNames;
        selectedOnboardPlace = "${tempstationNames[0]['stationName']}";
      });
    }
    print('stationNames filteredStations: $thisstations');
    print('tempstationNames: $tempstationNames');
    print('selectedOnboardPlace: $selectedOnboardPlace');

    // setState(() {
    //   // stationNames = stations.map((station) {
    //   //   return station['stationName']?.toString() ??
    //   //       ''; // Convert to string, handle null
    //   // }).toList();
    //   stationNames = stations;
    //   selectedStationName = null;
    // });
    return 'NO STATIONS'; // No stations found with the target km
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = dateservice.formatDateNow();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => InspectorMenuPage(
                      inspectorData: inspectorData,
                    )));
        return true;
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
                child: Column(
              children: [
                appbar(),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                      child: Text(
                    'VIOLATION REPORT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        if (!fetchservice.getIsNumeric())
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        topLeft: Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '* ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              'KM POST',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Center(
                                            child: TextField(
                                              controller: kmPostController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xff5f6062)),
                                              decoration: InputDecoration(
                                                  // contentPadding:
                                                  //     EdgeInsets.only(bottom: 10),
                                                  hintText: 'Enter KM Post',
                                                  hintStyle: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      20)))),
                                              onChanged: (value) {
                                                try {
                                                  double thisvalue =
                                                      double.parse(value);

                                                  // selectedOnboardPlace = null;
                                                  findNearestStation(
                                                      filteredStations,
                                                      thisvalue);
                                                  print(
                                                      'selectedOnboardPlace: $selectedOnboardPlace');
                                                } catch (e) {
                                                  print('km post error: $e');

                                                  setState(() {
                                                    stationNames =
                                                        filteredStations;
                                                    selectedOnboardPlace = null;
                                                  });
                                                  print(
                                                      'km post error stationNames: $stationNames');
                                                  return;
                                                }
                                              },
                                            ),
                                          ),
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
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '* ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                'PLACE ON BOARD',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Text(
                                                  'Select Station',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                                items: stationNames
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item[
                                                                  'stationName']
                                                              as String,
                                                          child: Center(
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                item['stationName']
                                                                    as String,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 22,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                value: selectedOnboardPlace,
                                                onChanged: (String? value) {
                                                  final selectedStations =
                                                      stationNames
                                                          .where((station) =>
                                                              station[
                                                                  'stationName'] ==
                                                              value)
                                                          .toList();
                                                  final selectedStation =
                                                      selectedStations
                                                              .isNotEmpty
                                                          ? selectedStations[0]
                                                          : {};

                                                  setState(() {
                                                    selectedOnboardPlace =
                                                        value ?? '';
                                                    kmPostController.text =
                                                        "${fetchservice.convertNumToIntegerOrDecimal(selectedStation['km'])}";
                                                  });
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                  height: 40,
                                                  width: 200,
                                                ),
                                                dropdownStyleData:
                                                    const DropdownStyleData(
                                                        maxHeight: 200,
                                                        width: 300),
                                                menuItemStyleData:
                                                    const MenuItemStyleData(
                                                  height: 40,
                                                ),
                                                dropdownSearchData:
                                                    DropdownSearchData(
                                                  searchController:
                                                      onboardplaceController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 4,
                                                      right: 8,
                                                      left: 8,
                                                    ),
                                                    child: TextFormField(
                                                      expands: true,
                                                      maxLines: null,
                                                      controller:
                                                          onboardplaceController,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                        hintText:
                                                            'Search for an item...',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  searchMatchFn:
                                                      (item, searchValue) {
                                                    return item.value
                                                        .toString()
                                                        .toUpperCase()
                                                        .contains(searchValue
                                                            .toUpperCase());
                                                  },
                                                ),
                                                //This to clear the search value when you close the menu
                                                onMenuStateChange: (isOpen) {
                                                  if (!isOpen) {
                                                    onboardplaceController
                                                        .clear();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '* ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'EMPLOYEE NAME',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: TextField(
                                        controller: employeeNameController,
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Color(0xff5f6062)),
                                        decoration: InputDecoration(
                                            // contentPadding:
                                            //     EdgeInsets.only(bottom: 10),
                                            hintText: 'Enter Employee Name',
                                            hintStyle: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20)))),
                                        onChanged: (value) {
                                          try {
                                            double thisvalue =
                                                double.parse(value);

                                            // selectedOnboardPlace = null;
                                            findNearestStation(
                                                filteredStations, thisvalue);
                                            print(
                                                'selectedOnboardPlace: $selectedOnboardPlace');
                                          } catch (e) {
                                            print('km post error: $e');

                                            setState(() {
                                              stationNames = filteredStations;
                                              selectedOnboardPlace = null;
                                            });
                                            print(
                                                'km post error stationNames: $stationNames');
                                            return;
                                          }
                                        },
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
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '* ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'VIOLATION',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text(
                                        'Select Violation',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),

                                      items: items
                                          .map((item) => DropdownMenuItem(
                                                value: item,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    "$item",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      value: selectedValue,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedValue = value;
                                        });
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          height: 40,
                                          width: 200,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent)),
                                      dropdownStyleData:
                                          const DropdownStyleData(
                                              maxHeight: 200,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              )),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        height: 40,
                                      ),
                                      dropdownSearchData: DropdownSearchData(
                                        searchController: textEditingController,
                                        searchInnerWidgetHeight: 50,
                                        searchInnerWidget: Container(
                                          height: 50,
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 4,
                                            right: 8,
                                            left: 8,
                                          ),
                                          child: TextFormField(
                                            expands: true,
                                            maxLines: null,
                                            controller: textEditingController,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              hintText:
                                                  'Search for an violation...',
                                              hintStyle:
                                                  const TextStyle(fontSize: 12),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        searchMatchFn: (item, searchValue) {
                                          return item.value
                                              .toString()
                                              .toUpperCase()
                                              .contains(
                                                  searchValue.toUpperCase());
                                        },
                                      ),
                                      //This to clear the search value when you close the menu
                                      onMenuStateChange: (isOpen) {
                                        if (!isOpen) {
                                          textEditingController.clear();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selectedValue == "OTHER")
                          SizedBox(
                            height: 5,
                          ),
                        if (selectedValue == "OTHER")
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '* ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          'OTHER VIOLATION',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Center(
                                        child: TextField(
                                          controller: otherViolationController,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xff5f6062)),
                                          decoration: InputDecoration(
                                              // contentPadding:
                                              //     EdgeInsets.only(bottom: 10),
                                              hintText:
                                                  'Enter Specific Violation',
                                              hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20)))),
                                          onChanged: (value) {
                                            try {
                                              double thisvalue =
                                                  double.parse(value);

                                              // selectedOnboardPlace = null;
                                              findNearestStation(
                                                  filteredStations, thisvalue);
                                              print(
                                                  'selectedOnboardPlace: $selectedOnboardPlace');
                                            } catch (e) {
                                              print('km post error: $e');

                                              setState(() {
                                                stationNames = filteredStations;
                                                selectedOnboardPlace = null;
                                              });
                                              print(
                                                  'km post error stationNames: $stationNames');
                                              return;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InspectorMenuPage(
                                                  inspectorData: inspectorData,
                                                )));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors
                                        .primaryColor, // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
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
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!fetchservice.getIsNumeric()) {
                                      try {
                                        double kmpost =
                                            double.parse(kmPostController.text);
                                      } catch (e) {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.info,
                                                title: 'INCORRECT',
                                                text:
                                                    "PLEASE FILL KM POST PROPERLY"));
                                        return;
                                      }

                                      if (selectedOnboardPlace == null ||
                                          selectedOnboardPlace == "") {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.info,
                                                title: 'INCOMPLETE',
                                                text:
                                                    "PLEASE FILL PLACE ON BOARD"));
                                        return;
                                      }
                                    }
                                    if (employeeNameController.text == '') {
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.info,
                                              title: 'MISSING',
                                              text:
                                                  "PLEASE FILL EMPLOYEE NAME"));
                                      return;
                                    }
                                    if (selectedValue == null ||
                                        selectedValue == '') {
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.info,
                                              title: 'MISSING',
                                              text: "PLEASE SELECT VIOLATION"));
                                      return;
                                    }
                                    ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.question,
                                          title: "CONFIRM SUBMISSION",
                                          text:
                                              "Are you certain that you wish to submit?\nNote: This action cannot be undone.",
                                          denyButtonText: "NO",
                                          confirmButtonText: 'YES',
                                          onConfirm: () async {
                                            Navigator.of(context).pop();
                                            _addViolation();
                                          },
                                          onDeny: () {
                                            print('deny');

                                            Navigator.of(context).pop();
                                          }),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors
                                        .primaryColor, // Background color of the button
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Border radius
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'SUBMIT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ],
        )),
      ),
    );
  }

  void _addViolation() async {
    bool isOffline = false;
    bool isProceed = false;
    loadingModal.showProcessing(context);
    print('confirm');
    String uuid = generatorServices.generateUuid();
    String onboardTime = await dateservice.departedTime();
    String onboardPlace =
        stations[SESSION['currentStationIndex']]['stationName'];
    double onboard_km_post = 0;
    try {
      onboard_km_post = double.parse(kmPostController.text);
    } catch (e) {
      print(e);
    }

    Map<String, dynamic> item = {
      "coopId": "${coopData['_id']}",
      "UUID": "$uuid",
      "device_id": "${torTrip[SESSION['currentTripIndex']]['device_id']}",
      "control_no": "${torTrip[SESSION['currentTripIndex']]['control_no']}",
      "tor_no": "${torTrip[SESSION['currentTripIndex']]['tor_no']}",
      "date_of_trip": "${torTrip[SESSION['currentTripIndex']]['date_of_trip']}",
      "bus_no": "${torTrip[SESSION['currentTripIndex']]['bus_no']}",
      "route": "${torTrip[SESSION['currentTripIndex']]['route']}",
      "route_code": "${torTrip[SESSION['currentTripIndex']]['route_code']}",
      "bound": "${torTrip[SESSION['currentTripIndex']]['bound']}",
      "trip_no": torTrip[SESSION['currentTripIndex']]['trip_no'],
      "inspector_emp_no": "${inspectorData['empNo']}",
      "inspector_emp_name": "${inspectorData['idName']}",
      "onboard_time": "$onboardTime",
      "onboard_place": "${selectedOnboardPlace}",
      "onboard_km_post": onboard_km_post,
      "employee_name": "${employeeNameController.text}",
      "employee_violation":
          "${selectedValue == "OTHER" ? otherViolationController.text : selectedValue}",
      "timestamp": "$onboardTime",
      "lat": "14.076688",
      "long": "120.866036"
    };

    Map<String, dynamic> isAddedViolation =
        await httprequestServices.addViolation(item);

    if (isAddedViolation['messages'][0]['code'].toString() != '0') {
      Navigator.of(context).pop();

      await ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: 'OFFLINE',
              showCancelBtn: true,
              confirmButtonText: 'YES',
              cancelButtonText: 'NO',
              onConfirm: () {
                isProceed = true;
                isOffline = true;
                Navigator.of(context).pop();
              },
              onDeny: () {
                Navigator.of(context).pop();
                return;
              },
              onCancel: () {
                Navigator.of(context).pop();
                return;
              },
              text: "Do you want to use offline mode?"));
      // ArtSweetAlert.show(
      //     context: context,
      //     artDialogArgs: ArtDialogArgs(
      //         type: ArtSweetAlertType.info,
      //         title: 'ERROR',
      //         text:
      //             "${isAddedViolation['messages'][0]['message'].toString().toUpperCase()}"));
      // return;
    }
    if (isAddedViolation['messages'][0]['code'].toString() == '0') {
      isProceed = true;
    }
    if (!isProceed) {
      return;
    }
    if (isOffline) {
      bool isAddOfflineViolation = await hiveservice.addOfflineViolation(item);
      if (!isAddOfflineViolation) {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.info,
                title: 'ERROR',
                text: "SOMETHING WENT WRONG, PLEASE TRY AGAIN"));
        return;
      }
    } else {
      Navigator.of(context).pop();
    }
    double kmpost = 0;
    try {
      kmpost = double.parse(kmPostController.text);
    } catch (e) {
      print(e);
    }

    bool isprintdone = await printservice.printViolation(
        "${torTrip[SESSION['currentTripIndex']]['tor_no']}",
        "${torTrip[SESSION['currentTripIndex']]['route']}",
        "${torTrip[SESSION['currentTripIndex']]['date_of_trip']}",
        coopData['coopType'] != "Bus"
            ? "${torTrip[SESSION['currentTripIndex']]['bus_no']}:${torTrip[SESSION['currentTripIndex']]['plate_number']} "
            : "${torTrip[SESSION['currentTripIndex']]['bus_no']}",
        "${torTrip[SESSION['currentTripIndex']]['bound']}",
        "${inspectorData['idName']}",
        "${employeeNameController.text}",
        "${selectedValue == "OTHER" ? otherViolationController.text : selectedValue}",
        "${fetchservice.convertNumToIntegerOrDecimal(kmpost)}",
        "${selectedOnboardPlace}");
    if (isprintdone) {
      ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  title: 'SUCCESS',
                  text: "SUCCESFULLY SUBMITTED"))
          .then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViolationPage(inspectorData: widget.inspectorData)));
      });
    } else {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: 'SUCCESS',
              text:
                  "SUCCESSFULLY SUBMITTED BUT THERE IS SOMETHING WRONG IN THE PRINTER"));
    }
  }
}
