# Implementation Plan: Système d'Authentification et Gestion des Rôles

## Overview

Ce projet implémente un système d'authentification contextuelle avec gestion des rôles pour l'application de mariage "Sonia & Aimé". L'approche suit une logique "invitation-first" où les utilisateurs naviguent librement sans authentification, puis s'identifient de manière contextuelle lorsqu'ils effectuent des actions protégées (RSVP, upload de photos, commentaires).

Le système gère trois rôles distincts :
- **guest** (invité) : Accès public avec capacité de RSVP, upload de photos, et interactions
- **couple** (mariés) : Gestion des invités, modération photos, statistiques
- **admin** (technique) : Accès complet au système

L'authentification utilise Supabase avec Magic Links pour les invités et email/mot de passe pour admin/mariés.

## Architecture

### Composants Principaux

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter App                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Public      │  │  Protected   │  │   Admin      │          │
│  │  Screens     │  │  Screens     │  │   Screens    │          │
│  │ - Home       │  │ - RSVP       │  │ - Dashboard  │          │
│  │ - Gallery    │  │ - Upload     │  │ - Guests     │          │
│  │ - Program    │  │ - Comment    │  │ - Photos     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                          │                                       │
│                          ▼                                       │
│  ┌──────────────────────────────────────────────────┐          │
│  │           Auth Modal (Contextual)                │          │
│  │  - Email input                                   │          │
│  │  - Magic link for guests                         │          │
│  │  - Email validation against guests table         │          │
│  └──────────────────────────────────────────────────┘          │
│                          │                                       │
│                          ▼                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Services   │  │   Models     │  │   Widgets    │          │
│  │ - AuthService│  │ - Guest      │  │ - AuthModal  │          │
│  │ - GuestService│ │ - UserProfile│  │ - AuthGuard  │          │
│  │ - AdminService│ │ - ActivityLog│  └──────────────┘          │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Supabase Backend                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  auth.users  │  │  user_profiles│ │   guests     │          │
│  │  (providers) │  │   (roles)    │  │   (invités)  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  gallery_photos││photo_likes   │  │photo_comments│          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### Services

| Service | Responsibility | Key Methods |
|---------|---------------|-------------|
| **AuthService** | Authentification, session management | signIn, signOut, sendMagicLink, isGuestEmail, loadUserRole |
| **GuestService** | CRUD operations for guests | getGuests, updateRSVP, getRSVPStats, addGuest, deleteGuest |
| **AdminService** | Admin operations | getLogs, getGalleryStats, exportGuests |

### Widgets

| Widget | Purpose |
|--------|---------|
| **AuthModal** | Contextual authentication overlay for protected actions |
| **AuthGuard** | Route protection for admin routes |
| **RSVPForm** | RSVP submission form with auth check |

## Data Models

### Guest
```dart
class Guest {
  String id;
  String email;
  String fullName;
  String rsvpStatus; // 'pending', 'confirmed', 'declined'
  int numberOfGuests;
  String? dietaryRestrictions;
  String? allergies;
  DateTime createdAt;
  DateTime? updatedAt;
}
```

### UserProfile
```dart
class UserProfile {
  String id;
  String userId; // auth.users.id
  String? guestId; // guests.id
  String role; // 'guest', 'couple', 'admin'
  String? avatarUrl;
}
```

### ActivityLog
```dart
class ActivityLog {
  String id;
  String userId;
  String actionType; // 'login', 'rsvp', 'upload', 'moderate'
  String? metadata;
  DateTime createdAt;
}
```

## Correctness Properties

### Property 1: Role Assignment Consistency
**Validates: Requirements 6.1, 6.2**
When a user authenticates, the system MUST assign a role from user_profiles table. If no profile exists, the system MUST default to 'guest' role.

### Property 2: Public Access Preservation
**Validates: Requirements 1.1, 1.2, 1.3**
Public routes (/, /home) MUST be accessible without authentication. The system MUST NOT prompt for authentication when navigating public content.

### Property 3: Contextual Auth Trigger
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
Authentication modal MUST only appear when user attempts protected actions (RSVP, upload, comment). Modal MUST NOT appear on public page loads.

### Property 4: Email Validation for Magic Link
**Validates: Requirements 3.1, 3.2, 3.3, 3.4**
Magic link MUST ONLY be sent if email exists in guests table. System MUST show error message if email not in guest list.

### Property 5: Admin Route Protection
**Validates: Requirements 7.1, 7.2, 7.3, 7.4**
Protected admin routes MUST redirect unauthenticated users to /admin/login. Routes MUST reject access for 'guest' role users.

### Property 6: RSVP Persistence
**Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 10.6**
RSVP data MUST be persisted to database via GuestService when submitted. Pre-existing RSVP data MUST be pre-filled for authenticated guests.

### Property 7: Photo Upload Authentication
**Validates: Requirements 13.1, 13.2, 13.3**
Photos MUST be uploaded with 'pending' status and linked to guest_id. Upload MUST trigger AuthModal if user not authenticated.

## Error Handling

### Authentication Errors
| Error | User Message | Action |
|-------|-------------|--------|
| Invalid email/password | "Identifiants incorrects" | Show error in login form |
| Email not in guests list | "Cet email n'est pas dans la liste des invités" | Show snack bar in AuthModal |
| Magic link expired | "Le lien a expiré. Veuillez en demander un nouveau" | Show error, offer retry |

### Database Errors
| Error | User Message | Action |
|-------|-------------|--------|
| Network error | "Erreur de connexion. Vérifiez votre connexion" | Show snack bar |
| RLS violation | "Permission refusée" | Log security event, redirect |

### Rate Limiting
- Max 3 magic link requests per 5 minutes per email
- Show message: "Trop de tentatives. Réessayez plus tard"

## Testing Strategy

| Test Type | Coverage | Location |
|-----------|----------|----------|
| **Unit Tests** | Services (AuthService, GuestService, AdminService) | `test/services/` |
| **Widget Tests** | AuthModal, AuthGuard | `test/widgets/` |
| **Integration Tests** | Full auth flows, RSVP flow, admin flows | `test/integration/` |

---

## Tasks

### 1. Database Setup

- [-] 1.1 Create user_profiles table migration
  - Run migration in Supabase to create user_profiles table
  - Add UUID primary key with default uuid_generate_v4()
  - Add foreign key to auth.users(id) ON DELETE CASCADE
  - Add foreign key to guests(id) ON DELETE SET NULL
  - Add role column with CHECK constraint ('guest', 'couple', 'admin')
  - Add created_at and updated_at columns with default NOW()
  - Create indexes on user_id and guest_id
  - Enable RLS on the table
  - _Requirements: 16.1, 16.2, 16.3, 16.4_

- [-] 1.2 Create user_profiles RLS policies
  - Policy "Users can read own profile" - SELECT on own profile
  - Policy "Admins can read all profiles" - SELECT for admin role
  - Policy "Users can update own profile" - UPDATE on own profile
  - Apply policies to user_profiles table
  - _Requirements: 15.1, 15.2, 15.3_

- [-] 1.3 Create invitations table migration
  - Run migration in Supabase to create invitations table
  - Add UUID primary key with default uuid_generate_v4()
  - Add foreign key to guests(id) ON DELETE CASCADE
  - Add invitation_code VARCHAR(50) UNIQUE NOT NULL
  - Add sent_at, opened_at, expires_at timestamp columns
  - Create indexes on code and guest_id
  - Enable RLS on the table
  - _Requirements: 17.1, 17.2, 17.3, 17.4_

- [-] 1.4 Create invitations RLS policies
  - Policy "Invitations readable by guest" - SELECT for guest email match
  - Policy "Invitations readable by couple/admin" - SELECT for couple/admin role
  - Apply policies to invitations table
  - _Requirements: 15.4, 15.5, 15.6, 15.7_

- [-] 1.5 Verify existing table RLS policies
  - Check and update RLS on guests table
  - Check and update RLS on gallery_photos table
  - Check and update RLS on photo_likes table
  - Check and update RLS on photo_comments table
  - Ensure all policies exist and are functional
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

### 2. Core Data Models

- [-] 2.1 Create Guest model
  - Create lib/models/guest.dart
  - Define Guest class with all fields from database
  - Implement fromJson factory constructor
  - Implement toJson method
  - Add constructor with required parameters only
  - _Requirements: 9.1, 9.2, 10.1_

- [-] 2.2 Create UserProfile model
  - Create lib/models/user_profile.dart
  - Define UserProfile class with all fields
  - Implement fromJson factory constructor
  - Implement toJson method
  - Add role constants for type safety
  - _Requirements: 6.1, 6.2, 16.1_

- [-] 2.3 Create ActivityLog model
  - Create lib/models/activity_log.dart
  - Define ActivityLog class with all fields
  - Implement fromJson factory constructor
  - Implement actionType constants for logging
  - _Requirements: 19.1, 19.2, 19.3_

### 3. Core Services

- [-] 3.1 Implement AuthService
  - Create lib/services/auth_service.dart
  - Extend ChangeNotifier for reactive state
  - Implement currentUser and userRole getters
  - Implement isAuthenticated, isCouple, isAdmin computed properties
  - Implement signIn with email/password
  - Implement signOut that resets state
  - Implement sendMagicLink for OTP authentication
  - Implement isGuestEmail to validate against guests table
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 6.1, 6.2, 6.3, 6.4, 8.1, 8.2, 8.3, 8.4_

- [-] 3.2 Implement GuestService
  - Create lib/services/guest_service.dart
  - Extend ChangeNotifier for reactive state
  - Implement getGuests() to fetch all guests (admin/couple only)
  - Implement updateRSVP() to save RSVP data
  - Implement getRSVPStats() to calculate statistics
  - Implement addGuest() to create new guest
  - Implement deleteGuest() to remove guest
  - Implement filterByRSVPStatus() to filter guests
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 11.1, 11.2, 11.3, 11.4, 20.1, 20.2, 20.3_

- [-] 3.3 Implement AdminService
  - Create lib/services/admin_service.dart
  - Implement getLogs() to fetch activity logs
  - Implement exportGuests() to generate CSV
  - Implement getGalleryStats() for moderation dashboard
  - Implement moderatePhoto() to approve/reject photos
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 19.1, 19.2, 19.3_

### 4. Auth Modal Implementation

- [-] 4.1 Create AuthModal widget
  - Create lib/widgets/auth_modal.dart
  - Implement Dialog with rounded corners
  - Add context-aware action message
  - Implement email input field
  - Add magic link send functionality
  - Add email validation (guest check)
  - Show error message for non-guest email
  - Add loading states during API calls
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5_

- [-] 4.2 Integrate AuthModal into RSVPScreen
  - Modify lib/screens/rsvp_screen.dart
  - Check authentication before form submission
  - Show AuthModal if not authenticated
  - Pass 'rsvp' action to AuthModal
  - Execute RSVP submit after authentication
  - Pre-fill form if user already authenticated
  - _Requirements: 10.6, 20.2_

- [-] 4.3 Integrate AuthModal into GalleryScreen
  - Modify lib/screens/galerie_screen.dart
  - Check authentication before upload
  - Show AuthModal if not authenticated
  - Pass 'upload' action to AuthModal
  - Execute upload after authentication
  - _Requirements: 13.3, 14.1, 14.2, 14.3, 14.4_

- [-] 4.4 Integrate AuthModal into Photo Comments
  - Modify photo comment widget
  - Check authentication before comment submission
  - Show AuthModal if not authenticated
  - Pass 'comment' action to AuthModal
  - Execute comment after authentication
  - _Requirements: 14.1, 14.2, 14.3, 14.4_

### 5. Admin Login and Guard

- [-] 5.1 Create AdminLoginScreen
  - Create lib/screens/admin/admin_login_screen.dart
  - Implement email and password fields
  - Implement login button with loading state
  - Show error messages for invalid credentials
  - Implement password visibility toggle
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [-] 5.2 Create AuthGuard widget
  - Create lib/widgets/auth_guard.dart
  - Check authentication status
  - Check role against requiredRoles
  - Redirect to /admin/login if not authenticated
  - Redirect to /home if role not authorized
  - Return child widget if authorized
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

### 6. Admin Screens

- [-] 6.1 Create AdminDashboardScreen
  - Create lib/screens/admin/admin_dashboard_screen.dart
  - Display RSVP statistics (confirmed, declined, pending, total guests)
  - Show quick actions cards
  - Display recent activity logs
  - Show navigation to guest management and photo moderation
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 18.1, 18.2, 18.3, 19.1, 19.2, 19.3_

- [-] 6.2 Create GuestManagementScreen
  - Create lib/screens/admin/guest_management_screen.dart
  - Display guests list with filtering
  - Implement filter by RSVP status
  - Add add guest button
  - Implement edit guest functionality
  - Implement delete guest functionality
  - Implement export to CSV button
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [-] 6.3 Create PhotoModerationScreen
  - Create lib/screens/admin/photo_moderation_screen.dart
  - Display photos with pending status
  - Add approve button
  - Add reject button
  - Show photo preview
  - Show photo metadata and uploader info
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [-] 6.4 Create CoupleDashboardScreen
  - Create lib/screens/couple/couple_dashboard_screen.dart
  - Display simplified RSVP statistics
  - Show guest management quick actions
  - Add photo moderation quick actions
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 12.1, 12.2, 12.3, 12.4, 12.5_

### 7. Integration

- [-] 7.1 Update main.dart with service providers
  - Add ChangeNotifierProvider for AuthService
  - Add ChangeNotifierProvider for GuestService
  - Add ChangeNotifierProvider for AdminService
  - Configure routes with protected admin routes
  - Set up initial route
  - _Requirements: 1.1, 1.2, 1.3, 5.6, 7.1, 7.2, 7.3, 7.4_

- [-] 7.2 Update home_screen.dart to add admin link
  - Add discreet admin login link to footer
  - Link to /admin/login route
  - Ensure link is visible but non-intrusive
  - _Requirements: 18.1, 18.2, 18.3_

- [-] 7.3 Update gallery_service.dart for protected uploads
  - Check authentication before upload
  - Link photo to guest_id of authenticated user
  - Set photo status to 'pending'
  - Show AuthModal if not authenticated
  - _Requirements: 13.1, 13.2, 13.3_

- [-] 7.4 Update enveloppe_screen.dart to verify public access
  - Verify no authentication required
  - Ensure public content displays correctly
  - _Requirements: 1.1, 1.2, 1.3_

- [-] 7.5 Verify RSVP persistence in database
  - Test RSVP save via GuestService.updateRSVP()
  - Verify database record created/updated
  - Test RSVP pre-fill for authenticated users
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 20.1, 20.2, 20.3_

### 8. Testing

- [-] 8.1 Write unit tests for AuthService
  - Test sign in with valid credentials
  - Test sign in with invalid credentials
  - Test sign out resets state
  - Test sendMagicLink for guest email
  - Test sendMagicLink for non-guest email
  - Test role loading
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [-] 8.2 Write unit tests for GuestService
  - Test getGuests returns all guests
  - Test updateRSVP saves to database
  - Test getRSVPStats calculates correctly
  - Test addGuest creates record
  - Test deleteGuest removes record
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 11.1, 11.2, 11.3, 11.4, 20.1_

- [-] 8.3 Write widget tests for AuthModal
  - Test modal displays on action trigger
  - Test email input validation
  - Test magic link sent for guest email
  - Test error message for non-guest email
  - Test loading states
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5_

- [-] 8.4 Write widget tests for AdminLoginScreen
  - Test login with valid credentials
  - Test login with invalid credentials
  - Test redirect based on role
  - Test error message display
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [-] 8.5 Write widget tests for AuthGuard
  - Test redirect when not authenticated
  - Test redirect when wrong role
  - Test allow when authorized
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [-] 8.6 Write integration tests for full auth flow
  - Test public page access without auth
  - Test auth modal appears on protected action
  - Test magic link authentication flow
  - Test admin login and dashboard access
  - Test guest RSVPS with authentication
  - Test photo upload with authentication
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 7.1, 7.2, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 13.1, 13.2, 13.3_

- [-] 8.7 Write property tests for correctness properties
  - **Property 1: Role Assignment Consistency**
    - Verify role defaults to 'guest' when no profile exists
    - Verify role loads from user_profiles table when exists
    - **Validates: Requirements 6.1, 6.2**
  
  - **Property 2: Public Access Preservation**
    - Verify / route accessible without auth
    - Verify /home route accessible without auth
    - **Validates: Requirements 1.1, 1.2, 1.3**
  
  - **Property 3: Contextual Auth Trigger**
    - Verify AuthModal appears on RSVP action without auth
    - Verify AuthModal appears on upload action without auth
    - Verify AuthModal does NOT appear on public page load
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
  
  - **Property 4: Email Validation for Magic Link**
    - Verify magic link sent for guest email
    - Verify error shown for non-guest email
    - Verify no magic link sent for non-guest email
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
  
  - **Property 5: Admin Route Protection**
    - Verify redirect to /admin/login for unauthenticated access
    - Verify redirect for 'guest' role accessing admin routes
    - Verify access granted for authorized roles
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**
  
  - **Property 6: RSVP Persistence**
    - Verify RSVP saved to database
    - Verify RSVP pre-filled for authenticated user
    - Verify database consistency
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 20.1, 20.2, 20.3**
  
  - **Property 7: Photo Upload Authentication**
    - Verify photo uploaded with 'pending' status
    - Verify photo linked to guest_id
    - Verify AuthModal triggered for unauthenticated upload
    - **Validates: Requirements 13.1, 13.2, 13.3**

### 9. Final Checkpoint

- [x] 9.1 Run all tests and ensure passing
  - Run unit tests for all services
  - Run widget tests for all widgets
  - Run integration tests for full flows
  - Verify test coverage meets standard
  - Fix any failing tests

- [x] 9.2 Verify Supabase configuration
  - Check all RLS policies applied correctly
  - Verify table indexes created
  - Check foreign key constraints
  - Test queries work with auth context

- [x] 9.3 Verify all requirements covered
  - Cross-check requirements with implementation tasks
  - Ensure all 20 requirements have corresponding tests
  - Document any uncovered requirements

- [x] 9.4 Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5"] },
    { "id": 1, "tasks": ["2.1", "2.2", "2.3"] },
    { "id": 2, "tasks": ["3.1", "3.2", "3.3"] },
    { "id": 3, "tasks": ["4.1", "4.2", "4.3", "4.4", "5.1", "5.2"] },
    { "id": 4, "tasks": ["6.1", "6.2", "6.3", "6.4"] },
    { "id": 5, "tasks": ["7.1", "7.2", "7.3", "7.4", "7.5"] },
    { "id": 6, "tasks": ["8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7"] },
    { "id": 7, "tasks": ["9.1", "9.2", "9.3", "9.4"] }
  ]
}
```

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP (not used in this feature)
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests validate full user flows
- The AuthModal approach keeps the invitation experience fluent while securing sensitive actions
- Admin login is discreet (footer link) to maintain public UX
- All protected actions trigger AuthModal for guest users
- Database RLS policies ensure data security at the backend level