import 'package:equatable/equatable.dart';

class Deck extends Equatable {
  final String id;
  final String name;
  final String languageCode;
  final DateTime createdAt;

  const Deck({
    required this.id,
    required this.name,
    required this.languageCode,
    required this.createdAt,
  });

  Deck copyWith({
    String? id,
    String? name,
    String? languageCode,
    DateTime? createdAt,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, languageCode, createdAt];
}
