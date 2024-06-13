import 'package:dltb/backend/provider/MobileNumberProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileNumberNotifier extends StatefulWidget {
  final Widget child;

  MobileNumberNotifier({required this.child});

  @override
  _MobileNumberNotifierState createState() => _MobileNumberNotifierState();
}

class _MobileNumberNotifierState extends State<MobileNumberNotifier> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MobileNumberProvider>(context, listen: false)
          .addListener(_showMobileNumberChange);
    });
  }

  void _showMobileNumberChange() {
    final provider = Provider.of<MobileNumberProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Mobile number changed: ${provider.mobileNumber}')),
    );
  }

  @override
  void dispose() {
    Provider.of<MobileNumberProvider>(context, listen: false)
        .removeListener(_showMobileNumberChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
