class LocationData {
  final String? address;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? storeNumber;

  LocationData({
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    this.storeNumber,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      address: json['address'],
      city: json['city'],
      region: json['region'],
      postalCode: json['postal_code'],
      country: json['country'],
      latitude: json['lat']?.toDouble(),
      longitude: json['lon']?.toDouble(),
      storeNumber: json['store_number'],
    );
  }
}