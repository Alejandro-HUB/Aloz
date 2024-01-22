// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Constants/IconHelper.dart';
import 'package:projectcrm/Helpers/Routing/AppRouter.dart';
import 'package:projectcrm/Models/WidgetsEntity.dart';
import 'package:projectcrm/Pages/Home/HomePage.dart';

class WidgetService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GetWidgetsResponse> fetchWidgets(
      int pageSize, int pageNumber, String? filter) async {
    List<WidgetsInfo> widgets = [];

    widgets.add(WidgetsInfo(
        id: "0",
        title: "Home",
        icon: Icons.home,
        widgetType: "Home",
        currentPage: 0,
        documentIdData: "0"));

    final uid = _auth.currentUser!.uid;

    // Order the collection by id
    final orderedQuery = _firestore
        .collection("UserWidgets")
        .doc(uid)
        .collection("UserWidgets:$uid")
        .orderBy('id'); // Replace with the actual field to order by

    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    DocumentSnapshot<Object?> lastDocument;

    if (pageNumber > 1) {
      final previousPageSnapshot =
          await orderedQuery.limit((pageNumber - 1) * pageSize).get();

      if (previousPageSnapshot.docs.isNotEmpty) {
        lastDocument = previousPageSnapshot.docs.last;

        if (filter != null) {
          // Fetch paged documents
          querySnapshot = await orderedQuery
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .get();
        } else {
          // Fetch paged documents wtih filter
          querySnapshot = await orderedQuery
              .startAfterDocument(lastDocument)
              .limit(pageSize)
              .where('title', arrayContains: filter)
              .get();
        }
      } else {
        if (filter != null) {
          querySnapshot = await orderedQuery
              .limit(pageSize)
              .where('title', arrayContains: filter)
              .get();
        } else {
          querySnapshot = await orderedQuery.limit(pageSize).get();
        }
      }
    } else {
      if (filter != null) {
        querySnapshot = await orderedQuery
            .limit(pageSize)
            .where('title', arrayContains: filter)
            .get();
      } else {
        querySnapshot = await orderedQuery.limit(pageSize).get();
      }
    }

    for (final doc in querySnapshot.docs) {
      final id = doc.get('id') as String;
      final title = doc.get('title') as String;
      final iconName = doc.get('icon') as String;
      final icon = IconsExtension.getIconData(iconName);
      final widgetType = doc.get('widgetType') as String;
      final documentIdData = doc.get('documentIdData') as String;
      widgets.add(WidgetsInfo(
          id: id,
          title: title,
          icon: icon,
          widgetType: widgetType,
          currentPage: 0,
          documentIdData: documentIdData));
    }

    // Calculate total number of documents
    final totalItemsSnapshot = await orderedQuery.get();
    var totalItems = totalItemsSnapshot.size;

    // Calculate total pages
    int totalPages = (totalItems / pageSize).ceil();

    GetWidgetsResponse widgetsResponse =
        GetWidgetsResponse(widgetsInfoList: widgets, totalPages: totalPages);

    return widgetsResponse;
  }

  Future addWidgets(CollectionReference widgetsCollection, BuildContext context, String title, String icon,
      String widgetType) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sending Data to Cloud Firestore"),
      ),
    );

    var doc = widgetsCollection.doc();
    WidgetsEntity widgetToAdd = WidgetsEntity(
        id: doc.id,
        title: title,
        icon: icon,
        widgetType: widgetType,
        documentIdData: "$title${doc.id}");
    await doc
        .set(widgetToAdd.toJson())
        // ignore: avoid_print
        .then((value) => print('Widget Added'))
        // ignore: avoid_print
        .catchError((error) => print('Failed to add Widget: $error'));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AppRouter(currentWidget: currentWidget!),
    ));
  }

  Future saveWidgetToFireStore(
      CollectionReference collectionReference,
      WidgetsInfo widget,
      BuildContext context,
      String title,
      String icon) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sending Data to Cloud Firestore"),
      ),
    );

    await collectionReference
        .doc(widget.id.toString())
        .update({
          'id': widget.id,
          'title': title,
          'icon': icon,
          'widgetType': widget.widgetType,
          'documentIdData': widget.documentIdData
        })
        .then((value) => //Return to contacts page
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AppRouter(currentWidget: currentWidget!),
            )))
        // ignore: avoid_print
        .catchError((error) => print('Failed to update widget: $error'));
  }
}

class GetWidgetsResponse {
  final List<WidgetsInfo>? widgetsInfoList;
  final int? totalPages;

  const GetWidgetsResponse({
    required this.widgetsInfoList,
    required this.totalPages,
  });
}
