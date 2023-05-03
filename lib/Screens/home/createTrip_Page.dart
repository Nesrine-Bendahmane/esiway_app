import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esiway/widgets/prefixe_icon_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../../../widgets/icons_ESIWay.dart';
import '../../../widgets/login_text.dart';
import '../../../widgets/simple_button.dart';
import 'home_page.dart';



class CreateTripPage extends StatefulWidget {
  Set<Marker> markers = Set(); //markers for google map
  GoogleMapController? mapController; //controller for Google map
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};//polylines to show direction
  double distance = 0.0;

  CreateTripPage({
    super.key,
    required this.markers,
    required this.mapController,
    required this.polylinePoints,
    required this.polylines,
    required this.distance,
});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {


  void initState() {
    // TODO: implement initState

    date = "${selectedDate.day} / ${selectedDate.month} / ${selectedDate.year}";
    minute = TimeNow.minute >= 10 ? "${TimeNow.minute}" : "0${TimeNow.minute}";
    hour = TimeNow.hour >= 10 ? "${TimeNow.hour}" : "0${TimeNow.hour}";
    time = hour! + " : " + minute!;


    super.initState();
  }

//======================================================================================================//
//=========================================| Variables |================================================//
//======================================================================================================//

  /// +Fire base (pour stocker dans firebase on choisit la collection Trips)
  final docTrips = FirebaseFirestore.instance.collection("Trips");
  final auth = FirebaseAuth.instance; // pour l'utilisateur
  DocumentReference DocRef = FirebaseFirestore.instance.collection("Trips").doc("Prefrences");
  /// +Map variables
  Set<Marker> markers = Set(); //markers for google map
  GoogleMapController? mapController; //controller for Google map
  PolylinePoints polylinePoints = PolylinePoints();
  PointLatLng debut =const PointLatLng(36.72376684085901, 2.991892973393687);
  PointLatLng fin =const PointLatLng(36.64364699576445, 2.9943386163692787);
  Map<PolylineId, Polyline> polylines = {};//polylines to show direction
  double distance = 0.0;
  static LatLng startLocation = const LatLng(36.705219106281575, 3.173786850126649);
  LatLng endLocation = const LatLng(36.687677024859354, 2.9965016961469324);
  LatLng? location;
  String? locationName;
  String? locationNamea;

  String paimentMethode="";
  String methode = "";
  DateTime selectedDate = DateTime.now();
  static bool bags =false;
  static bool talking = false;
  static bool animals =false ;
  static bool smoking = false;
  static bool others = false;
  String? seats;


  String? date;
  String? time;
  String? minute;
  String? hour;
  TimeOfDay TimeNow = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  TextEditingController pricecontroller = TextEditingController();


//======================================================================================================//
//=========================================| Functions |================================================//
//======================================================================================================//

  ///=============================| Map Functions|===================================//

  ///+++++++++++++++++++++++++++++< ajouter Markers >+++++++++++++++++++++++++++///
  ajouterMarkers(PointLatLng point) async{
    widget.markers.add(Marker( //add start location marker
      markerId: MarkerId(LatLng(point.latitude,point.longitude).toString()),
      position: LatLng(point.latitude,point.longitude), //position of marker
      infoWindow: const InfoWindow( //popup info
        title: 'Starting Point ',
        snippet: 'Staaaaaaaaaaaaaaaaaaaart Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));
  }
  ///-----------------------------< get Direction (draw polyline between two point and put markers) >---------------------------///
  getDirection(PointLatLng depart, PointLatLng arrival) async {
    List<LatLng> polylineCoordinates = [];
    List<String> cities = [];

    PolylineResult result = await  widget.polylinePoints.getRouteBetweenCoordinates(
      APIKEY,
      depart,
      arrival,
      //  travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) async {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    /*print('lenght ==');
    print({polylineCoordinates.length} );
    for (var i = 0; i < polylineCoordinates.length - 1; i+10) {
      print('Test');
      List<Placemark> placemarks = await placemarkFromCoordinates(polylineCoordinates[i].latitude,polylineCoordinates[i].longitude);
      String? city = placemarks[0].locality;
      cities.add(city!);
    }*/

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    setState(() {
      widget.distance = totalDistance;
    });

    addPolyLine(polylineCoordinates);
    print("cities = ");
    print(cities);
  }
  ///+++++++++++++++++++++++++++++< Add Polyline >++++++++++++++++++++++++++++++///
  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    widget.polylines[id] = polyline;
    setState(() {});
  }
  ///++++++++++++++++< Calculer la distance entre deux point >++++++++++++++++++///
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  ///+++++++++++++++++++++++< Position actuel >+++++++++++++++++++++++++++++++++///
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("location services are disabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("location permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission are permently denied");
    }
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
  Future<void> currentLocation(PointLatLng point)async{

    Position positione = await determinePosition();
    point = PointLatLng(positione.latitude, positione.longitude);
  }




  ///+++++++++++++++++++++++< Time Picker >+++++++++++++++++++++++++++++++++///
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      initialTime: TimeNow,
      context: context,
    );
    if (picked != null) {
      setState(() {
        TimeNow = picked;
        minute =
        TimeNow.minute >= 10 ? "${TimeNow.minute}" : "0${TimeNow.minute}";
        hour = TimeNow.hour >= 10 ? "${TimeNow.hour}" : "0${TimeNow.hour}";
        time = hour! + " : " + minute!;
      });
    }
  }
 ///+++++++++++++++++++++++< Date Picker >+++++++++++++++++++++++++++++++++///
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        date = "${selectedDate.day} - ${selectedDate.month} - ${selectedDate.year}";
      });
    }
  }

  void toHome(){setState(() { Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));});}
  
  Future<void> createTrip(String conducteur, PointLatLng one, PointLatLng two, String depart, String arrivee, String date, String heure, String price, String places, String methode) async {
    final json = {
      "Conducteur": conducteur,
      "Depart_LatLng": "$one",
      "Arrivee_LatLng": "$two",
      "Depart": depart,
      "Arrivee": arrivee,
      "Date": "$date",
      "Heure": "$heure",
      "Price": price,
      "Places": places,
      "methode": methode,
      //prefrences
    };

    if( locationNamea == "Current Location"){
      Position positione = await determinePosition();
      fin = PointLatLng(positione.latitude, positione.longitude);
    };
    if( locationName == "Current Location"){
      Position positione = await determinePosition();
      debut = PointLatLng(positione.latitude, positione.longitude);
    };

    await docTrips.doc(auth.currentUser?.uid).set(json);
    setState(() {});
    getDirection(one,two);//fetch direction polylines from Google API
    ajouterMarkers(one);
    ajouterMarkers(two);
     widget.mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(one.latitude,one.longitude), zoom: 17)));
  }



  @override
  Widget build(BuildContext context) {

    var largeur = MediaQuery.of(context).size.width;
    var hauteur = MediaQuery.of(context).size.height;
    var dropdownValue = "-1"; // drop down value

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(//innital position in map
              target: startLocation, //initial position
              zoom: 14.0, //initial zoom level
            ),
             markers:  widget.markers, //markers to show on map
            polylines: Set<Polyline>.of(widget.polylines.values), //polylines
            mapType: MapType.normal, //map type
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {widget.mapController = controller;});
            },
          ),
          Positioned(
            bottom:0,
            child:  SizedBox(
              width: largeur,
              height: hauteur*0.7125,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: const Color(0xFFF9F8FF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: largeur * 0.075),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: hauteur * 0.01),

                            /// "Depature"
                            SizedBox(
                                width: largeur * 0.55,
                                height: hauteur * 0.025,
                                child:  MyText(
                                    text: "Departure",
                                    weight: FontWeight.w700,
                                    fontsize: 14,
                                    color: const Color(0xff20236C),
                                    largeur: largeur * 0.55)),
                            SizedBox(height: hauteur * 0.005),

                            /// +Departure Filed
                            Container(
                              width: largeur * 0.9,
                              height: hauteur * 0.0625,
                              decoration:  BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, color: bleu_bg.withOpacity(0.15),offset: Offset(0,0), spreadRadius: 10)],color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(4))),
                              child:Row(
                                children: [
                                  ///Search places
                                  InkWell(
                                   onTap: () async {
                                      var place = await PlacesAutocomplete.show(
                                          context: context,
                                          apiKey: APIKEY,
                                          mode: Mode.overlay,
                                          types: [],
                                          strictbounds: false,
                                          components: [Component(Component.country, 'dz')],
                                         //google_map_webservice package
                                          onError: (err){
                                          print(err);
                                          }
                                        );
                                   if(place != null){
                                    setState(() {
                                    locationName = place.description.toString();
                                    print( locationName);
                                     });

                    //form google_maps_webservice package
                                    final plist = GoogleMapsPlaces(apiKey:APIKEY, apiHeaders: await const GoogleApiHeaders().getHeaders());
                                    String placeid = place.placeId ?? "0";
                                    final detail = await plist.getDetailsByPlaceId(placeid);
                                    final geometry = detail.result.geometry!;
                                    final lat = geometry.location.lat;
                                    final lang = geometry.location.lng;
                                    var newlatlang = LatLng(lat, lang);
                                    location = newlatlang;
                                    debut = PointLatLng(newlatlang.latitude, newlatlang.longitude);
                                    //move map camera to selected place with animation
                                     widget.mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                                     };
                                    setState(() {});
                                  },
                                    child: Row(
                                        children: [
                                          SizedBox(width: largeur*0.02),
                                          Icons_ESIWay(icon: 'search', largeur: largeur*0.08, hauteur: largeur*0.08),
                                          SizedBox(width: largeur*0.02),
                                          SizedBox(width:largeur*0.57,child: AutoSizeText(locationName??"Search places", style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: bleu_bg, fontSize: 12,),maxLines: 2,)),
                                        ],
                                      ),


                                  ),
                                  /// ESI
                                  InkWell(
                                      onTap: (){
                                    setState(() {
                                      locationName = "Ecole Nationale Supérieure d'Informatique (Ex. INI)";
                                      debut = PointLatLng(LocationEsi.latitude, LocationEsi.longitude);
                                    });
                                  },
                                      child: Image(image: AssetImage("Assets/Images/esi_logo.png"),width: largeur*0.06,height: hauteur*0.06)),
                                  // Icon(Icons.my_location,color:bleu_bg,size: largeur*0.06,),
                                  SizedBox(width: largeur*0.015,),
                                  ///Current location
                                  InkWell(
                                      onTap: (){setState(()  {locationName = "Current Location";});},
                                      child: Icon(Icons.my_location,color:bleu_bg,size: largeur*0.06,)),
                                ],
                              ),
                            ),
                            SizedBox(height: hauteur * 0.02),

                            ///  "Arival"
                            SizedBox(
                                width: largeur * 0.139,
                                height: hauteur * 0.025,
                                child: MyText(
                                    text: "Arrival",
                                    weight: FontWeight.w700,
                                    fontsize: 14,
                                    color: const Color(0xff20236C),
                                    largeur: largeur * 0.139,)),
                            SizedBox(height: hauteur * 0.005),

                            /// +Arrival Filed
                            Container(
                              width: largeur * 0.9,
                              height: hauteur * 0.0625,
                              decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 20, color: bleu_bg.withOpacity(0.15),offset: Offset(0,0), spreadRadius: 10)],color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(4))),
                            child:Row(
                              children: [
                                ///Search places
                                InkWell(

                                  onTap: () async {
                                    var place = await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey: APIKEY,
                                        mode: Mode.overlay,
                                        types: [],
                                        strictbounds: false,
                                        components: [Component(Component.country, 'dz')],
                                        //google_map_webservice package
                                        onError: (err){print(err);}
                                    );
                                    if(place != null){
                                      setState(() {
                                        locationNamea = place.description.toString();
                                        print( locationNamea);
                                      });

                                      //form google_maps_webservice package
                                      final plist = GoogleMapsPlaces(apiKey:APIKEY, apiHeaders: await const GoogleApiHeaders().getHeaders());
                                      String placeid = place.placeId ?? "0";
                                      final detail = await plist.getDetailsByPlaceId(placeid);
                                      final geometry = detail.result.geometry!;
                                      final lat = geometry.location.lat;
                                      final lang = geometry.location.lng;
                                      var newlatlang = LatLng(lat, lang);
                                      location = newlatlang;
                                      fin = PointLatLng(newlatlang.latitude, newlatlang.longitude);
                                      //move map camera to selected place with animation
                                      widget.mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                                    };
                                    setState(() {});
                                  },
                                  child: Row(
                                      children: [
                                        SizedBox(width: largeur*0.02),
                                        Icons_ESIWay(icon: 'search', largeur: largeur*0.08, hauteur: largeur*0.08),
                                        SizedBox(width: largeur*0.02),
                                        SizedBox(width:largeur*0.57,child: AutoSizeText(locationNamea??"Search places", style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: bleu_bg, fontSize: 12,),maxLines: 2,)),
                                      ],
                                    ),


                                ),
                                /// ESI
                                InkWell(
                                    onTap: (){
                                    setState(() {
                                      locationNamea = "Ecole Nationale Supérieure d'Informatique (Ex. INI)";
                                      fin = PointLatLng(LocationEsi.latitude, LocationEsi.longitude);
                                    });
                                    },
                                    child: Image(image: AssetImage("Assets/Images/esi_logo.png"),width: largeur*0.06,height: hauteur*0.06)),
                                SizedBox(width: largeur*0.015,),
                                ///Current location
                                InkWell(
                                    onTap: (){setState((){locationNamea = "Current Location";});},
                                    child: Icon(Icons.my_location,color:bleu_bg,size: largeur*0.06,)),
                              ],
                            ),
                            ),

                            SizedBox(height: hauteur * 0.02),

                            /// +Date & Hour
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    /// "Date"
                                    SizedBox(
                                        width: largeur * 0.11,
                                        height: hauteur * 0.025,
                                        child:  MyText(text: "Date", weight: FontWeight.w700, fontsize: 14, color: const Color(0xff20236C), largeur: largeur * 0.11,)),
                                    SizedBox(height: hauteur * 0.005),

                                    /// +Date Filed
                                    GestureDetector(
                                      onTap: ()async{_selectDate(context);},
                                      child:  SizedBox(
                                        height: hauteur * 0.0625,
                                        width: largeur * 0.5,
                                        child: Container(
                                            decoration:  BoxDecoration(boxShadow: const [BoxShadow(blurRadius: 18, color: Color.fromRGBO(32, 35, 108, 0.15))],color: Colors.white,borderRadius: BorderRadius.circular(5)),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const SizedBox(width: 5,),
                                                Transform.scale(
                                                  scale:1.5,  // to make the icon smaller or larger
                                                  child:  const Icons_ESIWay(icon: "calendar", largeur: 20, hauteur: 20),
                                                ),

                                                MyText(text: date!, weight: FontWeight.w500, fontsize: 14, color: const Color(0xFF20236C), largeur: largeur*0.2,),
                                                const SizedBox(width: 5,),

                                              ],
                                            )
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// "Heure"
                                    SizedBox(
                                        width: largeur * 0.13,
                                        height: hauteur * 0.025,
                                        child:  MyText(
                                            text: "Heure",
                                            weight: FontWeight.w700,
                                            fontsize: 14,
                                            color:
                                            const Color(0xff20236C),
                                        largeur:largeur * 0.13 ,)),
                                    SizedBox(height: hauteur * 0.005),

                                    /// +Heure Filed
                                    GestureDetector(
                                      onTap: ()async{_selectTime(context);},
                                      child:  SizedBox(
                                        height: hauteur * 0.0625,
                                        width: largeur * 0.3,
                                        child: Container(
                                            decoration:  BoxDecoration(boxShadow: const [BoxShadow(blurRadius: 18, color: Color.fromRGBO(32, 35, 108, 0.15))],color: Colors.white,borderRadius: BorderRadius.circular(5)),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Transform.scale(
                                                  scale:1.5,  // to make the icon smaller or larger
                                                  child:  const Icons_ESIWay(icon: "timer", largeur: 20, hauteur: 20),
                                                ),
                                                MyText(text: time!, weight: FontWeight.w500, fontsize: 14, color: const Color(0xFF20236C), largeur: largeur*0.15),

                                              ],
                                            )
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: hauteur * 0.02),
                              ],
                            ),
                            SizedBox(height: hauteur * 0.02),


                            ///  "Paiment"
                            SizedBox(
                                width: largeur * 0.2,
                                height: hauteur * 0.025,
                                child: MyText(
                                    text: "Paiment",
                                    weight: FontWeight.w700,
                                    fontsize: 14,
                                    color: const Color(0xff20236C),
                                    largeur: largeur * 0.2,)),
                            SizedBox(height: hauteur * 0.005),

                            /// +Paiment Field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: largeur*0.3,
                                  height: hauteur*0.0625,
                                  decoration:  BoxDecoration(boxShadow: const [BoxShadow(blurRadius: 18, color: Color.fromRGBO(32, 35, 108, 0.15))],color: Colors.white,borderRadius:BorderRadius.circular(5) ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child:TextField(
                                          controller: pricecontroller,
                                          decoration: const InputDecoration(hintText: "Price", hintStyle:  TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 14), focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, disabledBorder:  InputBorder.none, filled: false,),
                                        ),
                                      ),
                                      const AutoSizeText("Da",style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: const Color(0xff20236C), fontSize: 14)),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                /// methode
                                Container(
                                  width: largeur*0.51,
                                  height: hauteur*0.0625,
                                  decoration:  BoxDecoration(boxShadow: const [BoxShadow(blurRadius: 18, color: Color.fromRGBO(32, 35, 108, 0.15))],color: Colors.white,borderRadius:BorderRadius.circular(5)),
                                  child: DropdownButtonFormField(
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_drop_down_rounded,color: Color(0xFF72D2C2)),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white)),
                                      focusedBorder: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "-1",
                                        child: Text("choose a method ", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),
                                      ),
                                      DropdownMenuItem(
                                        value: "1",
                                        child: AutoSizeText("Negociable", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),

                                      ),
                                      DropdownMenuItem(
                                        value: "2",
                                        child:
                                        AutoSizeText("Service", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),

                                      ),

                                    ],
                                    onChanged: (value) {
                                      if (value == "1") { methode = "Negociable";};
                                      if (value == "2") {methode = "Service";};
                                      print(methode);
                                    },
                                  ),
                                ),


                              ],
                            ),
                            SizedBox(height: hauteur * 0.02),

                            ///Preferences
                            SizedBox(
                                width: largeur * 0.266,
                                height: hauteur * 0.025,
                                child: MyText(
                                    text: "Preferences",
                                    weight: FontWeight.w700,
                                    fontsize: 14,
                                    color: const Color(0xff20236C),
                                    largeur: largeur * 0.266)),
                            SizedBox(height: hauteur * 0.005),

                            /// +Preferences Field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                              children: [
                                SimpleButton(backgroundcolor: bags ?bleu_ciel :Colors.white , size: Size(largeur*0.2, hauteur*0.00875), radius: 3, text: "Bags", textcolor: bleu_bg, fontsize: 12, fct:(){bags=!bags;setState(() {});},blur: 18),
                                SimpleButton(backgroundcolor: talking ?bleu_ciel :Colors.white  , size: Size(largeur*0.277, hauteur*0.00875), radius: 3, text: "Talking", textcolor: bleu_bg, fontsize: 12, fct:(){(talking=!talking);setState(() {});},blur: 18),
                                SimpleButton(backgroundcolor: animals ?bleu_ciel :Colors.white  , size: Size(largeur*0.277, hauteur*0.00875), radius: 3, text: "Animals", textcolor: bleu_bg, fontsize: 12, fct:(){(animals=!animals);setState(() {});},blur: 18),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SimpleButton(backgroundcolor: smoking ?bleu_ciel :Colors.white  , size: Size(largeur*0.277, hauteur*0.00875), radius: 3, text: "Smoking", textcolor: bleu_bg, fontsize: 12, fct:(){(smoking=!smoking);setState(() {});},blur: 18),
                                SizedBox(width: largeur*0.07),
                                SimpleButton(backgroundcolor: others ?bleu_ciel :Colors.white , size: Size(largeur*0.277, hauteur*0.00875), radius: 3, text: "Other", textcolor: bleu_bg, fontsize: 12, fct:(){(others=!others);setState(() {});},blur: 18),
                              ],
                            ),
                            SizedBox(height: hauteur * 0.01),

                            ///Seats
                            Row(
                              children: [
                                SizedBox(
                                    width: largeur * 0.2,
                                    height: hauteur * 0.025,
                                    child:  MyText(
                                        text: "Seats",
                                        weight: FontWeight.w700,
                                        fontsize: 14,
                                        color: const Color(0xff20236C),
                                        largeur: largeur * 0.2)),
                                Container(
                                  width: largeur*0.3,
                                  height: hauteur*0.05,
                                  decoration:  BoxDecoration(boxShadow: const [BoxShadow(blurRadius: 18, color: Color.fromRGBO(32, 35, 108, 0.15))],color: Colors.white,borderRadius:BorderRadius.circular(5)),
                                  child: DropdownButtonFormField(
                                    borderRadius: BorderRadius.circular(10),
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_drop_down_rounded,color: Color(0xFF72D2C2)),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white)),
                                      focusedBorder: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "-1",
                                        child: Text("4", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),
                                      ),
                                      DropdownMenuItem(
                                        value: "1",
                                        child: AutoSizeText("3", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),

                                      ),
                                      DropdownMenuItem(
                                        value: "2",
                                        child:
                                        AutoSizeText("2", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),

                                      ),
                                      DropdownMenuItem(
                                        value: "3",
                                        child:
                                        AutoSizeText("1", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xff20236C), fontSize: 12),),

                                      ),

                                    ],
                                    onChanged: (value) {
                                      if (value == "-1") {seats = "4";};
                                      if (value == "1") {seats = "3";};
                                      if (value == "2") {seats = "2";};
                                      if (value == "3") {seats = "1";};
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: hauteur * 0.05),

                            /// Create Button
                            SimpleButton(
                                backgroundcolor:
                                const Color(0xffFFA18E),
                                size: Size(largeur, hauteur * 0.06),
                                radius: 10,
                                text: "Create",
                                textcolor: const Color(0xFF20236C),
                                fontsize: 20,
                                fct: (){
                                  createTrip(
                                      auth.currentUser!.uid,
                                      debut,
                                      fin,
                                      locationName!,
                                      locationNamea!,
                                      date!,
                                      time!,
                                      pricecontroller.text.trim(),
                                      seats!,
                                      methode);
                                  },
                                weight: FontWeight.w700),
                            SizedBox(height: hauteur * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),),
          Positioned(
            top: hauteur*0.05,
            left: largeur*0.05,
            child: SizedBox(
            height: 35,
            width: 80,
            child: PrefixeIconButton(
                size: const Size(73, 34),
                color: Colors.white,
                radius: 10,
                text: "Back",
                textcolor: const Color(0xFF20236C),
                weight: FontWeight.w600,
                fontsize: 14,
                icon: Transform.scale(scale: 0.75, child: const Icons_ESIWay(icon: "arrow_left", largeur: 30, hauteur: 30),),
                espaceicontext: 5.0,
                fct: (){toHome();}),
          ),)
        ],
      ),
    );
  }
}
