import 'package:flutter/material.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/UI/trailing.dart';

Widget buildStepItem({
  required IconData icon,
  required String title,
  required String status,
  required Color iconColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return reusableListItem(
    icon: icon,
    title: title,
    subtitle: status,
    iconColor: iconColor,
    onTap: onTap,
    trailing: trailing(),
    subtitleColor: textColor,
  );
}
