# Configuration des Comptes Admin et Couple

Ce guide explique comment configurer les comptes administrateur et couple pour accéder à l'administration et à la modération du site de mariage.

## Comptes à créer

### 1. Compte Admin
- **Email:** `zolasoll7@gmail.com`
- **Mot de passe:** `zola2026`
- **Rôle:** `admin` (accès complet à l'administration)

### 2. Compte Couple (Marié)
- **Email:** `aimemaboundou@gmail.com`
- **Mot de passe:** `francis2026`
- **Rôle:** `couple` (accès à la modération des photos)

## Méthodes de Configuration

### Méthode 1: Via Interface Supabase Dashboard (Recommandée pour première fois)

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cliquez sur **+ Create new user**
5. Créez l'utilisateur admin avec :
   - Email: `zolasoll7@gmail.com`
   - Password: `zola2026`
   - Auto Confirm: ✓ (cochez)
6. Répétez pour le compte couple

### Méthode 2: Via Application Flutter

1. Ouvrez l'app Flutter en mode développement
2. Allez à la route `/setup`
3. L'écran de configuration créera automatiquement les comptes

### Méthode 3: Via Edge Function (Programmatique)

```bash
# Appel POST à votre edge function
curl -X POST https://your-project.supabase.co/functions/v1/setup-admin-accounts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "zolasoll7@gmail.com",
    "password": "zola2026",
    "role": "admin"
  }'
```

## Vérification de la Configuration

### Via Dashboard Supabase:

1. Allez dans **Authentication** > **Users**
2. Vérifiez que les deux utilisateurs existent
3. Allez dans **SQL Editor** et exécutez:

```sql
SELECT 
  u.email,
  up.role,
  u.id as user_id
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IN ('zolasoll7@gmail.com', 'aimemaboundou@gmail.com')
ORDER BY u.email;
```

Vous devriez voir:
```
| email | role | user_id |
|-------|------|---------|
| aimemaboundou@gmail.com | couple | [UUID] |
| zolasoll7@gmail.com | admin | [UUID] |
```

### Via Application:

1. Allez dans l'app à `/admin/login`
2. Testez la connexion avec:
   - Admin: `zolasoll7@gmail.com` / `zola2026`
   - Couple: `aimemaboundou@gmail.com` / `francis2026`

## Accès après Configuration

### Admin
- **URL:** `/admin` ou `/admin/login`
- **Permissions:**
  - ✅ Gérer les invités
  - ✅ Modérer les photos
  - ✅ Voir les statistiques
  - ✅ Gérer les autres admins

### Couple (Marié)
- **URL:** `/couple` ou `/admin/login`
- **Permissions:**
  - ✅ Gérer les invités (partagé avec admin)
  - ✅ Modérer les photos
  - ❌ Gérer les autres admins

## Dépannage

### Le compte n'a pas accès à l'admin

Vérifiez dans `user_profiles` que le rôle est correct:

```sql
SELECT user_id, role FROM public.user_profiles 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email = 'aimemaboundou@gmail.com'
);
```

Si vide, créez l'entrée:

```sql
INSERT INTO public.user_profiles (user_id, role)
SELECT id, 'couple' FROM auth.users 
WHERE email = 'aimemaboundou@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET role = 'couple';
```

### Impossible de se connecter

1. Vérifiez que l'email est confirmé dans Supabase Dashboard
2. Vérifiez les logs en allant dans **Logs** > **Auth**
3. Assurez-vous que le mot de passe est exact

## Sécurité

⚠️ **Recommandations:**

1. Changez les mots de passe après la première connexion
2. Utilisez des mots de passe forts pour la production
3. N'exposez pas ces credentials dans le code source
4. Utilisez les variables d'environnement pour les credentials sensibles
5. Activez l'authentification 2FA si disponible

## Modification des Mots de Passe

Pour changer un mot de passe:

1. Allez dans **Authentication** > **Users**
2. Cliquez sur l'utilisateur
3. Cliquez sur le menu "..." > **Reset password**

Ou via SQL:

```sql
-- Note: Cela ne fonctionne que via Supabase Admin API
-- Utilisez le Dashboard pour les modifications
```
