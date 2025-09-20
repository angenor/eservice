import 'package:equatable/equatable.dart';
import 'location.dart';

enum CuisineCategory {
  locale,
  internationale,
  fastFood,
  streetFood,
  vegetarien,
}

enum RestaurantStatus {
  open,
  closed,
  pause,
  full,
}

enum PaymentMethod {
  mobileMoney,
  cash,
  card,
  wallet,
}

class TimeSlot {
  final String opening;
  final String closing;
  
  const TimeSlot({required this.opening, required this.closing});
}

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final String description;
  final CuisineCategory category;
  final List<String> certifications;
  final Location location;
  final Map<String, TimeSlot> openingHours;
  final RestaurantStatus currentStatus;
  final double averageRating;
  final int reviewCount;
  final double minimumOrder;
  final double deliveryFee;
  final int averagePreparationTime;
  final List<PaymentMethod> acceptedPayments;
  final List<String> badges;
  
  const Restaurant({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerUrl,
    required this.description,
    required this.category,
    required this.certifications,
    required this.location,
    required this.openingHours,
    required this.currentStatus,
    required this.averageRating,
    required this.reviewCount,
    required this.minimumOrder,
    required this.deliveryFee,
    required this.averagePreparationTime,
    required this.acceptedPayments,
    required this.badges,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    bannerUrl,
    description,
    category,
    certifications,
    location,
    openingHours,
    currentStatus,
    averageRating,
    reviewCount,
    minimumOrder,
    deliveryFee,
    averagePreparationTime,
    acceptedPayments,
    badges,
  ];
}