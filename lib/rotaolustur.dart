import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:neyimeshur/harita.dart';
import 'package:uuid/uuid.dart';
import 'package:neyimeshur/class/rota_bloc.dart';
import '../models/sehir_model.dart';
import 'package:neyimeshur/models/rota_model.dart';
import 'package:neyimeshur/rotaplani.dart';

class rotaOlustur extends StatefulWidget {
  final String placeName;
  final String placePhotoUrl;
  final isEditTrip;
  final Trip trip;
  rotaOlustur(
      {super.key,
      required this.placeName,
      required this.placePhotoUrl,
      required this.isEditTrip,
      required this.trip});
  @override
  State<rotaOlustur> createState() =>
      _createNewTripState(placeName, placePhotoUrl, isEditTrip, trip);
}

class _createNewTripState extends State<rotaOlustur> {
  var isDataReady = false;
  final String placeName;
  final bool isEditTrip;
  late final String backGroundPlacePhotoUrl;
  late String defultBacPhotoUrl;
  late final String planTrips = '5';
  late String tripName = '';
  var daysDuration;
  var endDate;
  var startDate;
  final Trip trip;
  late Trip newTrip;
  TextEditingController dateinput = TextEditingController();
  final TripNameController = TextEditingController();
  final TripBudgetController = TextEditingController();
  final TripLocationController = TextEditingController();
  final TripDescriptionController = TextEditingController();
  _createNewTripState(
      this.placeName, this.backGroundPlacePhotoUrl, this.isEditTrip, this.trip);
  @override
  void initState() {
    super.initState();
    getBackGroundImage();
    if (isEditTrip == true) {
      editTrip();
    }
  }

  @override
  void dispose() {
    super.dispose();
    TripNameController.dispose();
    TripBudgetController.dispose();
    TripLocationController.dispose();
    TripDescriptionController.dispose();
  }

  Future<void> editTrip() async {
    TripNameController.text = trip.tripName;
    tripName = trip.tripName;
    defultBacPhotoUrl = trip.tripCoverPhoto;
    dateinput.text = trip.tripDuration;
    TripBudgetController.text = trip.tripBudget;
    TripLocationController.text = trip.tripLocation;
    TripDescriptionController.text = trip.tripDescription;
  }

  Future<void> createTrip() async {
    if (isEditTrip != true) {
      var durationCount = daysDuration ?? 0;
      var conDurationCount = durationCount;
      var uuid = const Uuid();
      newTrip = Trip(
        tripId: uuid.v1(),
        tripName: TripNameController.text,
        tripBudget: TripBudgetController.text,
        tripLocation: TripLocationController.text,
        tripDescription: TripDescriptionController.text,
        tripCoverPhoto: defultBacPhotoUrl.isNotEmpty
            ? defultBacPhotoUrl
            : backGroundPlacePhotoUrl,
        tripDuration: dateinput.text,
        durationCount: conDurationCount,
        startDate: startDate,
        endDate: endDate,
        places: {},
      );
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => rotaPlani(
                isEditPlace: false,
                isAddPlace: false,
                trip: newTrip,
                place: Place(
                    address: '',
                    latitude: 0.0,
                    name: '',
                    id: '',
                    longitude: 0.0,
                    openingHours: [],
                    phone: '',
                    photoRef: '',
                    rating: 0.0,
                    type: '',
                    reviews: []),
              )));
    } else {
      var durationCount = daysDuration ?? 0;
      var conDurationCount = durationCount;
      newTrip = Trip(
        tripId: trip.tripId,
        tripName: TripNameController.text,
        tripBudget: TripBudgetController.text,
        tripLocation: TripLocationController.text,
        tripDescription: TripDescriptionController.text,
        tripCoverPhoto: defultBacPhotoUrl.isNotEmpty
            ? defultBacPhotoUrl
            : backGroundPlacePhotoUrl,
        tripDuration:
            '${DateFormat('yyyy-MM-dd').format(startDate ?? trip.startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate ?? trip.endDate)}',
        durationCount:
            conDurationCount != 0 ? conDurationCount : trip.durationCount,
        startDate: startDate ?? trip.startDate,
        endDate: endDate ?? trip.endDate,
        places: trip.places,
      );
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => rotaPlani(
                isEditPlace: true,
                isAddPlace: false,
                trip: newTrip,
                place: Place(
                    address: '',
                    latitude: 0.0,
                    name: '',
                    id: '',
                    longitude: 0.0,
                    openingHours: [],
                    phone: '',
                    photoRef: '',
                    rating: 0.0,
                    type: '',
                    reviews: []),
              )));
    }
  }

  Future<void> getBackGroundImagewithPhone(ImageSource media) async {
    final ImagePicker picker = ImagePicker();
    XFile? response = await picker.pickImage(source: media);
    if (response != null) {
      print(response.path);
    } else {
      print("Kullanıcı bir resim seçmedi.");
    }
  }

  Future<String> getBackGroundImage() async {
    final tripCount = await tripBlo.countTotalTrips();
    final image = await tripBlo.getRandomImage(tripCount);
    if (placeName != "" &&
        backGroundPlacePhotoUrl != "" &&
        isEditTrip == false) {
      defultBacPhotoUrl = backGroundPlacePhotoUrl;
      tripName = placeName;
    } else if (isEditTrip == false) {
      defultBacPhotoUrl = image;
    }
    return defultBacPhotoUrl;
  }

  dateTimeRangePicker() async {
    DateTimeRange? pickedDate = await showDateRangePicker(
        context: context,
        firstDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: isEditTrip
            ? DateTimeRange(
                end: endDate ?? trip.endDate,
                start: startDate ?? trip.startDate,
              )
            : endDate != null && startDate != null
                ? DateTimeRange(
                    end: endDate,
                    start: startDate,
                  )
                : null,
        currentDate: DateTime.now(),
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 300, maxHeight: 500),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color.fromARGB(255, 0, 0, 0),
                      onPrimary: Color.fromARGB(255, 255, 255, 255),
                      onSurface: Colors.blueAccent,
                    ),
                  ),
                  child: child!,
                ),
              )
            ],
          );
        });
    if (pickedDate != null) {
      print(pickedDate);
      String formattedDate1 = DateFormat('yyyy-MM-dd').format(pickedDate.start);
      String formattedDate2 = DateFormat('yyyy-MM-dd').format(pickedDate.end);
      print(pickedDate.duration.inDays);
      daysDuration = pickedDate.duration.inDays;
      endDate = pickedDate.end;
      startDate = pickedDate.start;
      setState(() {
        dateinput.text = '${formattedDate1} - ${formattedDate2}';
      });
    } else {
      print("Lutfen tarih seciniz.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            tripName;
          });
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarHeight: 1,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color.fromARGB(0, 255, 255, 255),
              statusBarIconBrightness: Brightness.light,
            ),
            elevation: 0,
            backgroundColor: Color.fromARGB(0, 20, 12, 12),
          ),
          body: LimitedBox(
            maxHeight: 800,
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                child: Stack(children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          FutureBuilder(
                              future: getBackGroundImage(),
                              builder: (context, snapshotImage) {
                                if (snapshotImage.hasData) {
                                  return Container(
                                    width: 392,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              '${snapshotImage.data}'),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Container(
                                      width: 360,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 40),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 150),
                                                      child: SizedBox(
                                                        width: 150,
                                                        child: Text(
                                                            "Gezi Bilgileri",
                                                            style: GoogleFonts
                                                                .cabin(
                                                                    // ignore: prefer_const_constructors
                                                                    textStyle:
                                                                        TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ))),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 20),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                getBackGroundImagewithPhone(
                                                                    ImageSource
                                                                        .gallery);
                                                              },
                                                              child: Container(
                                                                width: 35,
                                                                height: 35,
                                                                decoration: BoxDecoration(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            98,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            45)),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .camera_alt_outlined,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          153,
                                                                          152,
                                                                          152),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 120, left: 13),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 310,
                                                  child: Text(
                                                      tripName.isNotEmpty
                                                          ? tripName
                                                          : "Gezi Bilgilerini Giriniz",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.cabin(
                                                          // ignore: prefer_const_constructors
                                                          textStyle: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 33,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ))),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox(
                                    width: 360,
                                    height: 250,
                                    child: LoadingAnimationWidget.beat(
                                      color: Color.fromARGB(255, 129, 129, 129),
                                      size: 25,
                                    ),
                                  );
                                }
                              }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Container(
                                      width: 300,
                                      height: 60,
                                      child: TextField(
                                        controller: TripNameController,
                                        onTap: () {
                                          setState(() {});
                                        },
                                        onChanged: (value) {
                                          tripName = value;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Color.fromARGB(
                                              255, 240, 238, 238),
                                          hintText: 'Şehir Adı',
                                          hintStyle: GoogleFonts.cabin(
                                              // ignore: prefer_const_constructors
                                              textStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 145, 144, 144),
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          )),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(19.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 300,
                                    height: 60,
                                    child: TextField(
                                      controller: dateinput,
                                      readOnly: true,
                                      onTap: () async {
                                        dateTimeRangePicker();
                                      },
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 240, 238, 238),
                                        hintText: 'Gün Aralığı',
                                        prefixIcon: Icon(Icons.calendar_month),
                                        hintStyle: GoogleFonts.cabin(
                                            // ignore: prefer_const_constructors
                                            textStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 145, 144, 144),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        )),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(19.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 5.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 300,
                                    height: 60,
                                    child: TextField(
                                      controller: TripBudgetController,
                                      onTap: () {
                                        setState(() {});
                                      },
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 240, 238, 238),
                                        hintText: 'Gezi Bütçesi',
                                        prefixIcon: Icon(Icons.money_sharp),
                                        hintStyle: GoogleFonts.cabin(
                                            // ignore: prefer_const_constructors
                                            textStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 145, 144, 144),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        )),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(19.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 5.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  LatLng? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HaritaEkrani()),
                                  );

                                  if (result != null) {
                                    setState(() {
                                      TripLocationController.text =
                                          "${result.latitude}, ${result.longitude}";
                                    });
                                  }
                                },
                                child: Container(
                                  width: 300,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 240, 238, 238),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0), // İç boşluk eklendi
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        size: 24, // İkon boyutu
                                      ),
                                      SizedBox(
                                          width:
                                              10), // İkon ile yazı arasına boşluk
                                      Expanded(
                                        child: Text(
                                          TripLocationController.text.isEmpty
                                              ? "Konum Seç"
                                              : TripLocationController.text,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 145, 144, 144),
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Uzun metin taşarsa ...
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 300,
                                    height: 70,
                                    child: TextField(
                                      controller: TripDescriptionController,
                                      maxLines: 10,
                                      onTap: () {
                                        setState(() {});
                                      },
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color.fromARGB(255, 240, 238, 238),
                                        hintText: 'Açıklama',
                                        hintStyle: GoogleFonts.cabin(
                                            // ignore: prefer_const_constructors
                                            textStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 145, 144, 144),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        )),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 5.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Visibility(
                                        visible: isEditTrip,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0, right: 20),
                                          child: SizedBox(
                                            width: 100,
                                            height: 45,
                                            child: TextButton(
                                              onPressed: () async {
                                                await createTrip();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                foregroundColor: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Text(
                                                'Kaydet',
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20.0,
                                        ),
                                        child: SizedBox(
                                          width: isEditTrip ? 100 : 270,
                                          height: 45,
                                          child: TextButton(
                                            onPressed: () async {
                                              createTrip();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              foregroundColor: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              isEditTrip ? "Şehir" : 'Sonraki',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
