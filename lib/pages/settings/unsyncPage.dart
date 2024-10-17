import 'package:dltb/backend/service/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// class UnsyncController extends GetxController {

// }

class OfflineController extends GetxController {
  var selected = 0.obs;
  var ticketList = [].obs; // Initialize an empty list as observable
  var dispatchList = [].obs;

  var arrivalList = [].obs;

  var ticketResponse = "".obs;
  var dispatchResponse = "".obs;
  var arrivalResponse = "".obs;
  // Lifecycle method where async initialization happens
  @override
  void onInit() async {
    super.onInit();

    // Open the Hive box
    final _myBox = await Hive.openBox('myBox');

    // Retrieve the 'offlineTicket' from Hive and assign it to ticketList
    var offlineTickets = _myBox.get('offlineTicket');
    var offlineDispatchList = _myBox.get('offlineDispatch');
    final offlineUpdateTorTrip = _myBox.get('offlineUpdateTorTrip');

    ticketList.value = offlineTickets; // Make it observable
    dispatchList.value = offlineDispatchList;
    arrivalList.value = offlineUpdateTorTrip;
    print('arrivalList: ${arrivalList}');
  }
}

class UnsyncPage extends StatelessWidget {
  UnsyncPage({super.key});

  // UnsyncController unsyncController = Get.put(UnsyncController());
  OfflineController offlineController = Get.find();
  timeServices timeservices = timeServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsync Page'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (offlineController.ticketResponse.value != "") {
          print('transactionResponse.value not empty');

          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(offlineController.ticketResponse.value),
                duration: Duration(seconds: 3),
              ));
            }
          });
        }

        if (offlineController.dispatchResponse.value != "") {
          print('transactionResponse.value not empty');

          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(offlineController.dispatchResponse.value),
                duration: Duration(seconds: 3),
              ));
            }
          });
        }

        if (offlineController.arrivalResponse.value != "") {
          print('transactionResponse.value not empty');

          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(offlineController.arrivalResponse.value),
                duration: Duration(seconds: 3),
              ));
            }
          });
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    offlineController.selected.value = 0;

                    print(
                        'offlineController.selected.value: ${offlineController.selected.value}');
                  },
                  child: UnsyncButtonController(
                    unSyncValue: offlineController.selected.value,
                    targetValue: 0,
                    label: 'Ticket',
                  ),
                )),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    offlineController.selected.value = 1;
                    print(
                        'offlineController.selected.value: ${offlineController.selected.value}');
                  },
                  child: UnsyncButtonController(
                    targetValue: 1,
                    unSyncValue: offlineController.selected.value,
                    label: 'Dispatch',
                  ),
                )),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    offlineController.selected.value = 2;
                    offlineController.selected.refresh();
                    print(
                        'offlineController.selected.value: ${offlineController.selected.value}');
                  },
                  child: UnsyncButtonController(
                    targetValue: 2,
                    unSyncValue: offlineController.selected.value,
                    label: 'Arrival',
                  ),
                ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            if (offlineController.selected == 0) ...[
              if (offlineController.ticketList.isEmpty) Text('No Data'),
              Expanded(
                child: ListView.builder(
                    itemCount: offlineController.ticketList.length,
                    itemBuilder: (context, index) {
                      final ticket =
                          offlineController.ticketList[index]['items'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListRow(
                              label: "Ticket No:",
                              value: '${ticket['ticket_no']}',
                            ),
                            ListRow(
                              label: "Date:",
                              value:
                                  '${timeservices.converterDate(ticket['created_on'].toString())}',
                            ),
                            ListRow(
                              label: "Origin:",
                              value: '${ticket['from_place']}',
                            ),
                            ListRow(
                              label: "Destination:",
                              value: '${ticket['to_place']}',
                            ),
                            ListRow(
                              label: "Amount:",
                              value: '${ticket['subtotal']}',
                            ),
                            Divider()
                          ],
                        ),
                      );
                    }),
              )
            ],
            if (offlineController.selected == 1) ...[
              if (offlineController.dispatchList.isEmpty) Text('No Data'),
              Expanded(
                child: ListView.builder(
                    itemCount: offlineController.dispatchList.length,
                    itemBuilder: (context, index) {
                      final dispatch = offlineController.dispatchList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListRow(
                              label: "TOR NO:",
                              value: '${dispatch['tor_no']}',
                            ),
                            ListRow(
                              label: "Date of Trip:",
                              value: '${dispatch['date_of_trip']}',
                            ),
                            ListRow(
                              label: "route:",
                              value: '${dispatch['route']}',
                            ),
                            Divider()
                          ],
                        ),
                      );
                    }),
              )
            ],
            if (offlineController.selected == 2) ...[
              if (offlineController.arrivalList.isEmpty) Text('No Data'),
              Expanded(
                child: ListView.builder(
                    itemCount: offlineController.arrivalList.length,
                    itemBuilder: (context, index) {
                      final arrival = offlineController.arrivalList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListRow(
                              label: "TOR NO:",
                              value: '${arrival['tor_no']}',
                            ),
                            ListRow(
                              label: "DEPARTURE:",
                              value:
                                  '${timeservices.converterDate(arrival['departed_time'].toString())}',
                            ),
                            ListRow(
                              label: "route:",
                              value: '${arrival['route']}',
                            ),
                            Divider()
                          ],
                        ),
                      );
                    }),
              )
            ],
          ],
        );
      }),
    );
  }
}

class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
  }
}

class UnsyncButtonController extends StatelessWidget {
  const UnsyncButtonController(
      {super.key,
      required this.unSyncValue,
      required this.label,
      required this.targetValue});

  final int unSyncValue;
  final String label;
  final int targetValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          color: unSyncValue == targetValue ? Colors.blueAccent : Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: unSyncValue == targetValue ? Colors.white : Colors.blue,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
