import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../shared/constant.dart';
import '../../shared/tile_list.dart';
import 'change_password.dart';
import 'delete_account.dart';
import 'forgot_password_mailadress.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentindex = 3;
  int _selectedindex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color3,
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Theme.of(context).scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentindex,
        unselectedIconTheme: IconThemeData(color: bleu_bg),
        selectedIconTheme: IconThemeData(color: vert),
        items: [
          BottomNavigationBarItem(
            label: "",
            icon: Icon(
              Iconsax.home_2,
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(
              Iconsax.home_2,
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(
              Iconsax.home_2,
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(
              Iconsax.user,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedindex = index;
          });

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return tab[_selectedindex];
            }),
          );
        },
      ),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Iconsax.back_square,
            color: vert,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Profile();
                },
              ),
            );
          },
          color: vert,
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: bleu_bg,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.info_circle,
              color: orange,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Listbox(
              title: "Write to us",
              iconleading: Icon(
                Icons.email_outlined,
                color: vert,
              ),
              onPressed: () async {
                String emailUrl =
                    'mailto:lm_zoubir@esi.dz?subject=This is Subject Title&body=This is Body of Email';
                if (await canLaunchUrlString(emailUrl)) {
                  await launchUrlString(emailUrl);
                } else {
                  throw 'Could not launch $emailUrl';
                }
              },
            ),
            Listbox(
              title: "Call us",
              iconleading: Icon(
                Iconsax.call,
                color: vert,
              ),
              onPressed: () async {
                final Uri url = Uri(
                  scheme: 'tel',
                  path: "+213796902422",
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            Listbox(
              title: "Language",
              iconleading: Icon(
                Iconsax.language_square,
                color: vert,
              ),
              onPressed: () {},
            ),
            Listbox(
                title: "Change my password",
                iconleading: Icon(
                  Iconsax.key,
                  color: vert,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangePasswordInfo()));
                }),
            Listbox(
                title: "Delete my account",
                iconleading: Icon(
                  Iconsax.trush_square,
                  color: vert,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DeleteAccountPassword()));
                }),
          ],
        ),
      ),
    );
  }
}
