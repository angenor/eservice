part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Location location;
  final String address;
  
  const LocationLoaded({
    required this.location,
    required this.address,
  });
  
  @override
  List<Object?> get props => [location, address];
}

class LocationError extends LocationState {
  final String message;
  
  const LocationError(this.message);
  
  @override
  List<Object?> get props => [message];
}