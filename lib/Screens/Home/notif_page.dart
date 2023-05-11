import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esiway/Screens/Profile/profile_screen.dart';
import 'package:esiway/widgets/accept_notif.dart';
import 'package:esiway/widgets/constant.dart';
import 'package:esiway/widgets/icons_ESIWay.dart';
import 'package:esiway/widgets/login_text.dart';
import 'package:esiway/widgets/notif.dart';
import 'package:esiway/widgets/notif_list.dart';
import 'package:esiway/widgets/our_prefixeIconButton.dart';
import 'package:esiway/widgets/refuse_notif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class Notifpage extends StatefulWidget {
  //List<Map<String, dynamic>>? dataNotif = [];
  Notifpage({Key? key}) : super(key: key);

  @override
  State<Notifpage> createState() => _NotifpageState();
}

class _NotifpageState extends State<Notifpage> {
  @override
  void initState() {
    super.initState();
    readCollection();
  }

  List<Map<String, dynamic>>? dataList = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> readCollection() async {
    print(dataList);
    try {
      QuerySnapshot snapshot =
          await firestore.collection('Notifications').get();

      List<DocumentSnapshot> docs = snapshot.docs;
      dataList =
          docs.map((doc) => doc.data()).cast<Map<String, dynamic>>().toList();

      // Set the state to rebuild the widget and display the retrieved data
    } catch (e) {
      print('Error reading collection: $e');
    }
  }

  final String today = 'Today';

  final String month = 'This month';

  final String notif = 'Notifications';

  /*   Container(
      margin: EdgeInsets.only(left: 32),
      child: Text(
        'Today',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: bleu_bg,
            fontFamily: 'mont'),
      ),
    ), */

  @override
  Widget build(BuildContext context) {
    var largeur = MediaQuery.of(context).size.width;
    var hauteur = MediaQuery.of(context).size.height;
    //   addToEndOfArray('newElemen 1');

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Transform.scale(
            scale: 0.9,
            child: Icons_ESIWay(icon: "arrow_left", largeur: 50, hauteur: 50),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return HomePage();
                },
              ),
            );
          },
          color: vert,
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: bleu_bg,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: /* SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: largeur * 0.05, top: hauteur * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    OurPrefixeIconButton(
                        size: const Size(73, 34),
                        color: Colors.white,
                        radius: 10,
                        text: "Back",
                        textcolor: const Color(0xFF20236C),
                        weight: FontWeight.w600,
                        fontsize: 14,
                        iconName: "arrow_left",
                        espaceicontext: 0.0,
                        fct: () {}),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 20),
                child: Row(
                  children: [
                    MyText(
                      text: notif,
                      weight: FontWeight.bold,
                      fontsize: 24,
                      color: bleu_bg,
                      largeur: 0.5 * largeur,
                    )
                  ],
                ),
                //   ),

                // Text(
                //   textAlign: TextAlign.start,
                //   'Notifcations',
                //   style: TextStyle(
                //       fontSize: 24,
                //       fontWeight: FontWeight.bold,
                //       color: BLUE,
                //       fontFamily: 'mont'),
              ),
              MyWidget(
                notiflist: notifList,
              ),
              /////////////////////////////////////////////////////////////////
            ],
          ),
        ),
      ), */
          Column(
        children: [
          // other widgets
          Expanded(
            child: ListView.builder(
              itemCount: dataList?.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = dataList![index];
                return Notif();
              },
            ),
          ),
        ],
      ),
      /*  dataList!.isNotEmpty
              ? ListView.builder(
                  itemCount: dataList!.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = dataList![index];
                    print("object ==== ${data['type']}");
                    return (data['type'] == 0)
                        ? AcceptB()
                        : ((data['type'] == 1) ? RefuseB() : Notif());
                  },
                )
              : Center(child: CircularProgressIndicator()), */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          readCollection();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
