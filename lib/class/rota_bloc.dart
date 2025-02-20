import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neyimeshur/class/rota_event.dart';
import 'package:neyimeshur/class/rota_state.dart';
import 'package:neyimeshur/class/rota_repo.dart';
import '../models/rota_model.dart';

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
