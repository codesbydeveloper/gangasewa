class Devotee {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? gotra;
  final String? nakshatra;
  final String? rashi;
  final List<String> familyMembers;
  final String? address;

  const Devotee({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.gotra,
    this.nakshatra,
    this.rashi,
    this.familyMembers = const [],
    this.address,
  });
}
