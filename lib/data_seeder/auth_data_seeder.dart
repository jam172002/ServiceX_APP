/// Firebase Auth Data Seeder
/// -------------------------
/// Run this file as a standalone Dart script (or call seedUsers() from your app)
/// to create 15 test users in Firebase Authentication.
///
/// Dependencies (pubspec.yaml):
///   firebase_core: ^3.0.0
///   firebase_auth: ^5.0.0
///
/// Usage:
///   1. Make sure your app is initialised with Firebase before calling seedUsers().
///   2. Call `await FirebaseSeeder.seedUsers();` from main() or a debug button.
///   3. Check the console for results.

import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// Test user definitions
// ---------------------------------------------------------------------------

class _SeedUser {
  const _SeedUser({
    required this.email,
    required this.password,
    required this.displayName,
  });
  final String email;
  final String password;
  final String displayName;
}

const List<_SeedUser> _testUsers = [
  _SeedUser(
    email: 'alice.johnson@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Alice Johnson',
  ),
  _SeedUser(
    email: 'bob.smith@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Bob Smith',
  ),
  _SeedUser(
    email: 'carol.white@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Carol White',
  ),
  _SeedUser(
    email: 'david.brown@testapp.dev',
    password: 'Test@1234!',
    displayName: 'David Brown',
  ),
  _SeedUser(
    email: 'emma.davis@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Emma Davis',
  ),
  _SeedUser(
    email: 'frank.miller@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Frank Miller',
  ),
  _SeedUser(
    email: 'grace.wilson@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Grace Wilson',
  ),
  _SeedUser(
    email: 'henry.moore@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Henry Moore',
  ),
  _SeedUser(
    email: 'isabelle.taylor@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Isabelle Taylor',
  ),
  _SeedUser(
    email: 'james.anderson@testapp.dev',
    password: 'Test@1234!',
    displayName: 'James Anderson',
  ),
  _SeedUser(
    email: 'karen.thomas@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Karen Thomas',
  ),
  _SeedUser(
    email: 'liam.jackson@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Liam Jackson',
  ),
  _SeedUser(
    email: 'mia.harris@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Mia Harris',
  ),
  _SeedUser(
    email: 'noah.martin@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Noah Martin',
  ),
  _SeedUser(
    email: 'olivia.garcia@testapp.dev',
    password: 'Test@1234!',
    displayName: 'Olivia Garcia',
  ),
];

// ---------------------------------------------------------------------------
// Seeder class
// ---------------------------------------------------------------------------

class FirebaseSeeder {
  FirebaseSeeder._();

  /// Creates all 15 test users in Firebase Auth.
  ///
  /// Skips users that already exist (email-already-in-use).
  /// Prints a summary to the debug console when done.
  static Future<void> seedUsers() async {
    final auth = FirebaseAuth.instance;

    int created = 0;
    int skipped = 0;
    int failed = 0;

    print('========================================');
    print('  Firebase Auth Seeder — starting…');
    print('========================================');

    for (final user in _testUsers) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: user.email,
          password: user.password,
        );

        // Set the display name on the newly created user
        await credential.user?.updateDisplayName(user.displayName);
        await credential.user?.reload();

        print('✅  Created  : ${user.displayName} <${user.email}>');
        created++;

        // Sign out immediately so the loop can continue creating other accounts
        await auth.signOut();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('⏭️  Skipped  : ${user.email} (already exists)');
          skipped++;
        } else {
          print('❌  Failed   : ${user.email} — ${e.code}: ${e.message}');
          failed++;
        }
      } catch (e) {
        print('❌  Error    : ${user.email} — $e');
        failed++;
      }
    }

    print('========================================');
    print('  Done. Created: $created | Skipped: $skipped | Failed: $failed');
    print('========================================');
  }

  /// Deletes all 15 seed users from Firebase Auth.
  ///
  /// ⚠️  Each user must be signed in before deletion.
  /// This helper signs each user in, deletes them, then signs out.
  /// Use only in development / test environments.
  static Future<void> deleteSeededUsers() async {
    final auth = FirebaseAuth.instance;

    int deleted = 0;
    int skipped = 0;

    print('========================================');
    print('  Firebase Auth Seeder — deleting users…');
    print('========================================');

    for (final user in _testUsers) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: user.email,
          password: user.password,
        );

        await credential.user?.delete();
        print('🗑️  Deleted  : ${user.email}');
        deleted++;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('⏭️  Skipped  : ${user.email} (not found)');
          skipped++;
        } else {
          print('❌  Failed   : ${user.email} — ${e.code}: ${e.message}');
        }
      } catch (e) {
        print('❌  Error    : ${user.email} — $e');
      }
    }

    print('========================================');
    print('  Done. Deleted: $deleted | Skipped: $skipped');
    print('========================================');
  }
} 

// ---------------------------------------------------------------------------
// Example — call from your app's main() or a debug screen button:
// ---------------------------------------------------------------------------
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Seed users once, then comment out or guard with a flag
//   await FirebaseSeeder.seedUsers();
//
//   runApp(const MyApp());
// }