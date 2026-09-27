class Firearm {
  final int? id;
  final String name;
  final String manufacturer;
  final String countryOfOrigin;
  final String firearmType;
  final String caliber;
  final int? yearIntroduced;
  final double? weightKg;
  final double? barrelLengthCm;
  final int? magazineCapacity;
  final String? description;
  final String? imageUrl;

  Firearm({
    this.id,
    required this.name,
    required this.manufacturer,
    required this.countryOfOrigin,
    required this.firearmType,
    required this.caliber,
    this.yearIntroduced,
    this.weightKg,
    this.barrelLengthCm,
    this.magazineCapacity,
    this.description,
    this.imageUrl,
  });

  factory Firearm.fromJson(Map<String, dynamic> json) {
  return Firearm(
    id: int.tryParse(json['id']?.toString() ?? ''),
    name: json['name']?.toString() ?? '',
    manufacturer: json['manufacturer']?.toString() ?? '',
    countryOfOrigin:
        json['country_of_origin']?.toString() ?? '',
    firearmType:
        json['firearm_type']?.toString() ?? '',
    caliber: json['caliber']?.toString() ?? '',
    yearIntroduced:
        int.tryParse(json['year_introduced']?.toString() ?? ''),
    weightKg:
        double.tryParse(json['weight_kg']?.toString() ?? ''),
    barrelLengthCm:
        double.tryParse(json['barrel_length_cm']?.toString() ?? ''),
    magazineCapacity:
        int.tryParse(json['magazine_capacity']?.toString() ?? ''),
    description: json['description']?.toString(),

    // THIS LINE
    imageUrl: json['image_url']?.toString(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'country_of_origin': countryOfOrigin,
      'firearm_type': firearmType,
      'caliber': caliber,
      'year_introduced': yearIntroduced,
      'weight_kg': weightKg,
      'barrel_length_cm': barrelLengthCm,
      'magazine_capacity': magazineCapacity,
      'description': description,
      'image_url': imageUrl,
    };
  }
}