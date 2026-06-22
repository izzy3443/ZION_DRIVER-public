import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_doc_model.dart';
import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_permission_check.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

final driverDocsProvider = FutureProvider<DriverDocuments>((ref) async {
  final uid = ref.read(userProvider)!.uid;
  final firestore = FirebaseFirestore.instance;
  final docCollection =
      firestore.collection("drivers").doc(uid).collection("driver_documents");

  final userDoc = await firestore.collection("drivers").doc(uid).get();
  final dlSnap = await docCollection.doc("DriverLicence").get();
  final rcSnap = await docCollection.doc("RegistrationCertificate").get();
  final ppSnap = await docCollection.doc("ProfilePhoto").get();
  final permission = await areAllPermissionsGranted();
  final userData = userDoc.data();

  return DriverDocuments(
    dl: DriverLicenceDoc.fromMap(dlSnap.data()),
    rc: RegistrationCertificateDoc.fromMap(rcSnap.data()),
    pp: ProfilePhotoDoc.fromMap(ppSnap.data()),
    firstName: userData?['firstName'],
    lastName: userData?['lastName'],
    permission: permission,
  );
});
