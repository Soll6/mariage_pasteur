# 🔍 Diagnostic: Admin Connexion Failure

## Issue Identifiée

L'admin ne peut pas se connecter avec les identifiants:
- Email: `zolasoll7@gmail.com`
- Mot de passe: `zola2026`

**Message d'erreur:** "Erreur lors de la connexion. Veuillez réessayer."

## 📊 Diagnostic Findings

### ✅ Compte Admin Status
```
Email: zolasoll7@gmail.com
ID: b72feb33-9710-432a-83a3-fd702ea6579b
Email confirmé: ✅ 2026-05-05 01:11:58
Encrypted Password: ✅ Présent ($2a$ bcrypt hash)
Rôle: ✅ admin (assigné dans user_profiles)
RLS Policies: ✅ Configurées correctement
```

### ❌ Problème Identifié
```
last_sign_in_at: NULL
→ Le compte n'a JAMAIS réussi une connexion
→ Le mot de passe peut être incorrect
```

## 🔧 Solution: Réinitialiser le Mot de Passe

### Étape 1: Via Supabase Dashboard (Recommandée)

1. Allez sur https://app.supabase.com
2. Sélectionnez votre projet
3. **Authentication** > **Users**
4. Cherchez `zolasoll7@gmail.com`
5. Cliquez sur l'utilisateur pour l'ouvrir
6. Cliquez sur le menu **...** (trois points)
7. Sélectionnez **Reset password**
8. Entrez le nouveau mot de passe: **`zola2026`**
9. Confirmez le mot de passe: **`zola2026`**
10. Cliquez **Update password**

**Status:** ✅ Le mot de passe sera réinitialisé

### Étape 2: Vérifier la Réinitialisation

Attendez 5-10 secondes, puis testez de nouveau:

1. Ouvrez l'app Flutter
2. Allez à `/admin/login`
3. Email: `zolasoll7@gmail.com`
4. Mot de passe: `zola2026`
5. Cliquez **SE CONNECTER**

### Résultat Attendu

✅ Connexion réussie
✅ Redirect vers `/admin` (Admin Dashboard)
✅ Page chargée avec les statistiques

## 🎯 Points de Vérification

### Avant Réinitialisation

```sql
-- État actuel (tel que trouvé)
SELECT 
  email,
  email_confirmed_at,
  last_sign_in_at,
  created_at,
  updated_at
FROM auth.users 
WHERE email = 'zolasoll7@gmail.com';

-- Résultat attendu:
-- email | email_confirmed_at | last_sign_in_at | created_at | updated_at
-- zolasoll7@gmail.com | 2026-05-05 01:11:58 | NULL | 2026-05-05 01:11:58 | 2026-05-05 01:11:58
```

### Après Réinitialisation

```sql
-- État après reset (attendu)
SELECT 
  email,
  email_confirmed_at,
  last_sign_in_at,
  updated_at
FROM auth.users 
WHERE email = 'zolasoll7@gmail.com';

-- Résultat attendu:
-- email | email_confirmed_at | last_sign_in_at | updated_at
-- zolasoll7@gmail.com | 2026-05-05 01:11:58 | [Current] | [Dernière réinitialisation]
```

## 🔒 Sécurité

**⚠️ Important:**
- Vous utilisez actuellement le même mot de passe documenté (`zola2026`)
- En **production**, utilisez un mot de passe fort et unique
- Recommandations:
  - Minimum 12 caractères
  - Mélange: majuscules, minuscules, chiffres, symboles
  - Ne pas réutiliser dans d'autres services
  - Stocker de manière sécurisée (gestionnaire de mots de passe)

**Exemple de bon mot de passe:**
```
zola@2026MariagePasteur#Admin!
```

## 🔄 Diagnostic Avancé

Si la réinitialisation ne fonctionne pas:

### 1. Vérifier les Logs Supabase

```
Dashboard > Logs > Auth
```

Recherchez les erreurs récentes pour `zolasoll7@gmail.com`

### 2. Vérifier le Profil Utilisateur

```sql
SELECT 
  id,
  user_id,
  role,
  created_at
FROM public.user_profiles
WHERE user_id = 'b72feb33-9710-432a-83a3-fd702ea6579b';
```

Devrait retourner:
```
id | user_id | role | created_at
[UUID] | b72feb33-9710-432a-83a3-fd702ea6579b | admin | [Date]
```

### 3. Tester Directement l'Auth API

```bash
curl -X POST https://your-project.supabase.co/auth/v1/token?grant_type=password \
  -H "apikey: YOUR_PUBLISHABLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "zolasoll7@gmail.com",
    "password": "zola2026"
  }'
```

Devrait retourner:
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "user": {
    "id": "b72feb33-9710-432a-83a3-fd702ea6579b",
    "email": "zolasoll7@gmail.com",
    ...
  }
}
```

### 4. Vérifier la Configuration Supabase

- Allez dans **Settings** > **API**
- Vérifiez que **JWT Expiry** est raisonnable (ex: 3600 secondes)
- Vérifiez que **JWT Secret** est présent
- Vérifiez que **Site URL** est correcte

## 🆘 Si Toujours Bloqué

### Option 1: Recréer le Compte

```
1. Dashboard > Authentication > Users
2. Cherchez zolasoll7@gmail.com
3. Cliquez sur "..." > Delete user
4. Créez un nouveau compte avec le même email/password
```

### Option 2: Utiliser un Email Alternatif

```
Email: admin@mariagepasteur.com
Password: zola2026
Role: admin (assigner manuellement)
```

### Option 3: Vérifier la Couche Transport

- Vérifiez que vous utilisez HTTPS (pas HTTP)
- Vérifiez les certificats SSL
- Vérifiez les pare-feu/proxy
- Vérifiez les rate limiters

## 📋 Checklist Finale

- [ ] Accédez au Supabase Dashboard
- [ ] Allez dans Authentication > Users
- [ ] Trouvez `zolasoll7@gmail.com`
- [ ] Cliquez sur "Reset password"
- [ ] Entrez `zola2026` deux fois
- [ ] Cliquez "Update password"
- [ ] Attendez 10 secondes
- [ ] Ouvrez l'app Flutter
- [ ] Allez à `/admin/login`
- [ ] Entrez `zolasoll7@gmail.com` / `zola2026`
- [ ] Cliquez "SE CONNECTER"
- [ ] ✅ Devriez voir Admin Dashboard

---

## 🔗 Ressources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Reset Password Guide](https://supabase.com/docs/guides/auth/manage-passwords#reset-a-password)
- [Admin Dashboard Source](lib/screens/admin/admin_dashboard_screen.dart)
- [Auth Service Source](lib/services/auth_service.dart)

---

**Diagnostic Date:** 2026-07-14
**Status:** 🔴 BLOQUÉ - Attente Réinitialisation Mot de Passe
**Next Step:** Réinitialiser le mot de passe dans Supabase Dashboard
