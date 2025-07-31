class TeamModel {
  final int? id;
  final String? name;
  final String? code;
  final String? country;
  final int? founded;
  final bool? national;
  final String? logo;
  final VenueModel? venue;

  const TeamModel({
    this.id,
    this.name,
    this.code,
    this.country,
    this.founded,
    this.national,
    this.logo,
    this.venue,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      country: json['country'],
      founded: json['founded'],
      national: json['national'],
      logo: json['logo'],
      venue: json['venue'] != null ? VenueModel.fromJson(json['venue']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'founded': founded,
      'national': national,
      'logo': logo,
      'venue': venue?.toJson(),
    };
  }

  TeamModel copyWith({
    int? id,
    String? name,
    String? code,
    String? country,
    int? founded,
    bool? national,
    String? logo,
    VenueModel? venue,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      country: country ?? this.country,
      founded: founded ?? this.founded,
      national: national ?? this.national,
      logo: logo ?? this.logo,
      venue: venue ?? this.venue,
    );
  }
}

class VenueModel {
  final int? id;
  final String? name;
  final String? address;
  final String? city;
  final int? capacity;
  final String? surface;
  final String? image;

  const VenueModel({
    this.id,
    this.name,
    this.address,
    this.city,
    this.capacity,
    this.surface,
    this.image,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      capacity: json['capacity'],
      surface: json['surface'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'capacity': capacity,
      'surface': surface,
      'image': image,
    };
  }
}