import 'package:dltb/backend/fetch/fetchAllData.dart';

class checkCards {
  fetchServices fetchservice = fetchServices();

  Map<String, dynamic>? isCardExisting(String cardID) {
    // List<Map<String, dynamic>> loginInfo = fetchservice.fetchLoginInfoList();
    List<Map<String, dynamic>> cardList = fetchservice.fetchCardList();
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    // List<Map<String, dynamic>> cardList;
    // if (loginInfo != null && loginInfo != []) {
    //   cardList = loginInfo;
    // } else {
    //   cardList = beforecardList;
    // }

    for (int i = 0; i < cardList.length; i++) {
      print('cardList$i: ${cardList[i]}');
    }
    final card = cardList.firstWhere(
      (card) => card['cardId'].toString() == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    print('card: $card');

    if (card != {} && card.isNotEmpty) {
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );

      final employeeWithCardId = Map<String, dynamic>.from(employee);
      employeeWithCardId['cardId'] = cardID;
      return employeeWithCardId;
    }
    return null; // Employee not found
  }

  Map<String, dynamic>? isDashboardCardExisting(String cardID) {
    List<dynamic> cardList = fetchservice.fetchLoginInfoList();
    // print('isDashboardCardExisting cardlist: $cardList');
    List<Map<String, dynamic>> cardListOriginal = fetchservice.fetchCardList();
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    // List<Map<String, dynamic>> cardList;
    // if (loginInfo != null && loginInfo != []) {
    //   cardList = loginInfo;
    // } else {
    //   cardList = beforecardList;
    // }

    // for (int i = 0; i < cardList.length; i++) {
    //   print('cardList$i: ${cardList[i]}');
    // }
    final card = cardList.firstWhere(
      (card) => card['cardId'].toString() == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    print('isDashboardCardExisting card: $card');

    if (card != {} && card != null && card.isNotEmpty) {
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );

      final employeeWithCardId = Map<String, dynamic>.from(employee);
      employeeWithCardId['cardId'] = cardID;
      return employeeWithCardId;
    } else {
      final card = cardListOriginal.firstWhere(
        (card) => card['cardId'].toString() == cardID.toString(),
        orElse: () => <String, Object>{},
      );
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );
      print('isDashboardCardExisting employee: $employee');
      if (employee['designation'] != "Bus Driver" &&
          employee['designation'] != "Bus Conductor") {
        return employee;
      }
    }
    print('isDashboardCardExisting');
    return null; // Employee not found
  }

  Map<String, dynamic>? isMasterCardExisting(String cardID) {
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    List<Map<String, dynamic>> cardList = fetchservice.fetchMasterCardList();
    for (int i = 0; i < cardList.length; i++) {
      print('mastercardList$i: ${cardList[i]}');
    }
    final card = cardList.firstWhere(
      (card) => card['cardID'].toString() == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    print('isMasterCardExisting mastercard info: $card');

    if (card != {} && card.isNotEmpty) {
      print('isMasterCardExisting not equal to empty');
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );
      final employeeWithCardId = Map<String, dynamic>.from(employee);
      employeeWithCardId['cardID'] = cardID;
      employeeWithCardId['balance'] = card['balance'];
      employeeWithCardId['sNo'] = card['sNo'];
      employeeWithCardId['cardType'] = card['cardType'];
      return employeeWithCardId;
    }
    return null; // Employee not found
  }

  Map<String, dynamic>? dashboardisCardExisting(String cardID) {
    List<Map<String, dynamic>> employeeList = fetchservice.fetchEmployeeList();
    List<Map<String, dynamic>> cardList = fetchservice.fetchCardList();
    final card = cardList.firstWhere(
      (card) => card['cardId'].toString == cardID.toString(),
      orElse: () => <String, Object>{},
    );

    if (card != {}) {
      final empNo = card['empNo'];
      final employee = employeeList.firstWhere(
        (employee) => employee['empNo'].toString() == empNo.toString(),
        orElse: () => <String, Object>{},
      );
      final employeeWithCardId = Map<String, dynamic>.from(employee);
      employeeWithCardId['cardId'] = cardID;
      return employeeWithCardId;
    }
    return null; // Employee not found
  }
}
