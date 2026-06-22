import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion_driver_553/models/driver_home_model.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/controller_dashboard.dart';

final driverHomeControllerProvider =
    AutoDisposeNotifierProvider<DriverHomeController, DriverHomeState>(
  DriverHomeController.new,
);
