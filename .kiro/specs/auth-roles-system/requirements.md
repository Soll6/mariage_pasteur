# Requirements Document

## Introduction

Ce document définit les exigences du système d'authentification et de gestion des rôles pour l'application de mariage "Sonia & Aimé". Le système suit une approche "invitation-first" où les invités peuvent naviguer librement dans l'application et s'authentifient de manière contextuelle lorsqu'ils effectuent des actions protégées (RSVP, upload de photos, commentaires).

Le système gère trois rôles distincts :
- **Invité (guest)** : Accès public à l'invitation, RSVP, galerie
- **Marié (couple)** : Gestion invités, modération photos, statistiques
- **Admin** : Accès complet, logs, configuration

## Glossary

- **Invité (Guest)** : Personne invitée au mariage pouvant consulter l'invitation, confirmer son RSVP et interagir avec la galerie
- **Marié (Couple)** : Les mariés (Sonia & Aimé) disposant de permissions étendues pour gérer les invités et modérer la galerie
- **Admin** : Administrateur technique ayant un accès complet au système
- **AuthModal** : Modal contextuelle apparaissant lorsqu'un utilisateur non authentifié tente une action protégée
- **AuthGuard** : Widget protégeant les routes administratives
- **Magic Link** : Lien de connexion envoyé par email permettant une authentification sans mot de passe
- **RSVP** : Réponse à l'invitation confirmant ou déclinant la présence
- **RLS (Row Level Security)** : Sécurité au niveau des lignes dans Supabase pour contrôler l'accès aux données
- **UserProfile** : Profil utilisateur liant un compte auth.users à un rôle et optionnellement à un invité

---

## Requirements

### Requirement 1: Navigation Publique sans Authentification

**User Story:** En tant qu'invité, je veux accéder au contenu de l'invitation sans être obligé de me connecter, afin de découvrir les informations du mariage de manière fluide.

#### Acceptance Criteria

1. WHEN un utilisateur accède à l'application, THE System SHALL afficher l'écran d'invitation (EnveloppeScreen) sans exiger d'authentification
2. WHEN un utilisateur navigue vers la page d'accueil, THE System SHALL afficher le countdown, les infos cérémonies, les photos approuvées et le programme sans authentification
3. THE System SHALL permettre la navigation libre dans toutes les sections publiques de l'application sans vérification d'authentification

---

### Requirement 2: Authentification Contextuelle via AuthModal

**User Story:** En tant qu'invité non authentifié, je veux être invité à m'identifier uniquement lorsque j'effectue une action nécessitant une authentification, afin de ne pas être freiné dans ma découverte de l'invitation.

#### Acceptance Criteria

1. WHEN un utilisateur non authentifié tente de confirmer son RSVP, THE System SHALL afficher l'AuthModal en overlay
2. WHEN un utilisateur non authentifié tente d'uploader une photo, THE System SHALL afficher l'AuthModal en overlay
3. WHEN un utilisateur non authentifié tente de commenter ou liker une photo, THE System SHALL afficher l'AuthModal en overlay
4. WHEN l'AuthModal s'affiche, THE System SHALL présenter un message contextuel décrivant l'action nécessitant l'authentification
5. WHEN l'utilisateur annule l'authentification, THE System SHALL fermer l'AuthModal sans effectuer l'action demandée

---

### Requirement 3: Vérification Email dans la Liste des Invités

**User Story:** En tant qu'invité, je veux recevoir un magic link uniquement si mon email est dans la liste des invités, afin de garantir que seules les personnes invitées puissent s'authentifier.

#### Acceptance Criteria

1. WHEN un utilisateur saisit son email dans l'AuthModal, THE System SHALL vérifier si l'email existe dans la table `guests`
2. IF l'email existe dans la liste des invités, THEN THE System SHALL envoyer un magic link à cet email
3. IF l'email n'existe pas dans la liste des invités, THEN THE System SHALL afficher un message invitant l'utilisateur à contacter les mariés
4. WHEN le magic link est envoyé, THE System SHALL afficher une confirmation visuelle à l'utilisateur

---

### Requirement 4: Authentification par Magic Link pour les Invités

**User Story:** En tant qu'invité, je veux me connecter via un lien magique envoyé par email, afin de ne pas avoir à retenir un mot de passe.

#### Acceptance Criteria

1. WHEN un invité clique sur le magic link reçu par email, THE System SHALL l'authentifier automatiquement
2. WHEN l'authentification réussit, THE System SHALL créer ou récupérer le UserProfile associé à l'utilisateur
3. WHEN l'authentification réussit, THE System SHALL charger le rôle de l'utilisateur depuis la table `user_profiles`
4. WHEN l'authentification réussit, THE System SHALL fermer l'AuthModal et exécuter l'action initialement demandée
5. WHEN le magic link a expiré, THE System SHALL afficher un message d'erreur et proposer de renvoyer un nouveau lien

---

### Requirement 5: Connexion Admin/Marié par Email et Mot de Passe

**User Story:** En tant qu'admin ou marié, je veux me connecter via une page dédiée avec email et mot de passe, afin d'accéder aux fonctionnalités d'administration.

#### Acceptance Criteria

1. WHEN un utilisateur accède à `/admin/login`, THE System SHALL afficher un formulaire de connexion avec email et mot de passe
2. WHEN un utilisateur saisit des identifiants corrects, THE System SHALL l'authentifier et déterminer son rôle
3. IF l'utilisateur authentifié a le rôle 'admin', THEN THE System SHALL le rediriger vers `/admin`
4. IF l'utilisateur authentifié a le rôle 'couple', THEN THE System SHALL le rediriger vers `/couple`
5. IF les identifiants sont incorrects, THEN THE System SHALL afficher un message d'erreur sans révéler si l'email existe
6. THE System SHALL exiger une authentification pour accéder aux routes `/admin`, `/admin/guests`, `/admin/photos` et `/couple`

---

### Requirement 6: Gestion des Rôles Utilisateur

**User Story:** En tant que système, je dois attribuer et vérifier les rôles des utilisateurs, afin de contrôler l'accès aux différentes fonctionnalités.

#### Acceptance Criteria

1. WHEN un utilisateur s'authentifie, THE System SHALL récupérer son rôle depuis la table `user_profiles`
2. IF aucun UserProfile n'existe pour un utilisateur authentifié, THE System SHALL attribuer le rôle 'guest' par défaut
3. THE System SHALL supporter les rôles 'guest', 'couple' et 'admin'
4. WHEN le rôle d'un utilisateur est chargé, THE System SHALL notifier les listeners (via ChangeNotifier) du changement d'état

---

### Requirement 7: Protection des Routes Administratives

**User Story:** En tant qu'admin ou marié, je veux que les routes d'administration soient protégées, afin d'empêcher l'accès non autorisé aux fonctionnalités sensibles.

#### Acceptance Criteria

1. WHEN un utilisateur non authentifié tente d'accéder à une route protégée, THE System SHALL le rediriger vers `/admin/login`
2. WHEN un utilisateur avec le rôle 'guest' tente d'accéder à une route admin, THE System SHALL lui refuser l'accès
3. WHEN un utilisateur avec le rôle 'couple' tente d'accéder à une route admin-only, THE System SHALL lui refuser l'accès
4. WHEN un utilisateur autorisé accède à une route protégée, THE System SHALL afficher le contenu correspondant

---

### Requirement 8: Déconnexion Utilisateur

**User Story:** En tant qu'utilisateur authentifié, je veux pouvoir me déconnecter, afin de sécuriser mon compte sur un appareil partagé.

#### Acceptance Criteria

1. WHEN un utilisateur clique sur le bouton de déconnexion, THE System SHALL invalider sa session Supabase
2. WHEN la déconnexion est effectuée, THE System SHALL réinitialiser les variables d'état (currentUser, userRole)
3. WHEN la déconnexion est effectuée, THE System SHALL notifier les listeners du changement d'état
4. WHEN la déconnexion est effectuée, THE System SHALL rediriger l'utilisateur vers la page d'accueil publique

---

### Requirement 9: Gestion des Invités (Admin/Couple)

**User Story:** En tant que marié ou admin, je veux gérer la liste des invités, afin de suivre et organiser les participations au mariage.

#### Acceptance Criteria

1. WHEN un admin ou marié accède à la gestion des invités, THE System SHALL afficher la liste complète des invités avec leur statut RSVP
2. WHEN un admin ou marié ajoute un nouvel invité, THE System SHALL créer un enregistrement dans la table `guests`
3. WHEN un admin ou marié modifie les informations d'un invité, THE System SHALL mettre à jour l'enregistrement correspondant
4. WHEN un admin ou marié supprime un invité, THE System SHALL supprimer l'enregistrement de la table `guests`
5. THE System SHALL permettre le filtrage des invités par statut RSVP (confirmed, declined, pending)
6. THE System SHALL permettre l'export de la liste des invités au format CSV

---

### Requirement 10: Confirmation RSVP par les Invités

**User Story:** En tant qu'invité authentifié, je veux confirmer ou décliner ma présence au mariage, afin que les mariés puissent planifier l'événement.

#### Acceptance Criteria

1. WHEN un invité authentifié soumet son RSVP, THE System SHALL enregistrer son statut (confirmed ou declined) dans la table `guests`
2. WHEN un invité indique le nombre de personnes l'accompagnant, THE System SHALL enregistrer cette information
3. WHEN un invité indique des restrictions alimentaires, THE System SHALL les enregistrer dans le champ `dietary_restrictions`
4. WHEN un invité indique des allergies, THE System SHALL les enregistrer dans le champ `allergies`
5. WHEN le RSVP est mis à jour, THE System SHALL définir le champ `updated_at` à l'horodatage actuel
6. IF l'invité n'est pas authentifié, THEN THE System SHALL afficher l'AuthModal avant de permettre la soumission

---

### Requirement 11: Statistiques RSVP pour Admin/Couple

**User Story:** En tant que marié ou admin, je veux voir les statistiques des RSVP, afin d'avoir une vue d'ensemble sur la participation des invités.

#### Acceptance Criteria

1. WHEN un admin ou marié accède au dashboard, THE System SHALL afficher le nombre d'invités ayant confirmé
2. WHEN un admin ou marié accède au dashboard, THE System SHALL afficher le nombre d'invités ayant décliné
3. WHEN un admin ou marié accède au dashboard, THE System SHALL afficher le nombre d'invités en attente de réponse
4. WHEN un admin ou marié accède au dashboard, THE System SHALL afficher le nombre total de convives attendus (somme des numberOfGuests des confirmés)

---

### Requirement 12: Modération des Photos (Admin/Couple)

**User Story:** En tant que marié ou admin, je veux modérer les photos uploadées par les invités, afin de contrôler le contenu visible dans la galerie.

#### Acceptance Criteria

1. WHEN un admin ou marié accède à la modération photos, THE System SHALL afficher les photos en attente de validation
2. WHEN un admin ou marié approuve une photo, THE System SHALL mettre à jour son statut à 'approved'
3. WHEN un admin ou marié rejette une photo, THE System SHALL mettre à jour son statut à 'rejected'
4. WHEN une photo est approuvée, THE System SHALL la rendre visible dans la galerie publique
5. WHEN une photo est rejetée, THE System SHALL la masquer de la galerie publique

---

### Requirement 13: Upload de Photos par les Invités

**User Story:** En tant qu'invité authentifié, je veux uploader des photos dans la galerie, afin de partager mes souvenirs du mariage.

#### Acceptance Criteria

1. WHEN un invité authentifié uploade une photo, THE System SHALL l'enregistrer avec le statut 'pending'
2. WHEN une photo est uploadée, THE System SHALL l'associer au `guest_id` de l'utilisateur connecté
3. IF l'invité n'est pas authentifié, THEN THE System SHALL afficher l'AuthModal avant l'upload
4. THE System SHALL valider le format et la taille du fichier avant l'upload

---

### Requirement 14: Interactions avec la Galerie (Likes et Commentaires)

**User Story:** En tant qu'invité authentifié, je veux liker et commenter les photos de la galerie, afin d'interagir avec les autres invités.

#### Acceptance Criteria

1. WHEN un invité authentifié like une photo, THE System SHALL créer un enregistrement dans `photo_likes`
2. WHEN un invité authentifié retire son like, THE System SHALL supprimer l'enregistrement correspondant dans `photo_likes`
3. WHEN un invité authentifié commente une photo, THE System SHALL créer un enregistrement dans `photo_comments`
4. IF l'invité n'est pas authentifié, THEN THE System SHALL afficher l'AuthModal avant l'interaction

---

### Requirement 15: Sécurité Row Level Security (RLS)

**User Story:** En tant que système, je dois appliquer les politiques RLS sur les tables, afin de garantir que les utilisateurs n'accèdent qu'aux données autorisées.

#### Acceptance Criteria

1. THE System SHALL activer RLS sur la table `user_profiles`
2. THE System SHALL permettre aux utilisateurs de lire uniquement leur propre profil
3. THE System SHALL permettre aux admins de lire tous les profils
4. THE System SHALL activer RLS sur la table `guests`
5. THE System SHALL permettre aux invités de lire leurs propres données
6. THE System SHALL permettre aux couple et admin de gérer tous les invités
7. THE System SHALL activer RLS sur la table `invitations`

---

### Requirement 16: Profil Utilisateur et Liaison avec Auth

**User Story:** En tant que système, je dois créer et maintenir les profils utilisateurs liés aux comptes d'authentification, afin d'associer les rôles et les données invité.

#### Acceptance Criteria

1. WHEN un utilisateur s'authentifie pour la première fois, THE System SHALL créer un UserProfile si aucun n'existe
2. WHEN un UserProfile est créé, THE System SHALL définir le rôle par défaut à 'guest'
3. WHEN un UserProfile est créé pour un invité, THE System SHALL lier le `guest_id` correspondant
4. WHEN un UserProfile est mis à jour, THE System SHALL mettre à jour le champ `updated_at`

---

### Requirement 17: Gestion des Invitations

**User Story:** En tant que marié ou admin, je veux générer des liens d'invitation uniques, afin de tracker l'ouverture des invitations par les invités.

#### Acceptance Criteria

1. WHEN un admin ou marié génère une invitation, THE System SHALL créer un enregistrement dans `invitations` avec un code unique
2. WHEN un invité ouvre une invitation, THE System SHALL mettre à jour le champ `opened_at`
3. THE System SHALL permettre de définir une date d'expiration pour les invitations
4. THE System SHALL associer chaque invitation à un invité spécifique via `guest_id`

---

### Requirement 18: Lien Discret vers l'Espace Admin

**User Story:** En tant qu'admin ou marié, je veux accéder à l'espace d'administration via un lien discret, afin de ne pas perturber l'expérience des invités.

#### Acceptance Criteria

1. THE System SHALL afficher un lien vers `/admin/login` dans le footer de l'application
2. WHEN un utilisateur clique sur le lien admin, THE System SHALL le rediriger vers la page de connexion dédiée
3. THE System SHALL maintenir ce lien discret et non intrusif dans l'interface

---

### Requirement 19: Journal d'Activité (Logs)

**User Story:** En tant qu'admin, je veux consulter un journal des actions effectuées dans le système, afin de suivre l'activité et détecter les anomalies.

#### Acceptance Criteria

1. WHEN une action sensible est effectuée (connexion, RSVP, upload, modération), THE System SHALL créer un enregistrement dans `activity_logs`
2. WHEN un admin accède aux logs, THE System SHALL afficher les actions récentes avec horodatage, utilisateur et type d'action
3. THE System SHALL permettre le filtrage des logs par type d'action et par utilisateur

---

### Requirement 20: Persistance des Données RSVP

**User Story:** En tant qu'invité authentifié, je veux que mes informations RSVP soient persistées en base de données, afin que les mariés puissent les consulter.

#### Acceptance Criteria

1. WHEN un invité soumet son RSVP, THE System SHALL sauvegarder les données via le GuestService
2. WHEN un invité revient sur la page RSVP après authentification, THE System SHALL pré-remplir le formulaire avec ses données existantes
3. THE System SHALL garantir la cohérence des données entre le client et la base de données Supabase
