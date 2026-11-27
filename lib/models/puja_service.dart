class PujaService {
  final String id;
  final String name;
  final String description;
  final String category;
  final Duration duration;
  final double price;
  final List<String> requiredSamagri;
  final String? instructions;
  final String? imageUrl;
  final bool isActive;

  const PujaService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.duration,
    required this.price,
    this.requiredSamagri = const [],
    this.instructions,
    this.imageUrl,
    this.isActive = true,
  });

  PujaService copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    Duration? duration,
    double? price,
    List<String>? requiredSamagri,
    String? instructions,
    String? imageUrl,
    bool? isActive,
  }) {
    return PujaService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      requiredSamagri: requiredSamagri ?? this.requiredSamagri,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
