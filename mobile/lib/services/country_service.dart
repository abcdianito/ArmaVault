import 'dart:convert';
import 'package:http/http.dart' as http;

/// Third-party public API: REST Countries (https://restcountries.com)
/// No API key required. Used to enrich a firearm's "country of origin"
/// with its flag, region, and population.
class CountryInfo {
  final String commonName;
  final String flagEmoji;
  final String region;
  final int population;

  CountryInfo({
    required this.commonName,
    required this.flagEmoji,
    required this.region,
    required this.population,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      commonName: json['name']?['common'] ?? '',
      flagEmoji: json['flag'] ?? '',
      region: json['region'] ?? '',
      population: json['population'] ?? 0,
    );
  }
}

class CountryService {
  static const String baseUrl = 'https://restcountries.com/v3.1/name';

  Future<CountryInfo?> fetchCountryInfo(String countryName) async {
    final res = await http.get(
      Uri.parse('$baseUrl/${Uri.encodeComponent(countryName)}?fields=name,flag,region,population'),
    );
    if (res.statusCode == 200) {
      final List body = json.decode(res.body);
      if (body.isNotEmpty) {
        return CountryInfo.fromJson(body.first);
      }
    }
    return null;
  }
}
