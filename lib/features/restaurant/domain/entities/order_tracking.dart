import 'package:equatable/equatable.dart';
import 'location.dart';

class OrderTracking extends Equatable {
  final String id;
  final String orderId;
  final Location? currentLocation;
  final List<TrackingStep> steps;
  final DateTime lastUpdated;
  final String? estimatedTime;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleInfo;
  
  const OrderTracking({
    required this.id,
    required this.orderId,
    this.currentLocation,
    required this.steps,
    required this.lastUpdated,
    this.estimatedTime,
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
  });
  
  @override
  List<Object?> get props => [
    id,
    orderId,
    currentLocation,
    steps,
    lastUpdated,
    estimatedTime,
    driverName,
    driverPhone,
    vehicleInfo,
  ];
}

class TrackingStep extends Equatable {
  final String title;
  final String description;
  final DateTime? completedAt;
  final bool isCompleted;
  final bool isCurrent;
  
  const TrackingStep({
    required this.title,
    required this.description,
    this.completedAt,
    required this.isCompleted,
    required this.isCurrent,
  });
  
  @override
  List<Object?> get props => [
    title,
    description,
    completedAt,
    isCompleted,
    isCurrent,
  ];
}