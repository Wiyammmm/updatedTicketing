class ServiceValidator {
  Future<bool?> isDispatchValid(
      String vehicleNo,
      String bound,
      String route,
      bool isDriverLogin,
      bool isDispatcherLogin,
      bool isConductorLogin,
      bool isCashCardLogin,
      bool isCashLess) async {
    if (vehicleNo != '' &&
        bound != '' &&
        route != '' &&
        isDriverLogin != false &&
        isDispatcherLogin != false &&
        isConductorLogin != false) {
      if (isCashLess) {
        if (isCashCardLogin == false) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
}
