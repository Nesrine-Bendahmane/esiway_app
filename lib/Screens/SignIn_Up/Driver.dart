// ignore_for_file: file_names, unused_local_variable, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_element

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esiway/Screens/Profile/profile_screen.dart';
import 'package:esiway/widgets/icons_ESIWay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../widgets/Tripswidget/tripsTitle.dart';
import '../../widgets/constant.dart';
import '../../widgets/prefixe_icon_button.dart';
import '../../widgets/suffixe_icon_button.dart';
import '../../widgets/text_field.dart';
import '../../widgets/text_validation.dart';

class Driver extends StatefulWidget {
  const Driver({super.key});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> with UserValidation {
  @override
  bool modelvalidate = true;
  bool brandvalidate = true;
  bool registrationnumbervalidate = true;

  File? policy;
  File? carpicture;

  String? policyURL;
  String? carpictureURL;

  // This is the image picker
  final _picker = ImagePicker();
  // Implementing the image picker
  Future<void> _openImagePicker(String type, source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        if (type == "policy")
          policy = File(pickedImage.path);
        else
          carpicture = File(pickedImage.path);
      });
    }
  }

  TextEditingController modelcontroller = TextEditingController();
  TextEditingController brandcontroller = TextEditingController();
  TextEditingController registrationNumbercontroller = TextEditingController();

  void back() {
    Navigator.of(context).pop();
  }

  updateCar() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("Cars").doc(uid).set({
        "brand": brandcontroller.text,
        "model": modelcontroller.text,
        "registrationNumber": registrationNumbercontroller.text,
        "CarPicture": carpictureURL,
        "Policy": policyURL,
      });
      await FirebaseFirestore.instance.collection("Users").doc(uid).update({
        "hasCar": true,
      }).then((value) =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Profile();
          })));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          duration: Duration(
            seconds: 3,
          ),
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          padding: EdgeInsets.all(12),
          behavior: SnackBarBehavior.floating,
          elevation: 2,
          content: Center(
            child: Text(
              "${e.toString()}",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: "Montserrat",
              ),
            ),
          )));
    }
  }

  bool carPicrtureExist() {
    return (carpicture != null);
  }

  bool policyExist() {
    return (policy != null);
  }

  @override
  Widget build(BuildContext context) {
    var largeur = MediaQuery.of(context).size.width;
    var hauteur = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("Assets/Images/background3.png"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                          ),
                          width: 80,
                          height: 35,
                          child: PrefixeIconButton(
                              size: const Size(73, 34),
                              color: Colors.white,
                              radius: 8,
                              text: "Back",
                              textcolor: Color(0xFF20236C),
                              weight: FontWeight.w600,
                              fontsize: 14,
                              icon: Transform.scale(
                                scale: 0.75,
                                child: Icons_ESIWay(
                                    icon: "arrow_left",
                                    largeur: 30,
                                    hauteur: 30),
                              ),
                              espaceicontext: 5.0,
                              fct: back),
                        ),
                        SizedBox(
                          height: hauteur * 0.22,
                        ),
                        const Text(
                          'Car',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: Color(0xFF20236C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.topLeft,
                child: const Text(
                  'information',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Color(0xFF20236C),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //*****************************************************************************/

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          // optional flex property if flex is 1 because the default flex is 1
                          flex: 1,
                          child: Text_Field(
                            title: "Brand",
                            validate: brandvalidate,
                            error: "Value can't be Empty",
                            hinttext: 'Peugeot',
                            iconName: "car",
                            textfieldcontroller: brandcontroller,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          // optional flex property if flex is 1 because the default flex is 1
                          flex: 1,
                          child: Text_Field(
                            title: "Model",
                            validate: modelvalidate,
                            error: "Value can't be Empty",
                            hinttext: '206',
                            iconName: "car",
                            textfieldcontroller: modelcontroller,
                          ),
                        )
                      ],
                    ),

                    //*****************************************************************************/

                    Text_Field(
                      title: "Registration Number",
                      validate: registrationnumbervalidate,
                      error: "Value can't be Empty",
                      type: TextInputType.number,
                      hinttext: '00984-118-16',
                      iconName: "home",
                      textfieldcontroller: registrationNumbercontroller,
                    ),

                    //*****************************************************************************/

                    CustomTitle(
                      title: "Car's picture",
                      titleSize: 13,
                    ),

                    carpicture != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  //to show image, you type like this.
                                  File(carpicture!.path),
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                )),
                          )
                        : SizedBox(
                            height: 2,
                          ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.002,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(color6),
                            ),
                            onPressed: () =>
                                _openImagePicker("car", ImageSource.gallery),
                            icon: Transform.scale(
                              scale: 0.5,
                              child: Icons_ESIWay(
                                  icon: "upload", largeur: 35, hauteur: 35),
                            ),
                            label: Text(
                              "Upload",
                              style: TextStyle(
                                color: bleu_bg,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(color6),
                            ),
                            onPressed: () =>
                                _openImagePicker("car", ImageSource.camera),
                            icon: Transform.scale(
                              scale: 0.5,
                              child: Icons_ESIWay(
                                  icon: "camera", largeur: 35, hauteur: 35),
                            ),
                            label: Text(
                              "Take",
                              style: TextStyle(
                                color: bleu_bg,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009,
                    ),
                    //*****************************************************************************/

                    CustomTitle(
                      title: "Insurance policy",
                      titleSize: 13,
                    ),

                    policy != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  //to show image, you type like this.
                                  File(policy!.path),
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                )),
                          )
                        : SizedBox(
                            height: 2,
                          ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.002,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(color6),
                            ),
                            onPressed: () =>
                                _openImagePicker("policy", ImageSource.gallery),
                            icon: Transform.scale(
                              scale: 0.5,
                              child: Icons_ESIWay(
                                  icon: "upload", largeur: 35, hauteur: 35),
                            ),
                            label: Text(
                              "Upload",
                              style: TextStyle(
                                color: bleu_bg,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SuffixeIconButton(
                        size: Size(largeur, hauteur * 0.06),
                        color: const Color(0xFFFFA18E),
                        radius: 10,
                        text: "Next",
                        textcolor: Color(0xFF20236C),
                        weight: FontWeight.w700,
                        fontsize: 20,
                        icon: const Icon(
                          Icons.arrow_right_rounded,
                          color: Color(0xff20236C),
                          size: 40,
                        ),
                        espaceicontext: 0.0,
                        fct: () async {
                          if (isCar(brandcontroller.text) == false)
                            setState(() {
                              brandvalidate = false;
                            });
                          else {
                            setState(() {
                              brandvalidate = true;
                            });
                          }
                          if (isCar(modelcontroller.text) == false)
                            setState(() {
                              modelvalidate = false;
                            });
                          else {
                            setState(() {
                              modelvalidate = true;
                            });
                          }

                          if (isRegistrationNumber(
                                  registrationNumbercontroller.text) ==
                              false)
                            setState(() {
                              registrationnumbervalidate = false;
                            });
                          else {
                            setState(() {
                              registrationnumbervalidate = true;
                            });
                            User? currentuser =
                                FirebaseAuth.instance.currentUser;

                            if (registrationnumbervalidate &&
                                modelvalidate &&
                                brandvalidate &&
                                carPicrtureExist() &&
                                policyExist()) {
                              if (carpicture != null) {
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('Cars');
                                //Create a reference for the image to be stored
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(currentuser!.uid);

                                try {
                                  //Store the file
                                  await referenceImageToUpload
                                      .putFile(File(carpicture!.path));
                                  //Success: get the download URL

                                  carpictureURL = await referenceImageToUpload
                                      .getDownloadURL();
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor: Colors.white,
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 30, horizontal: 20),
                                          padding: EdgeInsets.all(12),
                                          behavior: SnackBarBehavior.floating,
                                          elevation: 2,
                                          content: Center(
                                            child: Text(
                                              "${error.toString()}",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontFamily: "Montserrat",
                                              ),
                                            ),
                                          )));
                                }
                              }
                              if (policy != null) {
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('Policy');
                                //Create a reference for the image to be stored
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(currentuser!.uid);

                                try {
                                  //Store the file
                                  await referenceImageToUpload
                                      .putFile(File(policy!.path));
                                  //Success: get the download URL

                                  policyURL = await referenceImageToUpload
                                      .getDownloadURL();
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor: Colors.white,
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 30, horizontal: 20),
                                          padding: EdgeInsets.all(12),
                                          behavior: SnackBarBehavior.floating,
                                          elevation: 2,
                                          content: Center(
                                            child: Text(
                                              "${error.toString()}",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontFamily: "Montserrat",
                                              ),
                                            ),
                                          )));
                                }
                              }

                              updateCar();
                            } else if (!carPicrtureExist() || !policyExist()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.white,
                                      duration: Duration(
                                        seconds: 3,
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 20),
                                      padding: EdgeInsets.all(12),
                                      behavior: SnackBarBehavior.floating,
                                      elevation: 2,
                                      content: Center(
                                        child: Text(
                                          "Car picture and Insurance policy picture are obligatory",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontFamily: "Montserrat",
                                          ),
                                        ),
                                      )));
                            }
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not ready now?',
                          style: TextStyle(
                            fontFamily: 'Montserrat-',
                            color: Color(0xff20236C),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Profile()));
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              color: Color(0xff20236C),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
