# Instructions de Configuration des Comptes Administrateur et Couple

## 📋 Résumé

Vous devez créer deux comptes dans Supabase :
1. **Admin** : zolasoll7@gmail.com / zola2026 ✅ (Existe déjà)
2. **Couple** : aimemaboundou@gmail.com / francis2026 ⏳ (À créer)

## ✅ Étape 1 : Compte Admin (Déjà Configuré)

Le compte admin existe déjà avec les détails suivants :
- **Email** : zolasoll7@gmail.com
- **Rôle** : admin
- **User ID** : b72feb33-9710-432a-83a3-fd702ea6579b
- **Email confirmé** : Oui ✅

### Pour changer le mot de passe admin (optionnel)

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Trouvez `zolasoll7@gmail.com`
5. Cliquez sur le menu **...** > **Reset password**
6. Entrez le nouveau mot de passe : `zola2026`

## ⏳ Étape 2 : Créer le Compte Couple

### Méthode 1 : Via Supabase Dashboard (Recommandée - Simple)

1. Allez sur [Supabase Dashboard](https://app.supabase.com)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cliquez sur **Create new user**
5. Remplissez les champs :
   - **Email** : `aimemaboundou@gmail.com`
   - **Password** : `francis2026`
   - **Confirm password** : `francis2026`
6. ✅ Cochez **Auto confirm user**
7. Cliquez sur **Create user**

✅ Le compte sera créé instantanément

### Après création du compte

Exécutez cette requête SQL pour ajouter le rôle:

1. Allez dans **SQL Editor**
2. Créez une nouvelle requête
3. Collez le SQL ci-dessous :

```sql
INSERT INTO public.user_profiles (user_id, role, created_at, updated_at)
SELECT 
  id,
  'couple',
  now(),
  now()
FROM auth.users 
WHERE email = 'aimemaboundou@gmail.com'
ON CONFLICT (user_id) DO UPDATE 
SET role = 'couple', updated_at = now();
```

4. Cliquez sur **Run**

## 🔍 Étape 3 : Vérification

Pour vérifier que tout est bien configuré, exécutez cette requête SQL :

```sql
SELECT 
  u.email,
  up.role,
  u.id as user_id,
  u.email_confirmed_at,
  up.created_at as profile_created
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IN ('zolasoll7@gmail.com', 'aimemaboundou@gmail.com')
ORDER BY u.email;
```

### Résultat attendu :

| email | role | user_id | email_confirmed_at | profile_created |
|-------|------|---------|-------------------|-----------------|
| aimemaboundou@gmail.com | couple | [UUID] | [Date] | [Date] |
| zolasoll7@gmail.com | admin | [UUID] | [Date] | [Date] |

## 🧪 Étape 4 : Test de Connexion

### Test Admin
1. Ouvrez l'app ou allez à `/admin/login`
2. Email: `zolasoll7@gmail.com`
3. Mot de passe: `zola2026`
4. Cliquez **SE CONNECTER**
5. ✅ Vous devriez voir le tableau de bord admin

### Test Couple
1. Ouvrez l'app ou allez à `/admin/login`
2. Email: `aimemaboundou@gmail.com`
3. Mot de passe: `francis2026`
4. Cliquez **SE CONNECTER**
5. ✅ Vous devriez voir le tableau de bord couple

## 🚀 Alternative : Via Application

Si vous préférez utiliser l'app Flutter :

1. Ouvrez l'app
2. Allez à la route `/setup`
3. L'écran de configuration créera automatiquement les comptes
4. Attendez la confirmation de succès

## ⚠️ Dépannage

### Erreur : "Email already exists"
- Le compte existe déjà
- Utilisez "Reset password" pour changer le mot de passe
- Ou supprimez et recréez le compte

### Erreur : "Invalid password"
- Le mot de passe doit faire au moins 6 caractères
- Les mots de passe fournis sont valides

### L'utilisateur ne peut pas se connecter
1. Vérifiez que l'email est confirmé (colonne `email_confirmed_at`)
2. Vérifiez que le rôle est défini dans `user_profiles`
3. Exécutez la requête de vérification ci-dessus

### Le compte existe mais pas le profil utilisateur
Exécutez cette requête pour corriger :

```sql
INSERT INTO public.user_profiles (user_id, role, created_at, updated_at)
SELECT 
  id,
  CASE 
    WHEN email = 'zolasoll7@gmail.com' THEN 'admin'
    WHEN email = 'aimemaboundou@gmail.com' THEN 'couple'
    ELSE 'guest'
  END,
  now(),
  now()
FROM auth.users 
WHERE email IN ('zolasoll7@gmail.com', 'aimemaboundou@gmail.com')
ON CONFLICT (user_id) DO NOTHING;
```

## 🔐 Sécurité

### Recommandations de sécurité :

1. **Changez les mots de passe en production**
   ```sql
   -- Les mots de passe par défaut doivent être changés après première connexion
   -- Utilisez Supabase Dashboard > Auth > Users > Reset password
   ```

2. **Activez 2FA (si disponible)**
   ```
   Supabase Dashboard > Authentication > Settings > Enable 2FA
   ```

3. **Limitez les tentatives de connexion**
   ```
   Supabase Dashboard > Authentication > Settings > Rate Limiting
   ```

4. **Utilisez des variables d'environnement en production**
   - Ne stockez pas les credentials en dur dans le code
   - Utilisez `.env` ou les secrets du CI/CD

## 📚 Ressources Additionnelles

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase SDK](https://pub.dev/packages/supabase_flutter)
- [Guide d'authentification](SETUP_ACCOUNTS.md)
- [Fichier SQL de création](CREATE_COUPLE_ACCOUNT.sql)

## ✅ Checklist Finale

- [ ] Admin account exists: `zolasoll7@gmail.com`
- [ ] Admin role is `admin` in user_profiles
- [ ] Couple account created: `aimemaboundou@gmail.com`
- [ ] Couple role is `couple` in user_profiles
- [ ] Both email addresses are confirmed
- [ ] Admin can login at `/admin/login`
- [ ] Couple can login at `/admin/login`
- [ ] Admin sees admin dashboard
- [ ] Couple sees couple dashboard
