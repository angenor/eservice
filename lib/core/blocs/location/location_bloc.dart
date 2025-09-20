import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../features/restaurant/domain/entities/location.dart';
import '../../services/location_service.dart';

part 'location_event.dart';
part 'location_state.dart';

@injectable
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService locationService;
  
  LocationBloc({required this.locationService}) : super(LocationInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<UpdateLocation>(_onUpdateLocation);
  }
  
  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final location = await locationService.getCurrentLocation();
      final address = await locationService.getAddressFromLocation(location);
      
      emit(LocationLoaded(
        location: location,
        address: address,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  
  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final granted = await locationService.requestLocationPermission();
      if (granted) {
        add(GetCurrentLocation());
      } else {
        emit(const LocationError('Location permission denied'));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
  
  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    final address = await locationService.getAddressFromLocation(event.location);
    emit(LocationLoaded(
      location: event.location,
      address: address,
    ));
  }
}