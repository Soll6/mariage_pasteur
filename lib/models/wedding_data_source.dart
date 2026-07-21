import 'wedding_data.dart';

class WeddingData {
  WeddingData._();

  static const String coupleName = 'Sonia & Aimé Francis';
  static const String weddingDate = '28 Novembre 2026';
  static DateTime targetDate = DateTime(2026, 11, 28, 10, 0, 0);
  static const String city = 'Libreville, Gabon';
  static const String rsvpDeadline = '15 Novembre 2026';

  static const List<Ceremony> ceremonies = [
    Ceremony(
      title: 'Cérémonie Traditionnelle',
      description: 'Célébration de notre union selon les rites ancestraux, dans un cadre chaleureux partagé avec nos familles.',
      time: '08:30',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'groups',
      latitude: 0.4630312692460624,
      longitude: 9.436918339513689,
    ),
    Ceremony(
      title: 'Bénédiction',
      description: 'Bénédiction solennelle de notre union devant Dieu, dans la magnifique salle de la Résidence Hôtelière.',
      time: '14:00',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'church',
      latitude: 0.4630312692460624,
      longitude: 9.436918339513689,
    ),
    Ceremony(
      title: 'Mariage Civil',
      description: 'L\'engagement légal devant Monsieur le Maire et nos témoins.',
      time: '16:00',
      location: 'Mairie d\'Akanda',
      icon: 'gavel',
      latitude: 0.49554166723996285,
      longitude: 9.393235409060534,
    ),
    Ceremony(
      title: 'Dîner',
      description: 'Un dîner festif pour célébrer notre union en compagnie de nos proches, dans un cadre élégant et chaleureux.',
      time: '20:00',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'restaurant',
      latitude: 0.4630312692460624,
      longitude: 9.436918339513689,
    ),
  ];

  static const List<TimelineEvent> timeline = [
    TimelineEvent(
      title: 'Cérémonie Traditionnelle',
      description: 'Célébration de notre union selon les rites ancestraux. Un voyage au cœur de nos racines, dans un cadre chaleureux partagé avec nos familles et les plus anciens.',
      time: '08:30',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'groups',
      imageUrl: 'assets/images/tradition.jpg',
    ),
    TimelineEvent(
      title: 'Bénédiction',
      description: 'Bénédiction solennelle de notre union devant Dieu. Un moment de spiritualité intense et de partage dans la magnifique salle de la Résidence Hôtelière.',
      time: '14:00',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'church',
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
    ),
    TimelineEvent(
      title: 'Mariage Civil',
      description: 'Signature officielle de notre engagement devant l\'État. Un moment de solennité et de joie partagé avec nos proches à la Mairie d\'Akanda.',
      time: '16:00',
      location: 'Mairie d\'Akanda',
      icon: 'gavel',
      imageUrl: 'assets/images/mairie d\'Akanda.jpeg',
    ),
    TimelineEvent(
      title: 'Dîner',
      description: 'Un dîner festif pour célébrer notre union en compagnie de nos proches. Ambiance musicale, discours et partage dans un cadre élégant à la Résidence Hôtelière.',
      time: '20:00',
      location: 'RH Ronda (Résidence Hôtelière)',
      icon: 'restaurant',
      imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
    ),
  ];

  static const List<GalleryPhoto> galleryPhotos = [
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
      caption: 'Le jour où tout a commencé',
    ),
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
      caption: 'Main dans la main',
    ),
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      caption: 'Éclats de rire',
    ),
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      caption: 'La cérémonie',
    ),
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=800',
      caption: 'Douceurs',
    ),
    GalleryPhoto(
      photoUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800',
      caption: 'Soirée inoubliable',
    ),
  ];

  static const List<Map<String, dynamic>> practicalInfo = [
    {
      'icon': 'local_parking',
      'title': 'Stationnement',
      'description': 'Parking gratuit sécurisé disponible devant la salle RH Ronda.',
    },
    {
      'icon': 'local_taxi',
      'title': 'Navettes',
      'description': 'Des navettes privées assureront la liaison entre l\'aéroport Léon-Mba et la salle des fêtes RH Ronda.',
    },
    {
      'icon': 'hotel',
      'title': 'Hébergement',
      'description': 'Tarifs préférentiels pour nos invités au Radisson Blu (Code: SONIAIME26).',
    },
  ];
}
