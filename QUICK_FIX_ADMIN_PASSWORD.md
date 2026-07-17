# ⚡ Quick Fix: Admin Password Reset

## 🎯 Solution Rapide (2 minutes)

### Via Supabase Dashboard (Recommandée)

**URL:** https://app.supabase.com

1. **Projet** → Sélectionnez "mariage-pasteur"
2. **Authentication** → Cliquez sur **Users**
3. Cherchez: `zolasoll7@gmail.com`
4. Cliquez sur l'email pour ouvrir le profil
5. Cliquez sur le menu **...** (trois points en haut à droite)
6. Sélectionnez **Reset password**
7. **New Password**: `zola2026`
8. **Confirm Password**: `zola2026`
9. Cliquez **Update password**
10. ✅ Attendez la confirmation

### Tester la Connexion

1. Ouvrez Flutter app: `/admin/login`
2. Email: `zolasoll7@gmail.com`
3. Mot de passe: `zola2026`
4. Cliquez **SE CONNECTER**
5. ✅ Vous devriez voir Admin Dashboard

---

## 🔍 Vérifier que ça a Fonctionné

Exécutez cette requête SQL dans Supabase Dashboard > SQL Editor:

```sql
SELECT 
  email,
  email_confirmed_at,
  last_sign_in_at,
  updated_at
FROM auth.users 
WHERE email = 'zolasoll7@gmail.com';
```

✅ **Résultat attendu:** `updated_at` aura une date récente (la réinitialisation)

---

## 🆘 Si ça ne Marche Pas

### Option A: Supprimer et Recréer

1. Dashboard > Auth > Users
2. Cliquez sur `zolasoll7@gmail.com`
3. Menu **...** > **Delete user**
4. Créez nouvel utilisateur:
   - Email: `zolasoll7@gmail.com`
   - Password: `zola2026`
   - ✅ Check **Auto confirm user**
5. Exécutez ce SQL:
```sql
INSERT INTO public.user_profiles (user_id, role, created_at, updated_at)
SELECT id, 'admin', now(), now()
FROM auth.users WHERE email = 'zolasoll7@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
```

### Option B: Via Edge Function

Si vous avez déployé `setup-admin-accounts`, appelez-le:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/setup-admin-accounts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "zolasoll7@gmail.com",
    "password": "zola2026",
    "role": "admin"
  }'
```

---

## ✅ Checklist

- [ ] Allez dans Supabase Dashboard
- [ ] Authentication > Users
- [ ] Trouvez zolasoll7@gmail.com
- [ ] Reset password → zola2026
- [ ] Attendez confirmation
- [ ] Testez login dans app
- [ ] ✅ Voir Admin Dashboard

---

**Status:** 🔴 EN ATTENTE RÉINITIALISATION PASSWORD
**Temps:** ~2 minutes
**Difficulté:** Facile ⭐
