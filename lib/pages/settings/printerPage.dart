import 'package:dltb/backend/printer/connectToPrinter.dart';
import 'package:dltb/backend/printer/printReceipt.dart';
import 'package:dltb/components/color.dart';
import 'package:dltb/pages/settings/unsyncPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrinterPage extends StatelessWidget {
  PrinterPage({super.key});

  TestPrinttt TestPrintt = TestPrinttt();

  PrinterController printerController = Get.put(PrinterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        leading: SizedBox(),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.secondaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Obx(() {
                  return Column(
                    children: [
                      Text('PRINTER'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Status: '),
                          Text(
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: printerController.connected.value
                                      ? Colors.green
                                      : Colors.red),
                              '${printerController.connected.value ? 'Connected' : 'Disconnected'}'),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: printerController
                                        .connected.value
                                    ? MaterialStateProperty.all(Colors.green)
                                    : MaterialStateProperty.all(
                                        Colors.blueAccent)),
                            onPressed: () async {
                              if (!printerController.connected.value) {
                                await printerController.connectToPrinter();
                              }
                            },
                            child: Text(printerController.connected.value
                                ? 'Connected'
                                : 'Connect')),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                            onPressed: () async {
                              await TestPrintt.sample();
                            },
                            child: Text('Test Print')),
                      ),
                      const Divider(),
                      Text('Unsync Data'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UnsyncPage()));
                            },
                            child: Text('Unsync Page')),
                      ),
                    ],
                  );
                }),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .primaryColor, // Background color of the button
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.black),
                        borderRadius:
                            BorderRadius.circular(10.0), // Border radius
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'BACK',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
