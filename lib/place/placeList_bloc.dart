import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neyimeshur/models/favorites.dart';
import 'package:neyimeshur/models/review.dart';

import '../models/sehir_model.dart';
import '../repositories/attractions/attractionList_repo.dart';
import '../repositories/city/city_repo.dart';
import '../repositories/directions/directions_repo.dart';
import '../repositories/favorites/favorites_repo.dart';
import '../repositories/restaurants/restaurants_repo.dart';
import '../repositories/weather/weather_repo.dart';
import 'place_event.dart';
import 'place_state.dart';

class placeListBloc extends Bloc<place_event, place_state> {
  Future<Place?> getPlaceDetailes(placeId, placeType) async {
    Place? details;

    if (placeType == 'city') {
      details = await cityRep.getcityDetailes(placeId);
    } else if (placeType == 'attraction') {
      details = await attractionListRep.getAttractionDetailes(placeId);
    } else if (placeType == 'restaurant') {
      details = await restaurantRepo.getRestaurantDetailes(placeId);
    }

    return details;
  }

  Future<List<Place>> searchPlaces(input, placeType) async {
    List<Place> details = [];

    if (placeType == 'city') {
      details = await cityRep.searchCities(input);
    } else if (placeType == 'attraction') {
      details = await attractionListRep.searchAttractions(input);
    } else if (placeType == 'restaurant') {
      details = await restaurantRepo.searchRestaurants(input);
    }

    return details;
  }

  Future<List<Place>> getplaces(String name, String placeType) async {
    List<Place> details = [];

    if (placeType == 'attraction') {
      details = await attractionListRep.getAttractionPlaces(name);
    } else if (placeType == 'restaurant') {
      details = await restaurantRepo.getRestaurants(name);
    }

    return details;
  }

  Future<List> checkFavorites(data) async {
    return await favRepo.isChecktFavorites(data);
  }

  Future<List<Favorite>> getFavorites() async {
    return await favRepo.getFavorites();
  }

  Future<List> getWeather(lat, lng) async {
    weatherRepo repo = weatherRepo(lat: lat, lng: lng);
    return await repo.findWeather();
  }

  Future<List> getRoute(lat, lng) async {
    directionsRepo repo = directionsRepo(lat: lat, lng: lng);
    return await repo.calculateDistance();
  }

  Future<List<Place>> getUserRecentlySearch() async {
    return await cityRep.getUserRecentlySearch();
  }

  Future<List<Review>> getReviewList(placeType, placeId) async {
    List<Review> reviewList = [];

    if (placeType == 'attraction') {
      reviewList = await attractionListRep.getReviews(placeId);
    } else if (placeType == 'restaurant') {
      reviewList = await restaurantRepo.getReviews(placeId);
    }

    return reviewList;
  }

  placeListBloc() : super(InitialPlaceState()) {
    on<place_event>(
      (event, emit) async {
        if (event is placeAddToFavorites) {
          print('this is addToFavorites');
          bool isAdd = await favRepo.addToFavorite(Favorite(
            placeId: event.atPlaceId,
            placeName: event.placeName,
            placePhotoUrl: event.placeImgUrl,
            placeType: event.type,
          ));
          emit(placeAddToFavoriteState(isAdd));
        } else if (event is placeRemoveFromFavorites) {
          print("this is removeFavorite");
          bool isRemove = await favRepo.removeFavorites(event.atPlaceId);
          emit(placeRemoveFromFavoriteState(isRemove));
        } else if (event is addUserRecentlySearch) {
          if (event.type == 'locality') {
            await cityRep.addUserRecentlySearch(Place(
              id: event.id,
              name: event.name,
              photoRef: event.photoRef,
              rating: 0.0,
              address: event.address,
              type: event.type,
              phone: event.phone,
              openingHours: event.openingHours,
              latitude: event.latitude,
              longitude: event.longitude,
              reviews: [],
            ));
          }
        } else if (event is addReviewEvent) {
          if (event.placeType == 'attraction') {
            await attractionListRep.addReview(
                event.placeId, event.reviews, event.userId);
          } else if (event.placeType == 'restaurant') {
            await restaurantRepo.addReview(event.placeId, event.reviews);
          }
        } else if (event is deleteReviewEvent) {
          if (event.placeType == 'attraction') {
            await attractionListRep.deleteReview(
                event.reviews, event.placeId, event.userId);
          } else if (event.placeType == 'restaurant') {
            await restaurantRepo.deleteReview(event.reviews, event.placeId);
          }
        }
      },
    );
  }
}

final placeBloc = placeListBloc();
