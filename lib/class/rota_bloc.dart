import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neyimeshur/class/rota_repo.dart';
import 'package:neyimeshur/models/sehir_model.dart';
import '../models/rota_model.dart';

abstract class trip_event {
  trip_event();
}

class temporarilyStoreTripEvent extends trip_event {
  final String tripName;
  final String durationCount;
  final String tripDuration;
  final String tripBudget;
  final String tripLocation;
  final String tripDescription;
  final String tripCoverPhot;
  final String endDate;

  temporarilyStoreTripEvent(
    this.tripName,
    this.durationCount,
    this.tripDuration,
    this.tripBudget,
    this.tripLocation,
    this.tripDescription,
    this.tripCoverPhot,
    this.endDate,
  );
}

class getSelectTrip extends trip_event {
  final tripId;
  getSelectTrip(this.tripId);
}

class addTripPalcesEvent extends trip_event {
  final bool isEditTrip;
  final List placesIds;
  final String tripId;

  addTripPalcesEvent({
    required this.tripId,
    required this.isEditTrip,
    required this.placesIds,
  });
}

class editTrip extends trip_event {
  final tripId;
  editTrip(this.tripId);
}

class planingPlaces extends trip_event {
  List<Place> places;
  int currentDay;
  planingPlaces(this.places, this.currentDay);
}

class creatTrip extends trip_event {
  Trip trip;
  creatTrip(this.trip);
}

class editPlaces extends trip_event {
  var places = {};
  editPlaces(this.places);
}

class updateTrip extends trip_event {
  Trip trip;
  updateTrip(this.trip);
}

class cancelPlaningPlaces extends trip_event {
  cancelPlaningPlaces();
}

abstract class tripState {}

class InitialTripState extends tripState {}

class temporarilyStoreTripState extends tripState {
  Trip trip;
  temporarilyStoreTripState(this.trip);
}

class getTripDetailsSate extends tripState {
  Trip trip;
  getTripDetailsSate(this.trip);
}

class addTripPlacesState extends tripState {
  bool isEditTrip;
  List placesIds;

  addTripPlacesState({
    required this.isEditTrip,
    required this.placesIds,
  });
}

class storeTripPlacesState extends tripState {
  var storeTripPlaces;
  storeTripPlacesState(this.storeTripPlaces);
}

class tripCreatingSuccessState extends tripState {
  tripCreatingSuccessState();
}

class tripCreateErrorState extends tripState {
  tripCreateErrorState();
}

class tripBloc extends Bloc<trip_event, tripState> {
  Future<List<Trip>> getOnGoingTrips() async {
    List<Trip> trips = await tripRepo.onGoingTrips();

    return trips;
  }

  Future<List<Trip>> pastTrips() async {
    List<Trip> trips = await tripRepo.pastTrips();

    return trips;
  }

  Future<int> countTotalTrips() async {
    int count = await tripRepo.countTotalTrips();
    return count;
  }

  Future<String> getRandomImage(tripCount) async {
    String image =
        'https://i0.wp.com/huseyinozbekar.com/wp-content/uploads/2024/11/5-soruda-gds-sistemi.jpg?w=640&ssl=1';
    return image;
  }

  tripBloc() : super(InitialTripState()) {
    var tempStoreTripPlaces = {};

    on<getSelectTrip>((event, emit) async {
      await tripRepo.getSelectTrip(event.tripId);
    });

    on<planingPlaces>((event, emit) async {
      if (tempStoreTripPlaces[event.currentDay.toString()] == null) {
        var toJson = event.places.map((ele) {
          return ele.toJson();
        }).toList();

        tempStoreTripPlaces[event.currentDay.toString()] = toJson;
      } else {
        bool isHave = false;
        for (var i = 0; i < event.places.length; i++) {
          for (var e in tempStoreTripPlaces[event.currentDay.toString()]) {
            if (event.places[i].id.contains(e['placeId'])) {
              isHave = true;
            }
          }
          if (isHave == false) {
            tempStoreTripPlaces[event.currentDay.toString()]
                .add(event.places[i].toJson());
          }
        }
      }

      emit(storeTripPlacesState(tempStoreTripPlaces));
    });

    on<creatTrip>((event, emit) async {
      bool isError = await tripRepo.createTrip(event.trip);

      if (isError == false) {
        emit(tripCreatingSuccessState());
      } else {
        emit(tripCreateErrorState());
      }
    });

    on<updateTrip>((event, emit) async {
      bool isError = await tripRepo.updateTrip(event.trip);

      if (isError == false) {
        emit(tripCreatingSuccessState());
      } else {
        emit(tripCreateErrorState());
      }
    });

    on<editPlaces>((event, emit) async {
      tempStoreTripPlaces = event.places;
      emit(storeTripPlacesState(tempStoreTripPlaces));
    });

    on<cancelPlaningPlaces>((event, emit) async {
      tempStoreTripPlaces = {};
      emit(InitialTripState());
    });
  }
}

final tripBlo = tripBloc();
