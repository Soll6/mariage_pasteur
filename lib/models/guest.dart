class Guest {
  final String id;
  final String email;
  final String fullName;
  final String rsvpStatus; // 'pending', 'confirmed', 'declined'
  final int numberOfGuests;
  final int? guestNumber;
  final String? dietaryRestrictions;
  final String? allergies;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Guest({
    required this.id,
    required this.email,
    required this.fullName,
    required this.rsvpStatus,
    this.numberOfGuests = 1,
    this.guestNumber,
    this.dietaryRestrictions,
    this.allergies,
    required this.createdAt,
    this.updatedAt,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      rsvpStatus: json['rsvp_status'] as String? ?? 'pending',
      numberOfGuests: json['number_of_guests'] as int? ?? 1,
      guestNumber: json['guest_number'] as int?,
      dietaryRestrictions: json['dietary_restrictions'] as String?,
      allergies: json['allergies'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'rsvp_status': rsvpStatus,
      'number_of_guests': numberOfGuests,
      'guest_number': guestNumber,
      'dietary_restrictions': dietaryRestrictions,
      'allergies': allergies,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Guest copyWith({
    String? id,
    String? email,
    String? fullName,
    String? rsvpStatus,
    int? numberOfGuests,
    int? guestNumber,
    String? dietaryRestrictions,
    String? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guest(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      guestNumber: guestNumber ?? this.guestNumber,
      dietaryRestrictions:
          dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
