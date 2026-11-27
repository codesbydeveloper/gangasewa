class Pandit {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final bool isVerified;
  final int experienceYears;
  final String? specialization;
  final List<String> languages;
  final String? location;
  final String? templeAffiliation;
  final String? biography;
  final String? gotra;
  final VerificationStatus verificationStatus;

  const Pandit({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.isVerified = false,
    this.experienceYears = 0,
    this.specialization,
    this.languages = const [],
    this.location,
    this.templeAffiliation,
    this.biography,
    this.gotra,
    this.verificationStatus = VerificationStatus.pending,
  });

  Pandit copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    bool? isVerified,
    int? experienceYears,
    String? specialization,
    List<String>? languages,
    String? location,
    String? templeAffiliation,
    String? biography,
    String? gotra,
    VerificationStatus? verificationStatus,
  }) {
    return Pandit(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      experienceYears: experienceYears ?? this.experienceYears,
      specialization: specialization ?? this.specialization,
      languages: languages ?? this.languages,
      location: location ?? this.location,
      templeAffiliation: templeAffiliation ?? this.templeAffiliation,
      biography: biography ?? this.biography,
      gotra: gotra ?? this.gotra,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

enum VerificationStatus { pending, approved, rejected }
