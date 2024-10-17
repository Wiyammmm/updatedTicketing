import 'dart:convert';

import 'package:dltb/backend/deviceinfo/getDeviceInfo.dart';
import 'package:dltb/backend/fetch/fetchAllData.dart';
import 'package:dltb/backend/fetch/httprequest.dart';
import 'package:dltb/backend/service/generator.dart';
import 'package:dltb/backend/service/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

class HiveService {
  fetchServices fetchService = fetchServices();
  httprequestService httpRequestServices = httprequestService();
  GeneratorServices generatorService = GeneratorServices();
  timeServices dateService = timeServices();
  DeviceInfoService DeviceInfo = DeviceInfoService();
  final _myBox = Hive.box('myBox');

  Future<bool> addTrip(Map<String, dynamic> items) async {
    // try {
    final storedListOfMaps = _myBox.get('torTrip');

    print('torTrip: $storedListOfMaps');
    String uuid = generatorService.generateUuid();
    final torMain = _myBox.get('torMain');
    final SESSION = _myBox.get('SESSION');
    final torDispatch = _myBox.get('torDispatch');

    int indexToUpdate = torMain.isEmpty
        ? -1
        : torMain.indexWhere((map) => map['tor_no'] == items['tor_no']);
    print('indexToUpdate: $indexToUpdate');
    final bodyTorMain = {
      "coopId": "${items['coopId']}",
      "UUID": "$uuid",
      "device_id": "${items['device_id']}",
      "control_no": "${torDispatch['control_no']}",
      "tor_no": "${items['tor_no']}",
      "date_of_trip": "${items['date_of_trip']}",
      "bus_no": "${items['bus_no']}",
      "route": "${items['route']}",
      "bound": "${items['bound']}",
      "route_code": "${items['route_code']}",
      "emp_no_driver_1": "${items['driver_id']}",
      "emp_no_driver_2": "",
      "emp_no_conductor": "${items['conductor_id']}",
      "emp_name_driver_1": "${items['driver']}",
      "emp_name_driver_2": "",
      "emp_name_conductor": "${items['conductor']}",
      "eskirol_id_driver": "",
      "eskirol_id_conductor": "",
      "eskirol_name_driver": "",
      "eskirol_name_conductor": "",
      "no_of_trips": 1,
      "ticket_revenue_atm": 0,
      "ticket_count_atm": 0,
      "ticket_revenue_atm_passenger": 0,
      "ticket_revenue_atm_baggage": 0,
      "ticket_count_atm_passenger": 0,
      "ticket_count_atm_baggage": 0,
      "ticket_revenue_punch": 0,
      "ticket_count_punch": 0,
      "ticket_revenue_punch_passenger": 0,
      "ticket_revenue_punch_baggage": 0,
      "ticket_count_punch_passenger": 0,
      "ticket_count_punch_baggage": 0,
      "ticket_revenue_charter": 0,
      "ticket_count_charter": 0,
      "ticket_revenue_waybill": 0,
      "ticket_count_waybill": 0,
      "ticket_amount_cancelled": 0.0,
      "ticket_count_cancelled": 0.0,
      "ticket_revenue_reserved": 0.0,
      "ticket_count_reserved": 0,
      "ticket_amount_passes": "",
      "ticket_count_passes": "",
      "ticket_revenue_card": 0.0,
      "ticket_count_card": 0,
      "passenger_revenue": 0.0,
      "baggage_revenue": 0.0,
      "gross_revenue": 0.0,
      "passenger_count": 0.0,
      "baggage_count": 0,
      "commission_driver1_passenger": "",
      "auto_commission_driver1_passenger": 0,
      "commission_driver1_baggage": "",
      "auto_commission_driver1_baggage": 0,
      "commission_driver1": 0,
      "auto_commission_driver1": 0,
      "commission_driver2_passenger": "",
      "auto_commission_driver2_passenger": 0.0,
      "commission_driver2_baggage": "",
      "auto_commission_driver2_baggage": 0.0,
      "commission_driver2": 0.0,
      "auto_commission_driver2": "",
      "commission_conductor_passenger": "",
      "auto_commission_conductor_passenger": 0,
      "commission_conductor_baggage": "",
      "auto_commission_conductor_baggage": 0,
      "commission_conductor": 0,
      "auto_commission_conductor": 0,
      "incentive_driver1": 0,
      "incentive_driver2": 0.0,
      "incentive_conductor": 0.0,
      "allowance_driver1": 0.0,
      "allowance_driver2": 0.0,
      "allowance_conductor": 0.0,
      "eskirol_commission_driver": 0,
      "eskirol_commission_conductor": 0,
      "eskirol_cash_bond_driver": 0,
      "eskirol_cash_bond_conductor": 0,
      "toll_fees": 0.0,
      "parking_fee": 0.0,
      "diesel": 0.0,
      "diesel_no_of_liters": 0,
      "others": 0.0,
      "services": 0.0,
      "callers_fee": 0.0,
      "employee_benefits": 0.0,
      "repair_maintenance": 0.0,
      "materials": 0.0,
      "representation": 0.0,
      "total_expenses": 0.0,
      "temp_net_collections": 0.0,
      "net_collections": 0.0,
      "total_cash_remitted": 0.0,
      "final_remittance": 0.0,
      "final_cash_remitted": 0.0,
      "overage_shortage": 0.0,
      "tellers_id": "",
      "tellers_name": "",
      "coding": "NO",
      "cardSales": 0,
      "cashReceived": 0,
      "remarks": "live",
      "total_top_up": 0
    };

    if (indexToUpdate != -1) {
      torMain[indexToUpdate]['no_of_trips'] += 1;
      try {
        Map<String, dynamic> isUpdateTorMain =
            await httpRequestServices.updateTorMain(torMain[indexToUpdate]);
        if (isUpdateTorMain['messages']['code'].toString() == '0') {
          storedListOfMaps.add(items);

          _myBox.put('torTrip', storedListOfMaps);
          torMain.add(torMain[indexToUpdate]);
          _myBox.put('torMain', torMain);
          final newtormain = _myBox.get('torMain');
          for (var element in newtormain) {
            print('newtormain: $element');
          }
          return true;
        } else {
          SESSION['isAlreadyInsertTrip'] = true;
          print('isAlreadyInsertTrip: ${SESSION['isAlreadyInsertTrip']}');
          _myBox.put('SESSION', SESSION);

          if (isUpdateTorMain['messages']['code'].toString() == '500') {
            final offlineUpdateTorMain = _myBox.get('offlineUpdateTorMain');
            offlineUpdateTorMain.add(torMain[indexToUpdate]);
            storedListOfMaps.add(items);
            _myBox.put('torTrip', storedListOfMaps);
            torMain.add(torMain[indexToUpdate]);
            _myBox.put('torMain', torMain);
            _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);
            return true;
          } else {
            return false;
          }
        }
      } catch (e) {
        print("error isUpdateTorMain: $e");
        storedListOfMaps.add(items);
        _myBox.put('torTrip', storedListOfMaps);
        torMain.add(torMain[indexToUpdate]);
        _myBox.put('torMain', torMain);
        _myBox.put('offlineUpdateTorMain', torMain[indexToUpdate]);
        return true;
      }
    } else {
      // try {
      Map<String, dynamic> isAddTorMain =
          await httpRequestServices.addTorMain(bodyTorMain);
      if (isAddTorMain['messages'][0]['code'].toString() == '0') {
        storedListOfMaps.add(items);
        _myBox.put('torTrip', storedListOfMaps);
        torMain.add(bodyTorMain);
        _myBox.put('torMain', torMain);
        final newtormain = _myBox.get('torMain');
        for (var element in newtormain) {
          print('newtormain: $element');
        }
        return true;
      } else {
        SESSION['isAlreadyInsertTrip'] = true;
        print('isAlreadyInsertTrip: ${SESSION['isAlreadyInsertTrip']}');
        _myBox.put('SESSION', SESSION);
        if (isAddTorMain['messages'][0]['code'].toString() == '500') {
          final offlineAddTorMain = _myBox.get('offlineAddTorMain');
          offlineAddTorMain.add(bodyTorMain);
          storedListOfMaps.add(items);
          _myBox.put('torTrip', storedListOfMaps);
          torMain.add(bodyTorMain);
          _myBox.put('torMain', torMain);
          _myBox.put('offlineAddTorMain', offlineAddTorMain);
          return true;
        } else {
          return false;
        }
      }
      // } catch (e) {
      //   print("error isAddTorMain: $e");
      //   final offlineAddTorMain = _myBox.get('offlineAddTorMain');
      //   offlineAddTorMain.add(bodyTorMain);
      //   storedListOfMaps.add(items);
      //   _myBox.put('torTrip', storedListOfMaps);
      //   torMain.add(bodyTorMain);
      //   _myBox.put('torMain', torMain);

      //   _myBox.put('offlineAddTorMain', bodyTorMain);
      //   return true;
      // }
    }

    // print('departure_lat: ${storedData['departure_lat']}');
    // print('departure_long: ${storedData['departure_long']}');
    // print('tor serial number: ${storedData['device_id']}');
    // } catch (e) {
    //   print('error addTrip: $e');
    //   return false;
    // }
  }

  Future<bool> addTicket(Map<String, dynamic> items) async {
    try {
      final storedListOfMaps = _myBox.get('torTicket');

      storedListOfMaps.add(items);
      _myBox.put('torTicket', storedListOfMaps);

      print('torTicket: $storedListOfMaps');
      print('added data in ticketpage: ${items}');
      // print('departure_lat: ${storedData['departure_lat']}');
      // print('departure_long: ${storedData['departure_long']}');
      // print('tor serial number: ${storedData['device_id']}');
      return true;
    } catch (e) {
      print('error addTicket in ticketpage: $e');
      return false;
    }
  }

  Future<bool> addPrepaidTicket(Map<String, dynamic> items) async {
    try {
      final prepaidTicket = _myBox.get('prepaidTicket');
      print("addPrepaidTicket items data: ${items['data']}");
      for (var entry in items['data']) {
        String recordId = entry['recordId'].toString();
        print('addPrepaidTicket recordId: $recordId');
        bool ischeckinUpdate =
            await httpRequestServices.checkInUpdate(recordId);
        if (!ischeckinUpdate) {
          return false;
        }
      }

      prepaidTicket.add(items);
      _myBox.put('prepaidTicket', prepaidTicket);
      print('addPrepaidTicket: $prepaidTicket');

      return true;
    } catch (e) {
      print("error addPrepaidTicket: $e");
      return false;
    }
  }

  Future<bool> addPrepaidBaggage(Map<String, dynamic> items) async {
    try {
      final prepaidBaggage = _myBox.get('prepaidBaggage');
      prepaidBaggage.add(items);
      _myBox.put('prepaidBaggage', prepaidBaggage);
      print('prepaidBaggage: $prepaidBaggage');

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addDispatch(Map<String, dynamic> items) async {
    try {
      _myBox.put('torDispatch', items);
      final storedData = _myBox.get('torDispatch');
      print('torDispatch: $storedData');
      return true;
    } catch (e) {
      print('error addDispatch: $e');
      return false;
    }
  }

  Future<bool> updateTripType(String tripType) async {
    try {
      final storedData = _myBox.get('SESSION');
      storedData['tripType'] = tripType;
      _myBox.put('SESSION', storedData);
      final newstoredData = _myBox.get('SESSION');
      print('newstoredData: $newstoredData');

      return true;
    } catch (e) {
      print('error updateTripType: $e');
      return false;
    }
  }

  Future<bool> updateArrived() async {
    try {
      final SESSION = _myBox.get('SESSION');
      final storedData = _myBox.get('torTrip');
      final torDispatch = _myBox.get('torDispatch');
      final employeeList = fetchService.fetchEmployeeList();
      final conductorData = employeeList.firstWhere(
        (employee) => employee['empNo'] == torDispatch['conductorEmpNo'],
      );
      final conductorName =
          '${conductorData['firstName']} ${conductorData['middleName'][0]}. ${conductorData['lastName']}';
      String arrivedTime = await dateService.departedTime();
      String arrivedTimeStamp = await dateService.departureTimestamp();
      // Position position = await DeviceInfo.determinePosition();

      storedData[SESSION['currentTripIndex']]['arrived_dispatcher_id'] =
          torDispatch['conductorEmpNo'];
      storedData[SESSION['currentTripIndex']]['arrived_dispatcher'] =
          'DISPATCHER, $conductorName';
      storedData[SESSION['currentTripIndex']]['arrived_time'] = arrivedTime;
      storedData[SESSION['currentTripIndex']]['arrival_timestamp'] =
          arrivedTimeStamp;
      final myLocation = _myBox.get('myLocation');
      String latitude = '${myLocation['latitude'] ?? 0.00}';
      String longitude = '${myLocation['longitude'] ?? 0.00}';
      storedData[SESSION['currentTripIndex']]['arrival_lat'] = latitude;
      storedData[SESSION['currentTripIndex']]['arrival_long'] = longitude;
      // storedData[SESSION['currentTripIndex']]['arrival_lat'] =
      //     position.latitude;
      // storedData[SESSION['currentTripIndex']]['arrival_long'] =
      //     position.longitude;

      _myBox.put('torTrip', storedData);
      return true;
    } catch (e) {
      print('error updateArrived: $updateArrived');
      return false;
    }
  }

  Future<bool> updateClosing(bool isclose) async {
    try {
      final storedData = _myBox.get('SESSION');
      storedData['isClosed'] = isclose;
      _myBox.put('SESSION', storedData);
      final newstoredData = _myBox.get('SESSION');

      print('newstoredData: $newstoredData');
      return true;
    } catch (e) {
      print('error updateClosing: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> getFilteredStations(
      List<Map<String, dynamic>> stationList) {
    final sessionbox = _myBox.get('SESSION');
    String routeid = sessionbox['routeID'];
    // List<Map<String, dynamic>> filteredStations = stationList
    //     .where((station) => station['routeId'].toString() == routeid)
    //     .toList();

    // // // Sort the filtered stations based on the 'km' field
    // filteredStations.sort((a, b) {
    //   int kmA = a['km'] ?? 0;
    //   int kmB = b['km'] ?? 0;
    //   return kmA.compareTo(kmB);
    // });
    List<Map<String, dynamic>> filteredStations = stationList
        .where((station) => station['routeId'].toString() == routeid)
        .toList();

    filteredStations.sort((a, b) {
      int rowNoA = a['rowNo'] ?? 0;
      int rowNoB = b['rowNo'] ?? 0;
      return rowNoA.compareTo(rowNoB);
    });
    // Sort the filtered stations based on the 'createdAt' field
    // filteredStations.sort((a, b) {
    //   String createdAtA = a['createdAt'] ?? '';
    //   String createdAtB = b['createdAt'] ?? '';
    //   // Convert createdAt strings to DateTime for comparison
    //   DateTime dateTimeA = DateTime.tryParse(createdAtA) ?? DateTime(0);
    //   DateTime dateTimeB = DateTime.tryParse(createdAtB) ?? DateTime(0);
    //   return dateTimeA.compareTo(dateTimeB);
    // });

    return filteredStations;
  }

  Future<Map<String, dynamic>> updateCurrentTripIndex(
      Map<String, dynamic> dispatcherData) async {
    Map<String, dynamic> updateTripResponse = {
      "messages": {
        "code": 500,
        "message": "SOMETHING WENT WRONG",
      },
      "response": {}
    };
    // try {
    String arrivedTime = await dateService.departedTime();
    String arrivedTimeStamp = await dateService.departureTimestamp();

    final storedData = _myBox.get('SESSION');
    final torTrip = _myBox.get('torTrip');
    final torTicket = _myBox.get('torTicket');
    final stations = getFilteredStations(fetchService.fetchStationList());
    final routes = _myBox.get('routeList');
    final selectedRoute =
        getRouteById(routes, storedData['routeID'].toString());
    String control_no =
        torTrip[storedData['currentTripIndex']]['control_no'].toString();

    torTrip[storedData['currentTripIndex']]['arrived_dispatcher_id'] =
        dispatcherData['empNo'];

    torTrip[storedData['currentTripIndex']]['arrived_dispatcher'] =
        '${dispatcherData['firstName']} ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}';
    final myLocation = _myBox.get('myLocation');
    String latitude = '${myLocation?['latitude'] ?? "0.00"}';
    String longitude = '${myLocation?['longitude'] ?? "0.00"}';
    torTrip[storedData['currentTripIndex']]['arrived_place'] =
        "${stations[stations.length - 1]['code']}";
    torTrip[storedData['currentTripIndex']]['arrival_lat'] = latitude;
    torTrip[storedData['currentTripIndex']]['arrival_long'] = longitude;
    torTrip[storedData['currentTripIndex']]['arrived_time'] = arrivedTime;
    torTrip[storedData['currentTripIndex']]['arrival_timestamp'] =
        arrivedTimeStamp;

    double net_collection = 0;

    final expenses = _myBox.get('expenses');
    double totalExpenses = expenses
        .where((item) => item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalDiesel = expenses
        .where((item) =>
            item['particular'] == "Fuel" && item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalToll = expenses
        .where((item) =>
            item['particular'] == "TOLL" && item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalParking = expenses
        .where((item) =>
            item['particular'] == "PARKING" && item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalServices = expenses
        .where((item) =>
            item['particular'] == "SERVICES" &&
            item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalRepair = expenses
        .where((item) =>
            item['particular'] == "REPAIR" && item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalCallersFee = expenses
        .where((item) =>
            item['particular'] == "CALLER'S FEE" &&
            item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalEmployeeBenefits = expenses
        .where((item) =>
            item['particular'] == "EMPLOYEE BENEFITS" &&
            item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalMaterials = expenses
        .where((item) =>
            item['particular'] == "MATERIALS" &&
            item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();

    double totalRepresentation = expenses
        .where((item) =>
            item['particular'] == "REPRESENTATION" &&
            item['control_no'] == control_no)
        .map((item) => (item['amount'] ?? 0.0) as num)
        .fold(0.0, (prev, amount) => prev + amount)
        .toDouble();
    double totalOthers = totalServices +
        totalCallersFee +
        totalEmployeeBenefits +
        totalRepair +
        totalMaterials +
        totalRepresentation;

    final torMain = _myBox.get('torMain');
    int indexToUpdate = torMain.indexWhere((map) =>
        map['tor_no'] == torTrip[storedData['currentTripIndex']]['tor_no']);
    if (torTicket.isNotEmpty) {
      torTrip[storedData['currentTripIndex']]['from_km'] = stations[0]['km'];

      torTrip[storedData['currentTripIndex']]['to_km'] =
          stations[stations.length - 1]['km'];
      torTrip[storedData['currentTripIndex']]['km_run'] =
          ((stations[0]['km'] ?? 0) -
                  (stations[stations.length - 1]['km'] ?? 0))
              .abs();
      // double baggageCount = torTicket
      //     .where((ticket) => ticket['control_no'] == control_no)
      //     .fold(0.0,
      //         (sum, ticket) => sum + (ticket['baggage'] as num).toDouble());
      // double totalAmount = torTicket
      //     .where((ticket) => ticket['control_no'] == control_no)
      //     .fold(
      //         0.0, (sum, ticket) => sum + (ticket['fare'] as num).toDouble());
      // double grandTotal = totalAmount + baggageCount;
      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'] =
          fetchService.totalTripTicketRevenue();

      int totalTickets = torTicket
          .where((ticket) => ticket['control_no'] == control_no)
          .length;
      torTrip[storedData['currentTripIndex']]['ticket_count_atm'] =
          totalTickets;
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

      double tickerRevenuePassenger = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['cardType'] == 'mastercard' ||
                  ticket['cardType'] == 'cash'))
          .fold(
              0.0,
              (sum, ticket) =>
                  sum +
                  (((ticket['fare'] ?? 0.0) as num).toDouble() *
                      ticket['pax']));

      double totalAdditionalFareCash() {
        double total = 0;

        for (var element in torTicket) {
          if (element['control_no'] == control_no &&
              (element['additionalFareCardType'] == "mastercard" ||
                  element['additionalFareCardType'] == "cash")) {
            total += element['additionalFare'];
          }
        }
        return total;
      }

      double totalAdditionalFareCard() {
        double total = 0;

        for (var element in torTicket) {
          if (element['control_no'] == control_no &&
              (element['additionalFareCardType'] != "mastercard" &&
                  element['additionalFareCardType'] != "cash")) {
            total += element['additionalFare'];
          }
        }
        return total;
      }

      double totalPrepaidPassengerRevenue() {
        double total = 0;
        final prePaidList = _myBox.get('prepaidTicket');
        for (var element in prePaidList) {
          if (element['control_no'] == control_no) {
            total += element['totalAmount'];
          }
        }

        return total;
      }

      double totalPrepaidBaggageRevenue() {
        double total = 0;
        final prePaidList = _myBox.get('prepaidBaggage');
        for (var element in prePaidList) {
          if (element['control_no'] == control_no) {
            total += element['totalAmount'];
          }
        }

        return total;
      }

      double totalPrepaidPassengerCount() {
        double total = 0;
        final prePaidList = _myBox.get('prepaidTicket');
        for (var element in prePaidList) {
          if (element['control_no'] == control_no) {
            total++;
          }
        }

        return total;
      }

      double totalPrepaidBaggageCount() {
        double total = 0;
        final prePaidList = _myBox.get('prepaidBaggage');
        for (var element in prePaidList) {
          if (element['control_no'] == control_no) {
            total++;
          }
        }

        return total;
      }

      double totalPrepaidCount() {
        double total = 0;
        final prePaidList = _myBox.get('prepaidTicket');
        for (var element in prePaidList) {
          if (element['control_no'] == control_no) {
            total++;
          }
        }
        return total;
      }

      tickerRevenuePassenger += totalAdditionalFareCash();
      double ticketRevenueCardPassenger = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['cardType'] != 'mastercard' &&
                  ticket['cardType'] != 'cash'))
          .fold(
              0.0,
              (sum, ticket) =>
                  sum +
                  (((ticket['fare'] ?? 0.0) as num).toDouble() *
                      ticket['pax']));

      double ticketRevenueCardBaggage = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['cardType'] != 'mastercard' &&
                  ticket['cardType'] != 'cash'))
          .fold(
              0.0,
              (sum, ticket) =>
                  sum + ((ticket['baggage'] ?? 0.0) as num).toDouble());

      ticketRevenueCardPassenger += totalAdditionalFareCard();
      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm_passenger'] =
          fetchService.totalTripFare();
      torTrip[storedData['currentTripIndex']]['ticket_revenue_card'] =
          ticketRevenueCardPassenger + ticketRevenueCardBaggage;
      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm_baggage'] =
          fetchService.totalBaggageperTrip();
      // int ticket_count_atm_passenger = torTicket
      //     .where((ticket) =>
      //         ticket['control_no'] == control_no && ticket['fare'] > 0)
      //     .length;
      torTrip[storedData['currentTripIndex']]['ticket_count_atm_passenger'] =
          fetchService.fetchPassengerCountATM();

      torTrip[storedData['currentTripIndex']]['ticket_count_card'] =
          fetchService.cardSalesCount();
      // int ticket_count_atm_baggage = torTicket
      //     .where((ticket) =>
      //         ticket['control_no'] == control_no && ticket['baggage'] > 0)
      //     .length;
      torTrip[storedData['currentTripIndex']]['ticket_count_atm_baggage'] =
          fetchService.baggageCount();

      torTrip[storedData['currentTripIndex']]['cashReceived'] =
          tickerRevenuePassenger +
              fetchService.totalCashReceivedBaggageperTrip() +
              getTotalTopUpperTrip();
      torTrip[storedData['currentTripIndex']]['cardSales'] =
          ticketRevenueCardPassenger +
              fetchService.totalCardSalesBaggageperTrip();

      torTrip[storedData['currentTripIndex']]['total_top_up'] =
          getTotalTopUpperTrip();
      torTrip[storedData['currentTripIndex']]['passenger_revenue'] =
          tickerRevenuePassenger +
              ticketRevenueCardPassenger +
              totalPrepaidPassengerRevenue();
      torTrip[storedData['currentTripIndex']]['baggage_revenue'] =
          fetchService.totalBaggageperTrip() + totalPrepaidBaggageRevenue();

      torTrip[storedData['currentTripIndex']]['passenger_count'] =
          fetchService.fetchAllPassengerCount();
      torTrip[storedData['currentTripIndex']]['baggage_count'] =
          fetchService.baggageCount() + totalPrepaidBaggageCount();

      torTrip[storedData['currentTripIndex']]['ticket_revenue_reserved'] =
          totalPrepaidPassengerRevenue() + totalPrepaidBaggageRevenue();

      torTrip[storedData['currentTripIndex']]['ticket_count_reserved'] =
          totalPrepaidCount();

      net_collection = (tickerRevenuePassenger +
              ticketRevenueCardPassenger +
              fetchService.totalBaggageperTrip() +
              getTotalTopUpperTrip() +
              totalPrepaidPassengerRevenue() +
              totalPrepaidBaggageRevenue()) -
          totalExpenses;

      torTrip[storedData['currentTripIndex']]['gross_revenue'] =
          tickerRevenuePassenger +
              ticketRevenueCardPassenger +
              fetchService.totalBaggageperTrip() +
              getTotalTopUpperTrip() +
              totalPrepaidPassengerRevenue() +
              totalPrepaidBaggageRevenue();

      // update tormain hive

      torMain[indexToUpdate]['ticket_revenue_reserved'] +=
          totalPrepaidPassengerRevenue() + totalPrepaidBaggageRevenue();

      torMain[indexToUpdate]['ticket_count_reserved'] += totalPrepaidCount();

      torMain[indexToUpdate]['ticket_revenue_atm_passenger'] +=
          fetchService.totalTripFare();

      torMain[indexToUpdate]['ticket_revenue_atm_baggage'] +=
          fetchService.totalBaggageperTrip();
      torMain[indexToUpdate]['ticket_count_atm_passenger'] +=
          fetchService.fetchPassengerCountATM();

      torMain[indexToUpdate]['ticket_count_atm_baggage'] +=
          fetchService.baggageCount();

      torMain[indexToUpdate]['passenger_count'] +=
          fetchService.fetchAllPassengerCount();

      torMain[indexToUpdate]['baggage_count'] +=
          fetchService.baggageCount() + totalPrepaidBaggageCount();

      torMain[indexToUpdate]['passenger_revenue'] += tickerRevenuePassenger +
          ticketRevenueCardPassenger +
          totalPrepaidPassengerRevenue();
      torMain[indexToUpdate]['baggage_revenue'] +=
          fetchService.totalBaggageperTrip() + totalPrepaidBaggageRevenue();
      torMain[indexToUpdate]['ticket_revenue_atm'] +=
          fetchService.totalTripTicketRevenue();
      torMain[indexToUpdate]['ticket_count_atm'] += totalTickets;
      torMain[indexToUpdate]['ticket_count_card'] +=
          fetchService.cardSalesCount();
      torMain[indexToUpdate]['ticket_revenue_card'] +=
          ticketRevenueCardPassenger + ticketRevenueCardBaggage;
      torMain[indexToUpdate]['toll_fees'] += totalToll;
      torMain[indexToUpdate]['diesel'] += totalDiesel;
      torMain[indexToUpdate]['diesel_no_of_liters'] +=
          fetchService.getFuelLitersPerTrip();
      torMain[indexToUpdate]['callers_fee'] += totalCallersFee;
      torMain[indexToUpdate]['employee_benefits'] += totalEmployeeBenefits;
      torMain[indexToUpdate]['materials'] += totalMaterials;
      torMain[indexToUpdate]['representation'] += totalRepresentation;
      torMain[indexToUpdate]['parking_fee'] += totalParking;
      torMain[indexToUpdate]['others'] += totalOthers;
      torMain[indexToUpdate]['services'] += totalServices;
      torMain[indexToUpdate]['repair_maintenance'] += totalRepair;
      torMain[indexToUpdate]['total_expenses'] += totalExpenses;
      torMain[indexToUpdate]['net_collections'] += net_collection;
      torMain[indexToUpdate]['temp_net_collections'] +=
          net_collection + totalExpenses;
      torMain[indexToUpdate]['gross_revenue'] +=
          torTrip[storedData['currentTripIndex']]['gross_revenue'];
      torMain[indexToUpdate]['cashReceived'] += tickerRevenuePassenger +
          fetchService.totalCashReceivedBaggageperTrip() +
          getTotalTopUpperTrip();
      try {
        torMain[indexToUpdate]['total_top_up'] += getTotalTopUpperTrip();
      } catch (e) {
        torMain[indexToUpdate]['total_top_up'] = getTotalTopUpperTrip();
      }

      torMain[indexToUpdate]['cardSales'] += ticketRevenueCardPassenger +
          fetchService.totalCardSalesBaggageperTrip();
    }

    print('torTrip current: ${torTrip[storedData['currentTripIndex']]}');

    Map<String, dynamic> isupdateTorTrip = await httpRequestServices
        .updateTorTrip(torTrip[storedData['currentTripIndex']]);

    // List<Map<String, dynamic>> filteredtorMain = torMain
    //     .where((map) =>
    //         map['control_no'] ==
    //         torTrip[storedData['currentTripIndex']]['control_no'])
    //     .toList();

    // final torMainBody = {
    //   "coopId": "${torTrip[storedData['currentTripIndex']]['coopId']}",
    //   "UUID": "${torTrip[storedData['currentTripIndex']]['UUID']}",
    //   "device_id": "${torTrip[storedData['currentTripIndex']]['device_id']}",
    //   "control_no":
    //       "${torTrip[storedData['currentTripIndex']]['control_no']}",
    //   "tor_no": "${torTrip[storedData['currentTripIndex']]['tor_no']}",
    //   "date_of_trip":
    //       "${torTrip[storedData['currentTripIndex']]['date_of_trip']}",
    //   "bus_no": "${torTrip[storedData['currentTripIndex']]['bus_no']}",
    //   "route": "${torTrip[storedData['currentTripIndex']]['route']}",
    //   "route_code":
    //       "${torTrip[storedData['currentTripIndex']]['route_code']}",
    //   "emp_no_driver_1":
    //       "${torTrip[storedData['currentTripIndex']]['driver_id']}",
    //   "emp_no_driver_2": "",
    //   "emp_no_conductor":
    //       "${torTrip[storedData['currentTripIndex']]['conductor_id']}",
    //   "emp_name_driver_1":
    //       "${torTrip[storedData['currentTripIndex']]['driver']}",
    //   "emp_name_driver_2": "",
    //   "emp_name_conductor":
    //       "${torTrip[storedData['currentTripIndex']]['conductor']}",
    //   "eskirol_id_driver": "",
    //   "eskirol_id_conductor": "",
    //   "eskirol_name_driver": "",
    //   "eskirol_name_conductor": "",
    //   "no_of_trips":
    //       "${torTrip[storedData['currentTripIndex']]['no_of_trips']}",
    //   "ticket_revenue_atm": filteredtorMain[0]['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_count_atm": filteredtorMain[0]['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_revenue_atm_passenger": filteredtorMain[0]
    //           ['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_revenue_atm_baggage": filteredtorMain[0]['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_count_atm_passenger": filteredtorMain[0]['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_count_atm_baggage": filteredtorMain[0]['ticket_revenue_atm'] +
    //       torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'],
    //   "ticket_revenue_punch": 0,
    //   "ticket_count_punch": 0,
    //   "ticket_revenue_punch_passenger": 0,
    //   "ticket_revenue_punch_baggage": 0,
    //   "ticket_count_punch_passenger": 0,
    //   "ticket_count_punch_baggage": 0,
    //   "ticket_revenue_charter": 0,
    //   "ticket_count_charter": 0,
    //   "ticket_revenue_waybill": 0,
    //   "ticket_count_waybill": 0,
    //   "ticket_amount_cancelled": 0.0,
    //   "ticket_count_cancelled": 0.0,
    //   "ticket_amount_passes": "",
    //   "ticket_count_passes": "",
    //   "passenger_revenue": 0.0,
    //   "baggage_revenue": 0.0,
    //   "gross_revenue": 0.0,
    //   "passenger_count": 0.0,
    //   "baggage_count": 0,
    //   "commission_driver1_passenger": "",
    //   "auto_commission_driver1_passenger": 0,
    //   "commission_driver1_baggage": "",
    //   "auto_commission_driver1_baggage": 0,
    //   "commission_driver1": 0,
    //   "auto_commission_driver1": 0,
    //   "commission_driver2_passenger": "",
    //   "auto_commission_driver2_passenger": 0.0,
    //   "commission_driver2_baggage": "",
    //   "auto_commission_driver2_baggage": 0.0,
    //   "commission_driver2": 0.0,
    //   "auto_commission_driver2": "",
    //   "commission_conductor_passenger": "",
    //   "auto_commission_conductor_passenger": 0,
    //   "commission_conductor_baggage": "",
    //   "auto_commission_conductor_baggage": 0,
    //   "commission_conductor": 0,
    //   "auto_commission_conductor": 0,
    //   "incentive_driver1": 0,
    //   "incentive_driver2": 0.0,
    //   "incentive_conductor": 0.0,
    //   "allowance_driver1": 0.0,
    //   "allowance_driver2": 0.0,
    //   "allowance_conductor": 0.0,
    //   "eskirol_commission_driver": 0,
    //   "eskirol_commission_conductor": 0,
    //   "eskirol_cash_bond_driver": 0,
    //   "eskirol_cash_bond_conductor": 0,
    //   "toll_fees": totalToll,
    //   "parking_fee": totalParking,
    //   "diesel": totalDiesel,
    //   "diesel_no_of_liters": 0,
    //   "others": totalOthers,
    //   "services": totalServices,
    //   "callers_fee": 0.0,
    //   "employee_benefits": 0.0,
    //   "repair_maintenance": totalRepair,
    //   "materials": 0.0,
    //   "representation": 0.0,
    //   "total_expenses": totalExpenses,
    //   "net_collections": net_collection,
    //   "total_cash_remitted": 0.0,
    //   "final_remittance": 0.0,
    //   "final_cash_remitted": 0.0,
    //   "overage_shortage": 0.0,
    //   "tellers_id": "",
    //   "tellers_name": "",
    //   "coding": "NO",
    //   "cardSales": 0,
    //   "cashReceived": 0,
    //   "remarks": "live"
    // };

    Map<String, dynamic> isupdateTorMain =
        await httpRequestServices.updateTorMain(torMain[indexToUpdate]);

    if (isupdateTorTrip['messages'][0]['code'].toString() == "0") {
      updateTripResponse['messages']['code'] = 0;
      updateTripResponse['messages']['message'] = "OK";
      print('isupdateTorTrip: success: $isupdateTorTrip');

      _myBox.put('torTrip', torTrip);
      final newtorTrip = _myBox.get('torTrip');
      print('newtorTrip: $newtorTrip');
      int trip = storedData['currentTripIndex'] + 1;
      storedData['selectedDestination'] = {};
      storedData['currentTripIndex'] = trip;
      storedData['currentStationIndex'] = 0;
      storedData['isViceVersa'] = false;
      storedData['lastInspectorEmpNo'] = "";
      storedData['reverseNum'] = 0;
      _myBox.put('torMain', torMain);
      _myBox.put('SESSION', storedData);
      final newstoredData = _myBox.get('SESSION');
      // _myBox.put('torTicket', <Map<String, dynamic>>[]);
      // _myBox.put('expenses', <Map<String, dynamic>>[]);

      print('newstoredData: $newstoredData');

      return updateTripResponse;
    } else {
      if (isupdateTorTrip['messages'][0]['code'].toString() == "500") {
        updateTripResponse['messages']['code'] = 0;
        updateTripResponse['messages']['message'] = "OK";

        final offlineUpdateTorTrip = _myBox.get('offlineUpdateTorTrip');
        final offlineUpdateTorMain = _myBox.get('offlineUpdateTorMain');
        offlineUpdateTorMain.add(torMain[indexToUpdate]);
        offlineUpdateTorTrip.add(torTrip[storedData['currentTripIndex']]);

        _myBox.put('offlineUpdateTorTrip', offlineUpdateTorTrip);
        _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);

        // print('isupdateTorTrip: success: $isupdateTorTrip');

        _myBox.put('torTrip', torTrip);
        final newtorTrip = _myBox.get('torTrip');
        print('newtorTrip: $newtorTrip');
        int trip = storedData['currentTripIndex'] + 1;
        storedData['selectedDestination'] = {};
        storedData['currentTripIndex'] = trip;
        storedData['currentStationIndex'] = 0;
        storedData['isViceVersa'] = false;
        storedData['lastInspectorEmpNo'] = "";
        storedData['reverseNum'] = 0;
        _myBox.put('torMain', torMain);
        _myBox.put('SESSION', storedData);
        final newstoredData = _myBox.get('SESSION');
        // _myBox.put('torTicket', <Map<String, dynamic>>[]);
        // _myBox.put('expenses', <Map<String, dynamic>>[]);

        print('newstoredData: $newstoredData');

        return updateTripResponse;
      } else {
        print(
            'error isupdateTorTrip: ${isupdateTorTrip['messages'][0]['message']}');
        updateTripResponse['messages']['message'] =
            "${isupdateTorTrip['messages'][0]['message']}";
        return updateTripResponse;
      }
    }
    // } catch (e) {
    //   print('error updateCurrentTripIndex: $e');
    //   return false;
    // }
  }

  List<Map<String, dynamic>> getRouteById(
      List<Map<String, dynamic>> routeList, String id) {
    return routeList.where((route) => route['_id'].toString() == id).toList();
  }

  Future<bool> updateSpecialCurrentTripIndex(
      Map<String, dynamic> dispatcherData,
      int passengerCount,
      double passengerRevenue) async {
    try {
      String arrivedTime = await dateService.departedTime();
      String arrivedTimeStamp = await dateService.departureTimestamp();

      final storedData = _myBox.get('SESSION');
      final torTrip = _myBox.get('torTrip');
      final torTicket = _myBox.get('torTicket');
      final routes = _myBox.get('routeList');
      final stations = getFilteredStations(fetchService.fetchStationList());
      final selectedRoute =
          getRouteById(routes, storedData['routeID'].toString());
      String control_no =
          torTrip[storedData['currentTripIndex']]['control_no'].toString();
      String tripType =
          torTrip[storedData['currentTripIndex']]['control_no'].toString();
      torTrip[storedData['currentTripIndex']]['arrived_dispatcher_id'] =
          dispatcherData['empNo'];

      torTrip[storedData['currentTripIndex']]['arrived_dispatcher'] =
          '${dispatcherData['firstName']} ${dispatcherData['lastName']} ${dispatcherData['nameSuffix']}';
      final myLocation = _myBox.get('myLocation');
      String latitude = '${myLocation?['latitude'] ?? "0.00"}';
      String longitude = '${myLocation?['longitude'] ?? "0.00"}';
      torTrip[storedData['currentTripIndex']]['arrived_place'] =
          "${stations[stations.length - 1]['stationName']}";
      torTrip[storedData['currentTripIndex']]['arrival_lat'] = latitude;
      torTrip[storedData['currentTripIndex']]['arrival_long'] = longitude;
      torTrip[storedData['currentTripIndex']]['arrived_time'] = arrivedTime;
      torTrip[storedData['currentTripIndex']]['arrival_timestamp'] =
          arrivedTimeStamp;

      double net_collection = 0;

      final expenses = _myBox.get('expenses');
      double totalExpenses = expenses
          .where((item) => item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalDiesel = expenses
          .where((item) =>
              item['particular'] == "Fuel" && item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalToll = expenses
          .where((item) =>
              item['particular'] == "TOLL" && item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalParking = expenses
          .where((item) =>
              item['particular'] == "PARKING" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalServices = expenses
          .where((item) =>
              item['particular'] == "SERVICES" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalRepair = expenses
          .where((item) =>
              item['particular'] == "REPAIR" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalCallersFee = expenses
          .where((item) =>
              item['particular'] == "CALLER'S FEE" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalEmployeeBenefits = expenses
          .where((item) =>
              item['particular'] == "EMPLOYEE BENEFITS" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalMaterials = expenses
          .where((item) =>
              item['particular'] == "MATERIALS" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();

      double totalRepresentation = expenses
          .where((item) =>
              item['particular'] == "REPRESENTATION" &&
              item['control_no'] == control_no)
          .map((item) => (item['amount'] ?? 0.0) as num)
          .fold(0.0, (prev, amount) => prev + amount)
          .toDouble();
      double totalOthers = totalServices +
          totalCallersFee +
          totalEmployeeBenefits +
          totalRepair +
          totalMaterials +
          totalRepresentation;

      final torMain = _myBox.get('torMain');
      int indexToUpdate = torMain.indexWhere((map) =>
          map['tor_no'] == torTrip[storedData['currentTripIndex']]['tor_no']);

      // if (torTicket.isNotEmpty) {
      torTrip[storedData['currentTripIndex']]['from_km'] = stations[0]['km'];

      torTrip[storedData['currentTripIndex']]['to_km'] =
          stations[stations.length - 1]['km'];
      torTrip[storedData['currentTripIndex']]['km_run'] =
          ((stations[0]['km'] ?? 0) -
                  (stations[stations.length - 1]['km'] ?? 0))
              .abs();
      // double baggageCount = torTicket
      //     .where((ticket) => ticket['control_no'] == control_no)
      //     .fold(0.0,
      //         (sum, ticket) => sum + (ticket['baggage'] as num).toDouble());
      // double totalAmount = torTicket
      //     .where((ticket) => ticket['control_no'] == control_no)
      //     .fold(
      //         0.0, (sum, ticket) => sum + (ticket['fare'] as num).toDouble());
      // double grandTotal = totalAmount + baggageCount;
      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm'] = 0;

      int totalTickets = torTicket
          .where((ticket) => ticket['control_no'] == control_no)
          .length;
      // torTrip[storedData['currentTripIndex']]['ticket_count_atm'] =
      //     passengerCount;

      double ticketRevenueCardPassenger = torTicket
          .where((ticket) =>
              ticket['control_no'] == control_no &&
              (ticket['cardType'] != 'mastercard' &&
                  ticket['cardType'] != 'cash'))
          .fold(
            0.0,
            (sum, ticket) =>
                sum +
                (((ticket['fare'] ?? 0.0) as num).toDouble() * ticket['pax']) +
                ((ticket['additionalFare'] ?? 0.0) as num).toDouble() +
                ((ticket['baggage'] ?? 0.0) as num).toDouble(),
          );

      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm_passenger'] =
          0;

      torTrip[storedData['currentTripIndex']]['ticket_revenue_charter'] =
          passengerRevenue;
      torTrip[storedData['currentTripIndex']]['ticket_count_charter'] =
          passengerCount;
      torTrip[storedData['currentTripIndex']]['ticket_revenue_card'] =
          ticketRevenueCardPassenger;
      torTrip[storedData['currentTripIndex']]['ticket_revenue_atm_baggage'] =
          fetchService.totalBaggageperTrip();
      // int ticket_count_atm_passenger = torTicket
      //     .where((ticket) =>
      //         ticket['control_no'] == control_no && ticket['fare'] > 0)
      //     .length;
      torTrip[storedData['currentTripIndex']]['ticket_count_atm_passenger'] = 0;

      torTrip[storedData['currentTripIndex']]['ticket_count_card'] =
          fetchService.cardSalesCount();

      torTrip[storedData['currentTripIndex']]['passenger_revenue'] =
          passengerRevenue;
      torTrip[storedData['currentTripIndex']]['passenger_count'] =
          passengerCount;

      torTrip[storedData['currentTripIndex']]['gross_revenue'] =
          passengerRevenue;
      // int ticket_count_atm_baggage = torTicket
      //     .where((ticket) =>
      //         ticket['control_no'] == control_no && ticket['baggage'] > 0)
      //     .length;
      torTrip[storedData['currentTripIndex']]['ticket_count_atm_baggage'] =
          fetchService.baggageCount();

      torTrip[storedData['currentTripIndex']]['cashReceived'] = 0;
      torTrip[storedData['currentTripIndex']]['cardSales'] =
          ticketRevenueCardPassenger;

      net_collection =
          (passengerRevenue + ticketRevenueCardPassenger) - totalExpenses;
      // update tormain hive

      // torMain[indexToUpdate]['ticket_revenue_atm_passenger'] +=
      //     passengerRevenue;

      torMain[indexToUpdate]['ticket_revenue_charter'] += passengerRevenue;

      torMain[indexToUpdate]['ticket_count_charter'] += passengerCount;

      torMain[indexToUpdate]['ticket_revenue_atm_baggage'] +=
          fetchService.totalBaggageperTrip();

      // torMain[indexToUpdate]['ticket_count_atm_passenger'] += passengerCount;

      torMain[indexToUpdate]['ticket_count_atm_baggage'] +=
          fetchService.baggageCount();

      torMain[indexToUpdate]['passenger_count'] += passengerCount;
      torMain[indexToUpdate]['passenger_revenue'] += passengerRevenue;

      // torMain[indexToUpdate]['ticket_revenue_atm'] += passengerRevenue;
      // torMain[indexToUpdate]['ticket_count_atm'] += passengerCount;
      torMain[indexToUpdate]['toll_fees'] += totalToll;
      torMain[indexToUpdate]['parking_fee'] += totalParking;
      torMain[indexToUpdate]['others'] += totalOthers;
      torMain[indexToUpdate]['services'] += totalServices;
      torMain[indexToUpdate]['repair_maintenance'] += totalRepair;
      torMain[indexToUpdate]['total_expenses'] += totalExpenses;
      torMain[indexToUpdate]['gross_revenue'] += passengerRevenue;
      torMain[indexToUpdate]['net_collections'] += net_collection;
      torMain[indexToUpdate]['temp_net_collections'] +=
          net_collection + totalExpenses;
      // torMain[indexToUpdate]['cashReceived'] += passengerRevenue;
      torMain[indexToUpdate]['cardSales'] += ticketRevenueCardPassenger;

      // end if torticket is empty
      // }

      print('torTrip current: ${torTrip[storedData['currentTripIndex']]}');

      Map<String, dynamic> isupdateTorTrip = await httpRequestServices
          .updateTorTrip(torTrip[storedData['currentTripIndex']]);

      Map<String, dynamic> isupdateTorMain =
          await httpRequestServices.updateTorMain(torMain[indexToUpdate]);

      if (isupdateTorTrip['messages'][0]['code'].toString() == "0") {
        final offlineUpdateTorTrip = _myBox.get('offlineUpdateTorTrip');
        final offlineUpdateTorMain = _myBox.get('offlineUpdateTorMain');
        offlineUpdateTorMain.add(torMain[indexToUpdate]);
        offlineUpdateTorTrip.add(torTrip[storedData['currentTripIndex']]);

        _myBox.put('offlineUpdateTorTrip', offlineUpdateTorTrip);
        _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);

        print('isupdateTorTrip: success: $isupdateTorTrip');

        _myBox.put('torTrip', torTrip);
        final newtorTrip = _myBox.get('torTrip');
        print('newtorTrip: $newtorTrip');
        int trip = storedData['currentTripIndex'] + 1;
        storedData['selectedDestination'] = {};
        storedData['currentTripIndex'] = trip;
        storedData['currentStationIndex'] = 0;
        storedData['isViceVersa'] = false;
        storedData['lastInspectorEmpNo'] = "";
        storedData['reverseNum'] = 0;
        _myBox.put('torMain', torMain);
        _myBox.put('SESSION', storedData);
        final newstoredData = _myBox.get('SESSION');
        // _myBox.put('torTicket', <Map<String, dynamic>>[]);
        // _myBox.put('expenses', <Map<String, dynamic>>[]);

        print('newstoredData: $newstoredData');
        return true;
      } else {
        if (isupdateTorTrip['messages'][0]['code'].toString() == "500") {
          print('isupdateTorTrip: success: $isupdateTorTrip');

          _myBox.put('torTrip', torTrip);
          final newtorTrip = _myBox.get('torTrip');
          print('newtorTrip: $newtorTrip');
          int trip = storedData['currentTripIndex'] + 1;
          storedData['selectedDestination'] = {};
          storedData['currentTripIndex'] = trip;
          storedData['currentStationIndex'] = 0;
          storedData['isViceVersa'] = false;
          storedData['lastInspectorEmpNo'] = "";
          storedData['reverseNum'] = 0;
          _myBox.put('torMain', torMain);
          _myBox.put('SESSION', storedData);
          final newstoredData = _myBox.get('SESSION');
          // _myBox.put('torTicket', <Map<String, dynamic>>[]);
          // _myBox.put('expenses', <Map<String, dynamic>>[]);

          print('newstoredData: $newstoredData');

          return true;
        } else {
          if (isupdateTorTrip['messages'][0]['code'].toString() == "500") {
            print('isupdateTorTrip: success: $isupdateTorTrip');

            _myBox.put('torTrip', torTrip);
            final newtorTrip = _myBox.get('torTrip');
            print('newtorTrip: $newtorTrip');
            int trip = storedData['currentTripIndex'] + 1;
            storedData['selectedDestination'] = {};
            storedData['currentTripIndex'] = trip;
            storedData['currentStationIndex'] = 0;
            storedData['isViceVersa'] = false;
            storedData['lastInspectorEmpNo'] = "";
            storedData['reverseNum'] = 0;
            _myBox.put('torMain', torMain);
            _myBox.put('SESSION', storedData);
            final newstoredData = _myBox.get('SESSION');
            // _myBox.put('torTicket', <Map<String, dynamic>>[]);
            // _myBox.put('expenses', <Map<String, dynamic>>[]);

            print('newstoredData: $newstoredData');

            final offlineUpdateTorTrip = _myBox.get('offlineUpdateTorTrip');
            final offlineUpdateTorMain = _myBox.get('offlineUpdateTorMain');
            offlineUpdateTorMain.add(torMain[indexToUpdate]);
            offlineUpdateTorTrip.add(torTrip[storedData['currentTripIndex']]);

            _myBox.put('offlineUpdateTorTrip', offlineUpdateTorTrip);
            _myBox.put('offlineUpdateTorMain', offlineUpdateTorMain);
            return true;
          } else {
            print(
                'error isupdateTorTrip: ${isupdateTorTrip['messages'][0]['message']}');
            return false;
          }
        }
      }
    } catch (e) {
      print('error updateCurrentTripIndex: $e');
      return false;
    }
  }

  Future<bool> resetTrip() async {
    try {
      final storedData = _myBox.get('SESSION');
      storedData['currentTripIndex'] = 0;
      storedData['selectedDestination'] = {};
      storedData['isClosed'] = false;
      storedData['lastInspectorEmpNo'] = "";
      storedData['torNo'] = "";
      var removedcashCardInfo = storedData.remove('cashCardInfo');
      var removedloginInfo = storedData.remove('loginInfo');

      print('removed Map after removing age: $storedData');
      print('Removed value: $removedcashCardInfo');
      print('Removed value: $removedloginInfo');
      _myBox.put('SESSION', storedData);
      final newstoredData = _myBox.get('SESSION');
      _myBox.put('torTrip', <Map<String, dynamic>>[]);
      _myBox.put('torMain', <Map<String, dynamic>>[]);
      // _myBox.put('offlineTicket', <Map<String, dynamic>>[]);
      // _myBox.put('offlineUpdateAdditionalFare', <Map<String, dynamic>>[]);
      _myBox.put('torTicket', <Map<String, dynamic>>[]);
      _myBox.put('prepaidTicket', <Map<String, dynamic>>[]);
      _myBox.put('prepaidBaggage', <Map<String, dynamic>>[]);
      _myBox.put('expenses', <Map<String, dynamic>>[]);
      _myBox.put('topUpList', <Map<String, dynamic>>[]);
      _myBox.put('torInspection', <Map<String, dynamic>>[]);
      // _myBox.put('offlinetorInspection', <Map<String, dynamic>>[]);
      // _myBox.put('offlinetorViolation', <Map<String, dynamic>>[]);

      print('newstoredData: $newstoredData');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> addExpenses(Map<String, dynamic> item) async {
    try {
      final storedData = _myBox.get('expenses');
      storedData.add(item);
      _myBox.put('expenses', storedData);
      final newstoredData = _myBox.get('expenses');
      print('addExpenses newstoredData: $newstoredData');
      return true;
    } catch (e) {
      print('error addExpenses: $e');
      return false;
    }
  }

  Future<bool> addFuel(Map<String, dynamic> item) async {
    try {
      final storedData = _myBox.get('fuel');
      storedData.add(item);
      _myBox.put('fuel', storedData);
      final newstoredData = _myBox.get('fuel');
      print('addFuel newstoredData: $newstoredData');
      return true;
    } catch (e) {
      print('addFuel fuel: $e');
      return false;
    }
  }

  Future<String> getSerialNumber() async {
    final storedData = _myBox.get('SESSION');
    String serialNumber = storedData['serialNumber'];
    return serialNumber;
  }

  String getSerialNumber2() {
    final storedData = _myBox.get('SESSION');
    String serialNumber = storedData['serialNumber'];
    return serialNumber;
  }

  Future<bool> updateCardBalance(
      final cardList, String cardID, double newBalance) async {
    try {
      Map<String, dynamic>? cardToUpdate =
          cardList.firstWhere((card) => card['cardID'] == cardID);

      if (cardToUpdate != null) {
        cardToUpdate['balance'] =
            newBalance; // Replace 15000 with the new balance value
        print('Balance updated successfully');
        print('masterCardList: $cardList');
        return true;
      } else {
        print('Card not found');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  double getCashReceived() {
    final torTicket = _myBox.get('torTicket');
    for (int i = 0; i < torTicket.length; i++) {
      print('torTicket-$i: ${torTicket[i]}');
    }
    double cashRecieved = 0.0;
    cashRecieved = torTicket
        .where((ticket) => (ticket['cardType'] == 'mastercard' ||
            ticket['cardType'] == 'cash'))
        .fold<double>(
            0.0,
            (double sum, ticket) =>
                sum +
                ((ticket['fare'] as num).toDouble() * ticket['pax']) +
                (ticket['baggage'] as num).toDouble());
    double totalAddFarecashRecieved = torTicket
        .where((ticket) => (ticket['additionalFareCardType'] == 'mastercard' ||
            ticket['additionalFareCardType'] == 'cash'))
        .fold<double>(
            0.0,
            (double sum, ticket) =>
                sum + (ticket['additionalFare'] as num).toDouble());
    print('cashRecieved: $cashRecieved');
    return cashRecieved + totalAddFarecashRecieved;
  }

  double getAllCashRecevied() {
    final torTrip = _myBox.get('torTrip');
    double cashreceived = 0;
    if (torTrip.isNotEmpty) {
      for (var element in torTrip) {
        cashreceived += double.parse(element['cashReceived'].toString());
      }

      return cashreceived;
    } else {
      return cashreceived;
    }
  }

  Future<bool> addOfflineTicket(Map<String, dynamic> item) async {
    try {
      final storedListOfMaps = _myBox.get('offlineTicket');

      storedListOfMaps.add(item);
      _myBox.put('offlineTicket', storedListOfMaps);

      print('addOfflineTicket offlineTicket: $storedListOfMaps');
      return true;
    } catch (e) {
      print('addOfflineTicket error: $e');
      return false;
    }
  }

  Future<bool> addOfflineFuel(Map<String, dynamic> item) async {
    try {
      final storedListOfMaps = _myBox.get('offlineFuel');

      storedListOfMaps.add(item);
      _myBox.put('offlineFuel', storedListOfMaps);

      print('addofflineFuel offlineFuel: $storedListOfMaps');
      return true;
    } catch (e) {
      print('addofflineFuel error: $e');
      return false;
    }
  }

  Future<bool> addOfflineAdditionalFare(Map<String, dynamic> item) async {
    try {
      var copyItem = Map<String, dynamic>.from(item);
      print('copyItem: $copyItem');
      List<Map<String, dynamic>> offlineAddFare =
          _myBox.get('offlineUpdateAdditionalFare');

      bool isExisted = false;
      for (int i = 0; i < offlineAddFare.length; i++) {
        if (offlineAddFare[i]['items']['ticket_no'] ==
            copyItem['items']['ticket_no']) {
          isExisted = true;
          // Deep copy the 'items' map
          offlineAddFare[i]['items'] =
              Map<String, dynamic>.from(copyItem['items']);
        }
      }
      if (!isExisted) {
        // Deep copy the 'items' map before adding it to the list
        offlineAddFare.add(Map<String, dynamic>.from(copyItem));
      }

      print('copyitem offlineAddFare: $offlineAddFare');
      //  _myBox.put('offlineUpdateAdditionalFare', <Map<String, dynamic>>[]);
      _myBox.put('offlineUpdateAdditionalFare', offlineAddFare);

      List<Map<String, dynamic>> torTicket = _myBox.get('torTicket');
      List<Map<String, dynamic>> copyTorTicket = List.from(torTicket);
      for (int i = 0; i < copyTorTicket.length; i++) {
        if (copyTorTicket[i]['ticket_no'] == copyItem['items']['ticket_no']) {
          isExisted = true;
          // Deep copy the 'items' map
          copyTorTicket[i]['items'] =
              Map<String, dynamic>.from(copyItem['items']);
          copyTorTicket[i]['additionalFare'] += copyItem['amount'];
          copyTorTicket[i]['additionalFareCardType'] =
              copyItem['additionalFareCardType'];
        }
      }
      _myBox.put('torTicket', copyTorTicket);

      print('copyitem! torTicket: $torTicket');
      print('copyitem offlineAddFare v2: $offlineAddFare');
      return true;
    } catch (e) {
      print('copyitem offlineUpdateAdditionalFare error: $e');
      return false;
    }
  }

  Future<bool> addInspection(Map<String, dynamic> item) async {
    try {
      final storedListOfMaps = _myBox.get('torInspection');
      // final session = _myBox.get('SESSION');
      storedListOfMaps.add(item);
      _myBox.put('torInspection', storedListOfMaps);
      // session['lastInspectorEmpNo'] = "${item['inspector_emp_no']}";
      // _myBox.put('SESSION', session);
      print('addInspection : $storedListOfMaps');
      final newsession = _myBox.get('SESSION');
      print('addInspection new session: $newsession');
      return true;
    } catch (e) {
      print('addInspection error: $e');
      return false;
    }
  }

  Future<bool> addOfflineInspection(Map<String, dynamic> item) async {
    try {
      final storedListOfMaps = _myBox.get('offlinetorInspection');
      // final session = _myBox.get('SESSION');
      storedListOfMaps.add(item);
      _myBox.put('offlinetorInspection', storedListOfMaps);
      // session['lastInspectorEmpNo'] = "${item['inspector_emp_no']}";
      // _myBox.put('SESSION', session);
      print('offlinetorInspection : $storedListOfMaps');
      return true;
    } catch (e) {
      print('addInspection error: $e');
      return false;
    }
  }

  Future<bool> addOfflineViolation(Map<String, dynamic> item) async {
    try {
      final storedListOfMaps = _myBox.get('offlinetorViolation');

      storedListOfMaps.add(item);
      _myBox.put('offlinetorViolation', storedListOfMaps);
      print('addOfflineViolation : $storedListOfMaps');
      return true;
    } catch (e) {
      print('addOfflineViolation error: $e');
      return false;
    }
  }

  Future<bool> addToup(final cardData) async {
    try {
      final topUpList = _myBox.get('topUpList');
      topUpList.add(cardData);

      _myBox.put('topUpList', topUpList);

      print('topUpList: $topUpList');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updatetorMainExpenses(
      String particular, String tor_no, double amount) async {
    try {
      final torMain = _myBox.get('torMain');

      int indextorMain = torMain.indexWhere((item) => item['tor_no'] == tor_no);
      torMain[indextorMain]['total_expenses'] += amount;

      if (particular == "TOLL") {
        torMain[indextorMain]['toll_fees'] += amount;
      }
      if (particular == "PARKING") {
        torMain[indextorMain]['parking_fee'] += amount;
      }
      if (particular == "SERVICES") {
        torMain[indextorMain]['services'] += amount;
        torMain[indextorMain]['others'] += amount;
      }
      if (particular == "CALLER'S FEE") {
        torMain[indextorMain]['callers_fee'] += amount;
        torMain[indextorMain]['others'] += amount;
      }
      if (particular == "EMPLOYEE BENEFITS") {
        torMain[indextorMain]['employee_benefits'] += amount;
        torMain[indextorMain]['others'] += amount;
      }
      if (particular == "MATERIALS") {
        torMain[indextorMain]['materials'] += amount;
        torMain[indextorMain]['others'] += amount;
      }
      if (particular == "REPRESENTATION") {
        torMain[indextorMain]['representation'] += amount;
        torMain[indextorMain]['others'] += amount;
      }
      if (particular == "REPAIR") {
        torMain[indextorMain]['repair_maintenance'] += amount;
        torMain[indextorMain]['others'] += amount;
      }

      _myBox.put('torMain', torMain);
      return true;
    } catch (e) {
      return false;
    }
  }
}
