import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import '../../features/restaurant/domain/entities/location.dart' as app_location;

abstract class LocationService {
  Future<app_location.Location> getCurrentLocation();
  Future<String> getAddressFromLocation(app_location.Location location);
  Future<double> calculateDistance(app_location.Location from, app_location.Location to);
  Future<bool> requestLocationPermission();
  Stream<app_location.Location> getLocationStream();
}

@LazySingleton(as: LocationService)
class LocationServiceImpl implements LocationService {
  @override
  Future<app_location.Location> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return app_location.Location(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<String> getAddressFromLocation(app_location.Location location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Error getting address';
    }
  }

  @override
  Future<double> calculateDistance(
    app_location.Location from,
    app_location.Location to,
  ) async {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    ) / 1000; // Return in kilometers
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  @override
  Stream<app_location.Location> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) => app_location.Location(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
}