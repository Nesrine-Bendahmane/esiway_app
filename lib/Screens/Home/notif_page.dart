import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esiway/Auth.dart';
import 'package:esiway/Screens/Chat/ChatServices.dart';
import 'package:esiway/widgets/accept_notif.dart';
import 'package:esiway/widgets/notif.dart';
import 'package:esiway/widgets/refuse_notif.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({Key? key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  @override
  Widget build(BuildContext context) {
    final currentUserUID = AuthService()
        .auth
        .currentUser!
        .uid; // Replace with your logic to get the current user's UID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: Column(
        children: [
          const Text(
            'My List:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notifications')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final document = documents[index];

                        // Exclude notifications with the current user's UID
                        if (document['uid'] != currentUserUID) {
                          return SizedBox
                              .shrink(); // Return an empty widget to skip rendering
                        }

                        // Retrieve user_name from the 'Users' collection based on a condition
                        return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(document['uid'])
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              }

                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              }

                              final userDocument = userSnapshot.data!;
                              final user_name = userDocument['Name'];
                              final profilePictureExists =
                                  userDocument['ProfilePicture'] != "null";
                              final profilePicture = profilePictureExists
                                  ? userDocument['ProfilePicture']
                                  : 'Assets/Images/appicon2.png';

                              return document['type'] == 0
                                  ? AcceptB(
                                      user_name: user_name ?? '',
                                      path: profilePicture,
                                    )
                                  : (document['type'] == 1
                                      ? RefuseB(
                                          user_name: user_name ?? '',
                                        )
                                      : Notif(user_name: user_name ?? ''));
                            });
                      });
                }),
          ),
        ],
      ),
    );
  }
}
