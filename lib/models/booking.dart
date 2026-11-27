import 'devotee.dart';

enum BookingStatus {
  pending,
  accepted,
  upcoming,
  inProgress,
  completed,
  cancelled,
  rejected,
}

class Booking {
  final String id;
  final String bookingNumber;
  final String pujaName;
  final String pujaType;
  final String? pujaImageUrl;
  final Devotee devotee;
  final DateTime scheduledAt;
  final Duration duration;
  final String location;
  final String? address;
  final double amount;
  final double platformFee;
  final BookingStatus status;
  final List<String> samagri;
  final String? specialInstructions;
  final String? videoId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.pujaName,
    required this.pujaType,
    this.pujaImageUrl,
    required this.devotee,
    required this.scheduledAt,
    required this.duration,
    required this.location,
    this.address,
    required this.amount,
    this.platformFee = 0,
    required this.status,
    this.samagri = const [],
    this.specialInstructions,
    this.videoId,
    required this.createdAt,
    this.completedAt,
  });

  double get netEarning => amount - platformFee;

  Booking copyWith({
    String? id,
    String? bookingNumber,
    String? pujaName,
    String? pujaType,
    String? pujaImageUrl,
    Devotee? devotee,
    DateTime? scheduledAt,
    Duration? duration,
    String? location,
    String? address,
    double? amount,
    double? platformFee,
    BookingStatus? status,
    List<String>? samagri,
    String? specialInstructions,
    String? videoId,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      pujaName: pujaName ?? this.pujaName,
      pujaType: pujaType ?? this.pujaType,
      pujaImageUrl: pujaImageUrl ?? this.pujaImageUrl,
      devotee: devotee ?? this.devotee,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      address: address ?? this.address,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      status: status ?? this.status,
      samagri: samagri ?? this.samagri,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      videoId: videoId ?? this.videoId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
