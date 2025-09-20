part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  
  @override
  List<Object?> get props => [];
}

class GetCurrentLocation extends LocationEvent {}

class RequestLocationPermission extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final Location location;
  
  const UpdateLocation(this.location);
  
  @override
  List<Object?> get props => [location];
}