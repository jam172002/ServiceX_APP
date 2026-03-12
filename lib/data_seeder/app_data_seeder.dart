// ============================================================
// Firebase Firestore Data Seeding - Flutter/Dart
//
// ALL 20 real Firebase Auth UIDs are used:
//   FIXXERS (10): kamran, naveed, liam→Ali, karen→Bilal, james→Zara,
//                 isabelle→Usman, henry→Sara, grace→Tariq, frank→Nadia, emma→Omar
//   USERS   (10): jamshaid, olivia, noah, mia, david, carol, alice,
//                 admin, lrzOjga…(extra), XnDNd…(admin)
//
// HOW TO USE:
//   ElevatedButton(
//     onPressed: () => FirebaseSeed.seedAll(),
//     child: Text('Seed Data'),
//   )
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeed {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────
  // 10 FIXER UIDs
  // ─────────────────────────────────────────────────────────────
  static const String fKamran = 'BoTd9qwIKQZp6fXQS3gGSTdI40u2';
  static const String fNaveed = '5y7I8aAFA8gC01kYPFbXOdbRLW72';
  static const String fAli    = 'cbRUYYbdokhho3e8Yc1LbwPIjOv1'; // liam  → Ali Hassan
  static const String fBilal  = '3aKbzWpWSMQrwflAYeuekOaqMLv1'; // karen → Bilal Mahmood
  static const String fZara   = 'FudJ0iU8vKSpQEzZx2VNidYJpBy1'; // james → Zara Qureshi
  static const String fUsman  = '1Qby8x7CahfgJYmQjXJwqBpLalR2'; // isabelle → Usman Tariq
  static const String fSara   = '5YWuHv0zEGcEuyT7Y10GbK4zXEg2'; // henry → Sara Malik
  static const String fTariq  = 'FC5SlTxPdKQTWSDPgtWj9INvP2N2'; // grace → Tariq Mehmood
  static const String fNadia  = '9Tkv4zTLQHakvUmKpJKjCXWL32J2'; // frank → Nadia Iqbal
  static const String fOmar   = 'JZz8v4iLeWNtXtw71Co4MynOTem2'; // emma  → Omar Farooq

  // ─────────────────────────────────────────────────────────────
  // 10 USER UIDs
  // ─────────────────────────────────────────────────────────────
  static const String uJamshaid = 'NL6KXNm3cNcmD6k6VeM1pw3eAoZ2';
  static const String uOlivia   = 'stwI7fkTFGhmJaTnTbBUqc3O5mU2';
  static const String uNoah     = 'u45aUnT7BGQ60zZLDBljNE250sp1';
  static const String uMia      = 'Q0XIygCvyNWQ1Ilnbe4O6dMPCZM2';
  static const String uDavid    = 'NVJdjBrptxTXKfrBQnKRIOpYwRP2';
  static const String uCarol    = 'l0kqnPTRtvUC8zVGCn3xVti9ZwK2';
  static const String uAlice    = 'GFdVKZHcnWWD9kjMqfT7LzpSXZn1';
  static const String uAdmin    = 'XnDNdBJXfNQimZ2iB2y6jhIIYpw1';
  static const String uEmma     = 'lrzOjgaHD2VPufMjd08PMVogwcF2'; // was shown as extra in auth
  static const String uLiam2    = 'Q0XIygCvyNWQ1Ilnbe4O6dMPCZM2'; // spare (same as mia slot, adjust if needed)

  // ─────────────────────────────────────────────────────────────
  // CATEGORY IDs  (real Firestore IDs from your screenshots)
  // ─────────────────────────────────────────────────────────────
  static const String catElectric = 'a10fb40f-e0b0-4988-adc6-61eb976f9c91';
  static const String catMechanic = '4001a35d-579c-423e-a829-98b1df32c795';
  static const String catPlumbing = 'DNI7ExFTNOTsV00hCqrI';

  // ─────────────────────────────────────────────────────────────
  // SUBCATEGORY IDs  (real Firestore IDs from your screenshots)
  // ─────────────────────────────────────────────────────────────
  static const String subWiring       = '983bb5be-d6a7-4837-b5fb-7bae7679188a';
  static const String subLeakageFix   = '6bscFD7nguFZHTJSmL5M';
  static const String subAcRepair     = 'subcat-ac-repair-001';
  static const String subEngineRepair = 'subcat-engine-repair-001';
  static const String subTireChange   = 'subcat-tire-change-001';
  static const String subPipeInstall  = 'subcat-pipe-install-001';

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  static Timestamp daysAgo(int days, {int hours = 0}) =>
      Timestamp.fromDate(DateTime.now().subtract(Duration(days: days, hours: hours)));

  static Timestamp daysAhead(int days) =>
      Timestamp.fromDate(DateTime.now().add(Duration(days: days)));

  // ─────────────────────────────────────────────────────────────
  // LOCATIONS
  // ─────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> locs = [
    {'address': 'Mohala Abbassia, Ahmedpur East, Punjab, Pakistan', 'lat': 29.1519399, 'lng': 71.2613003},
    {'address': 'Model Town, Lahore, Punjab, Pakistan',             'lat': 31.4697,    'lng': 74.2728},
    {'address': 'F-10 Markaz, Islamabad, Pakistan',                 'lat': 33.6969,    'lng': 73.0167},
    {'address': 'Clifton Block 5, Karachi, Sindh, Pakistan',        'lat': 24.8138,    'lng': 67.0299},
    {'address': 'Saddar Bazaar, Rawalpindi, Punjab, Pakistan',      'lat': 33.5651,    'lng': 73.0169},
    {'address': 'New Kumbharwara, Karachi, Sindh, Pakistan',        'lat': 24.8736,    'lng': 67.0057},
    {'address': 'Gulshan-e-Iqbal, Karachi, Sindh, Pakistan',        'lat': 24.9215,    'lng': 67.0948},
    {'address': 'DHA Phase 6, Lahore, Punjab, Pakistan',            'lat': 31.4736,    'lng': 74.4026},
    {'address': 'Blue Area, Islamabad, Pakistan',                   'lat': 33.7294,    'lng': 73.0931},
    {'address': 'Hayatabad, Peshawar, KPK, Pakistan',               'lat': 34.0151,    'lng': 71.4315},
  ];

  // ═══════════════════════════════════════════════════════════════
  // MAIN ENTRY POINT
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedAll() async {
    print('🚀 Starting Firebase seed...');
    try {
      await seedServiceCategories();
      await seedServiceSubcategories();
      await seedUsers();
      await seedFixxers();
      await seedBookings();
      await seedJobRequests();
      await seedConversations();
      await seedWallets();
      print('✅ All collections seeded successfully!');
    } catch (e, st) {
      print('❌ Seeding error: $e\n$st');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SERVICE CATEGORIES
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedServiceCategories() async {
    print('  Seeding service_categories...');
    final batch = _db.batch();
    for (final c in [
      {'id': catElectric, 'name': 'Electric'},
      {'id': catMechanic, 'name': 'Mechanic'},
      {'id': catPlumbing, 'name': 'Plumbing'},
    ]) {
      batch.set(
        _db.collection('service_categories').doc(c['id']),
        {'name': c['name'], 'iconUrl': '', 'imageUrl': '', 'createdAt': daysAgo(30), 'updatedAt': daysAgo(1)},
      );
    }
    await batch.commit();
    print('  ✓ service_categories done');
  }

  // ═══════════════════════════════════════════════════════════════
  // SERVICE SUBCATEGORIES
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedServiceSubcategories() async {
    print('  Seeding service_subcategories...');
    final batch = _db.batch();
    for (final s in [
      {'id': subWiring,       'name': 'Wiring',            'categoryId': catElectric, 'icon': 'electric'},
      {'id': subLeakageFix,   'name': 'Leakage Fix',       'categoryId': catPlumbing, 'icon': 'plumbing'},
      {'id': subAcRepair,     'name': 'AC Repair',         'categoryId': catElectric, 'icon': 'ac_repair'},
      {'id': subEngineRepair, 'name': 'Engine Repair',     'categoryId': catMechanic, 'icon': 'mechanic'},
      {'id': subTireChange,   'name': 'Tire Change',       'categoryId': catMechanic, 'icon': 'mechanic'},
      {'id': subPipeInstall,  'name': 'Pipe Installation', 'categoryId': catPlumbing, 'icon': 'plumbing'},
    ]) {
      batch.set(
        _db.collection('service_subcategories').doc(s['id']),
        {'name': s['name'], 'categoryId': s['categoryId'], 'icon': s['icon'],
          'imageUrl': '', 'createdAt': daysAgo(28), 'updatedAt': daysAgo(1)},
      );
    }
    await batch.commit();
    print('  ✓ service_subcategories done');
  }

  // ═══════════════════════════════════════════════════════════════
  // USERS  (10 real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedUsers() async {
    print('  Seeding users...');
    final users = [
      _user(uJamshaid, 'Jamshaid',      'jamshaid@gmail.com',          '03001112233', 'male',   locs[0]),
      _user(uOlivia,   'Olivia Garcia', 'olivia.garcia@testapp.dev',   '03001234567', 'female', locs[1]),
      _user(uNoah,     'Noah Martin',   'noah.martin@testapp.dev',     '03011234567', 'male',   locs[2]),
      _user(uMia,      'Mia Harris',    'mia.harris@testapp.dev',      '03021234567', 'female', locs[3]),
      _user(uDavid,    'David Brown',   'david.brown@testapp.dev',     '03111234567', 'male',   locs[4]),
      _user(uCarol,    'Carol White',   'carol.white@testapp.dev',     '03121234567', 'female', locs[5]),
      _user(uAlice,    'Alice Johnson', 'alice.johnson@testapp.dev',   '03131234567', 'female', locs[6]),
      _user(uAdmin,    'Admin',         'admin@servicex.app',          '03000000000', 'male',   locs[7], role: 'admin'),
      _user(uEmma,     'Emma Davis',    'emma.davis@testapp.dev',      '03101234567', 'female', locs[8]),
      // Note: uLiam2 is same UID as uMia above — only seed 9 unique users
      // (your auth list has 20 entries; one is a duplicate slot)
    ];

    for (int i = 0; i < users.length; i += 10) {
      final batch = _db.batch();
      final chunk = users.sublist(i, (i + 10).clamp(0, users.length));
      for (final u in chunk) {
        final id = u['id'] as String;
        final data = Map<String, dynamic>.from(u)..remove('id');
        batch.set(_db.collection('users').doc(id), data, SetOptions(merge: true));
      }
      await batch.commit();
    }
    print('  ✓ users done');
  }

  static Map<String, dynamic> _user(
      String id, String name, String email, String phone, String gender,
      Map<String, dynamic> loc, {String role = 'user'}
      ) =>
      {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'role': role,
        'photoUrl': '',
        'isVerified': false,
        'location': {
          'address': loc['address'], 'lat': loc['lat'], 'lng': loc['lng'],
          'label': 'Home', 'isDefault': true,
        },
        'createdAt': daysAgo(10),
        'updatedAt': daysAgo(1),
      };

  // ═══════════════════════════════════════════════════════════════
  // FIXXERS  (10 real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedFixxers() async {
    print('  Seeding fixxers...');
    final fixxers = [
      _fixer(id: fKamran, name: 'Kamran',        email: 'kamran@gmail.com',
          phone: '03002234567', gender: 'Male',
          bio: 'Professional electrician with 8 years of experience in wiring and AC repair.',
          rate: 300, mainCat: catElectric, subCats: [subWiring, subAcRepair],
          days: ['Mon','Tue','Wed','Thu','Fri'], maxB: 4,
          langs: ['Urdu','Punjabi'], loc: locs[0], rating: 4.5, reviews: 18),

      _fixer(id: fNaveed, name: 'Naveed Echha',  email: 'naveed@gmail.com',
          phone: '03003234567', gender: 'Male',
          bio: "Experienced electrician. Wiring, socket repair and load management specialist.",
          rate: 200, mainCat: catElectric, subCats: [subWiring],
          days: ['Thu','Wed','Tue','Sat','Mon'], maxB: 5,
          langs: ['Urdu','Sindhi'], loc: locs[5], rating: 4.2, reviews: 12),

      _fixer(id: fAli, name: 'Ali Hassan',       email: 'ali.hassan@testapp.dev',
          phone: '03004234567', gender: 'Male',
          bio: 'Certified plumber — pipe installation, leak repairs, bathroom fittings.',
          rate: 250, mainCat: catPlumbing, subCats: [subLeakageFix, subPipeInstall],
          days: ['Mon','Tue','Wed','Thu','Sat'], maxB: 3,
          langs: ['Urdu','Punjabi'], loc: locs[1], rating: 4.7, reviews: 25),

      _fixer(id: fBilal, name: 'Bilal Mahmood',  email: 'bilal.mahmood@testapp.dev',
          phone: '03005234567', gender: 'Male',
          bio: 'Auto mechanic specializing in engine repair and tire services. 6 years exp.',
          rate: 350, mainCat: catMechanic, subCats: [subEngineRepair, subTireChange],
          days: ['Mon','Wed','Fri','Sat'], maxB: 4,
          langs: ['Urdu','Sindhi'], loc: locs[3], rating: 3.9, reviews: 8),

      _fixer(id: fZara, name: 'Zara Qureshi',    email: 'zara.qureshi@testapp.dev',
          phone: '03006234567', gender: 'Female',
          bio: 'Experienced female electrician. AC repair and wiring specialist.',
          rate: 280, mainCat: catElectric, subCats: [subWiring, subAcRepair],
          days: ['Tue','Thu','Fri','Sun'], maxB: 3,
          langs: ['Urdu','English'], loc: locs[2], rating: 4.8, reviews: 31),

      _fixer(id: fUsman, name: 'Usman Tariq',    email: 'usman.tariq@testapp.dev',
          phone: '03007234567', gender: 'Male',
          bio: 'Plumbing expert with 10 years in residential and commercial work.',
          rate: 320, mainCat: catPlumbing, subCats: [subLeakageFix, subPipeInstall],
          days: ['Mon','Tue','Thu','Sat'], maxB: 5,
          langs: ['Urdu','Punjabi','English'], loc: locs[4], rating: 4.3, reviews: 20),

      _fixer(id: fSara, name: 'Sara Malik',      email: 'sara.malik@testapp.dev',
          phone: '03008234567', gender: 'Female',
          bio: 'Skilled mechanic — engine diagnostics and general car maintenance.',
          rate: 300, mainCat: catMechanic, subCats: [subEngineRepair, subTireChange],
          days: ['Mon','Tue','Wed','Sat'], maxB: 3,
          langs: ['Urdu','Punjabi'], loc: locs[6], rating: 4.1, reviews: 14),

      _fixer(id: fTariq, name: 'Tariq Mehmood',  email: 'tariq.mehmood@testapp.dev',
          phone: '03009234567', gender: 'Male',
          bio: 'Electrician and AC technician. Prompt service, affordable rates.',
          rate: 260, mainCat: catElectric, subCats: [subAcRepair, subWiring],
          days: ['Wed','Thu','Fri','Sat','Sun'], maxB: 4,
          langs: ['Urdu'], loc: locs[7], rating: 4.0, reviews: 9),

      _fixer(id: fNadia, name: 'Nadia Iqbal',    email: 'nadia.iqbal@testapp.dev',
          phone: '03010234567', gender: 'Female',
          bio: 'Plumber specializing in leak repair and bathroom fittings. Fast response.',
          rate: 240, mainCat: catPlumbing, subCats: [subLeakageFix],
          days: ['Mon','Wed','Fri'], maxB: 3,
          langs: ['Urdu','Sindhi'], loc: locs[8], rating: 4.6, reviews: 22),

      _fixer(id: fOmar, name: 'Omar Farooq',     email: 'omar.farooq@testapp.dev',
          phone: '03011234567', gender: 'Male',
          bio: 'All-round mechanic. Tire change, engine oil, general car servicing.',
          rate: 280, mainCat: catMechanic, subCats: [subTireChange, subEngineRepair],
          days: ['Tue','Thu','Sat','Sun'], maxB: 5,
          langs: ['Urdu','Punjabi'], loc: locs[9], rating: 3.8, reviews: 6),
    ];

    for (int i = 0; i < fixxers.length; i += 10) {
      final batch = _db.batch();
      final chunk = fixxers.sublist(i, (i + 10).clamp(0, fixxers.length));
      for (final f in chunk) {
        final id = f['id'] as String;
        final data = Map<String, dynamic>.from(f)..remove('id');
        batch.set(_db.collection('fixxers').doc(id), data, SetOptions(merge: true));
      }
      await batch.commit();
    }
    print('  ✓ fixxers done');
  }

  static Map<String, dynamic> _fixer({
    required String id, required String name, required String email,
    required String phone, required String gender, required String bio,
    required int rate, required String mainCat, required List<String> subCats,
    required List<String> days, required int maxB, required List<String> langs,
    required Map<String, dynamic> loc, required double rating, required int reviews,
  }) =>
      {
        'id': id, 'uid': id,
        'fullName': name, 'email': email, 'phone': phone, 'gender': gender, 'bio': bio,
        'hourlyRate': rate,
        'mainCategory': mainCat,
        'subCategories': subCats,
        'availableDays': days,
        'maxBookingsPerDay': maxB,
        'languages': langs,
        'location': {'address': loc['address'], 'lat': loc['lat'], 'lng': loc['lng']},
        'profileImageUrl': '', 'bannerImageUrl': '', 'serviceImages': [],
        'profileComplete': true,
        'rating': rating,
        'totalReviews': reviews,
        'createdAt': daysAgo(20),
        'updatedAt': daysAgo(1),
      };

  // ═══════════════════════════════════════════════════════════════
  // BOOKINGS  (12 — all real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedBookings() async {
    print('  Seeding bookings...');
    final bookings = [
      _booking(id: 'booking-seed-001', client: uJamshaid, fixer: fKamran,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[0], min: 100, max: 500, details: 'Need complete wiring done for a new room.',
          pay: 'Mobile Transfer', status: 'pending', sched: daysAhead(2), created: daysAgo(1)),

      _booking(id: 'booking-seed-002', client: uJamshaid, fixer: fNaveed,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[0], min: 50, max: 150, details: 'Fix broken socket and rewire living room switches.',
          pay: 'Cash', status: 'confirmed', sched: daysAhead(1), created: daysAgo(3)),

      _booking(id: 'booking-seed-003', client: uOlivia, fixer: fAli,
          catId: catPlumbing, catName: 'Plumbing', subId: subLeakageFix, subName: 'Leakage Fix',
          loc: locs[1], min: 200, max: 600, details: 'Bathroom pipe leaking badly, water damage on floor.',
          pay: 'Mobile Transfer', status: 'completed', sched: daysAgo(5), created: daysAgo(7)),

      _booking(id: 'booking-seed-004', client: uNoah, fixer: fBilal,
          catId: catMechanic, catName: 'Mechanic', subId: subEngineRepair, subName: 'Engine Repair',
          loc: locs[2], min: 300, max: 800, details: 'Car engine making strange noise, oil leak suspected.',
          pay: 'Cash', status: 'completed', sched: daysAgo(10), created: daysAgo(12)),

      _booking(id: 'booking-seed-005', client: uMia, fixer: fKamran,
          catId: catElectric, catName: 'Electric', subId: subAcRepair, subName: 'AC Repair',
          loc: locs[3], min: 150, max: 400, details: 'AC not cooling, compressor might be faulty.',
          pay: 'Mobile Transfer', status: 'in_progress', sched: daysAgo(0, hours: 2), created: daysAgo(2)),

      _booking(id: 'booking-seed-006', client: uDavid, fixer: fZara,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[4], min: 80, max: 250, details: 'Short circuit in kitchen, need immediate repair.',
          pay: 'Cash', status: 'cancelled', sched: daysAgo(3), created: daysAgo(5)),

      _booking(id: 'booking-seed-007', client: uCarol, fixer: fUsman,
          catId: catPlumbing, catName: 'Plumbing', subId: subPipeInstall, subName: 'Pipe Installation',
          loc: locs[5], min: 200, max: 700, details: 'New water supply pipes for full bathroom renovation.',
          pay: 'Mobile Transfer', status: 'pending', sched: daysAhead(3), created: daysAgo(0, hours: 5)),

      _booking(id: 'booking-seed-008', client: uAlice, fixer: fSara,
          catId: catMechanic, catName: 'Mechanic', subId: subTireChange, subName: 'Tire Change',
          loc: locs[6], min: 100, max: 300, details: 'All 4 tires need replacing, car pulls to the right.',
          pay: 'Cash', status: 'confirmed', sched: daysAhead(1), created: daysAgo(1)),

      _booking(id: 'booking-seed-009', client: uJamshaid, fixer: fZara,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[2], min: 100, max: 350, details: 'Install new light fixtures and rewire dining room.',
          pay: 'Mobile Transfer', status: 'completed', sched: daysAgo(8), created: daysAgo(10)),

      _booking(id: 'booking-seed-010', client: uNoah, fixer: fTariq,
          catId: catElectric, catName: 'Electric', subId: subAcRepair, subName: 'AC Repair',
          loc: locs[7], min: 200, max: 500, details: 'AC gas refill and compressor check needed.',
          pay: 'Mobile Transfer', status: 'pending', sched: daysAhead(2), created: daysAgo(0, hours: 3)),

      _booking(id: 'booking-seed-011', client: uDavid, fixer: fNadia,
          catId: catPlumbing, catName: 'Plumbing', subId: subLeakageFix, subName: 'Leakage Fix',
          loc: locs[8], min: 50, max: 200, details: 'Rooftop water tank overflow pipe blocked.',
          pay: 'Cash', status: 'confirmed', sched: daysAhead(1), created: daysAgo(2)),

      _booking(id: 'booking-seed-012', client: uEmma, fixer: fOmar,
          catId: catMechanic, catName: 'Mechanic', subId: subEngineRepair, subName: 'Engine Repair',
          loc: locs[9], min: 400, max: 1200, details: 'Engine oil change and full car service.',
          pay: 'Cash', status: 'completed', sched: daysAgo(6), created: daysAgo(8)),
    ];

    for (final b in bookings) {
      final id = b['id'] as String;
      final data = Map<String, dynamic>.from(b)..remove('id');
      await _db.collection('bookings').doc(id).set(data);
    }
    print('  ✓ bookings done');
  }

  static Map<String, dynamic> _booking({
    required String id, required String client, required String fixer,
    required String catId, required String catName,
    required String subId, required String subName,
    required Map<String, dynamic> loc, required int min, required int max,
    required String details, required String pay, required String status,
    required Timestamp sched, required Timestamp created,
  }) =>
      {
        'id': id, 'clientId': client, 'fixerId': fixer,
        'categoryId': catId, 'categoryName': catName,
        'subcategoryId': subId, 'subcategoryName': subName,
        'address': loc['address'], 'lat': loc['lat'], 'lng': loc['lng'],
        'budgetMin': min, 'budgetMax': max,
        'details': details, 'paymentMethod': pay, 'status': status,
        'imageUrls': [],
        'scheduledAt': sched, 'createdAt': created, 'updatedAt': created,
      };

  // ═══════════════════════════════════════════════════════════════
  // JOB REQUESTS  (8 — all real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedJobRequests() async {
    print('  Seeding job_requests...');
    final jobs = [
      _job(id: 'job-seed-001', userId: uOlivia,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[1], min: 100, max: 400, details: 'Short circuit in garage needs immediate fix.',
          pay: 'Cash', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(1), created: daysAgo(0, hours: 3)),

      _job(id: 'job-seed-002', userId: uNoah,
          catId: catPlumbing, catName: 'Plumbing', subId: subLeakageFix, subName: 'Leakage Fix',
          loc: locs[2], min: 150, max: 500, details: 'Underground pipe leakage causing damp walls.',
          pay: 'Mobile Transfer', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(2), created: daysAgo(0, hours: 6)),

      _job(id: 'job-seed-003', userId: uMia,
          catId: catMechanic, catName: 'Mechanic', subId: subEngineRepair, subName: 'Engine Repair',
          loc: locs[3], min: 500, max: 2000, details: 'Car completely dead, full engine diagnostic needed.',
          pay: 'Cash', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(1), created: daysAgo(1)),

      _job(id: 'job-seed-004', userId: uCarol,
          catId: catElectric, catName: 'Electric', subId: subAcRepair, subName: 'AC Repair',
          loc: locs[5], min: 200, max: 600, details: 'AC unit making loud noise, not cooling at all.',
          pay: 'Mobile Transfer', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(3), created: daysAgo(0, hours: 2)),

      _job(id: 'job-seed-005', userId: uJamshaid,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[0], min: 50, max: 640, details: 'Rare wiring case this weekend, urgent.',
          pay: 'Mobile Transfer', isOpen: false, provider: fKamran, status: 'pending',
          sched: daysAgo(3), created: daysAgo(3)),

      _job(id: 'job-seed-006', userId: uAlice,
          catId: catPlumbing, catName: 'Plumbing', subId: subPipeInstall, subName: 'Pipe Installation',
          loc: locs[6], min: 300, max: 900, details: 'Full bathroom pipe installation for new construction.',
          pay: 'Cash', isOpen: false, provider: fUsman, status: 'accepted',
          sched: daysAhead(2), created: daysAgo(2)),

      _job(id: 'job-seed-007', userId: uDavid,
          catId: catMechanic, catName: 'Mechanic', subId: subTireChange, subName: 'Tire Change',
          loc: locs[4], min: 100, max: 350, details: 'Flat tire on highway, need mobile tire change.',
          pay: 'Cash', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(1), created: daysAgo(0, hours: 4)),

      _job(id: 'job-seed-008', userId: uJamshaid,
          catId: catElectric, catName: 'Electric', subId: subWiring, subName: 'Wiring',
          loc: locs[0], min: 80, max: 300, details: 'Garden lighting installation, weatherproof fittings.',
          pay: 'Mobile Transfer', isOpen: true, provider: null, status: 'pending',
          sched: daysAhead(4), created: daysAgo(0, hours: 8)),
    ];

    for (final j in jobs) {
      final id = j['id'] as String;
      final data = Map<String, dynamic>.from(j)..remove('id');
      await _db.collection('job_requests').doc(id).set(data);
    }
    print('  ✓ job_requests done');
  }

  static Map<String, dynamic> _job({
    required String id, required String userId,
    required String catId, required String catName,
    required String subId, required String subName,
    required Map<String, dynamic> loc, required int min, required int max,
    required String details, required String pay,
    required bool isOpen, required String? provider, required String status,
    required Timestamp sched, required Timestamp created,
  }) =>
      {
        'id': id, 'userId': userId,
        'categoryId': catId, 'categoryName': catName,
        'subcategoryId': subId, 'subcategoryName': subName,
        'address': loc['address'], 'lat': loc['lat'], 'lng': loc['lng'],
        'budgetMin': min, 'budgetMax': max,
        'details': details, 'paymentMethod': pay,
        'isOpenForAll': isOpen, 'providerId': provider, 'status': status,
        'imageUrls': [],
        'scheduledAt': sched, 'createdAt': created, 'updatedAt': created,
      };

  // ═══════════════════════════════════════════════════════════════
  // CONVERSATIONS + MESSAGES  (all real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedConversations() async {
    print('  Seeding conversations...');

    final convs = [
      _convDef(p1: uJamshaid, p2: fKamran,
          lastMsg: 'Okay, I will be there at 9 AM', lastSender: fKamran,
          lastTime: daysAgo(0, hours: 1), unread: {uJamshaid: 2, fKamran: 0},
          msgs: [
            _msg(uJamshaid, fKamran, 'Hi Kamran, are you available tomorrow for wiring?', true,  daysAgo(1, hours: 2)),
            _msg(fKamran,   uJamshaid, 'Yes I am free tomorrow morning.',                true,  daysAgo(1, hours: 1)),
            _msg(uJamshaid, fKamran, 'Perfect, can you come at 9 AM?',                  true,  daysAgo(1)),
            _msg(fKamran,   uJamshaid, 'Okay, I will be there at 9 AM',                 false, daysAgo(0, hours: 1)),
          ]),

      _convDef(p1: uJamshaid, p2: fNaveed,
          lastMsg: 'hello', lastSender: uJamshaid,
          lastTime: daysAgo(1), unread: {fNaveed: 6, uJamshaid: 0},
          msgs: [
            _msg(fNaveed,   uJamshaid, 'what why',                              true,  daysAgo(3)),
            _msg(uJamshaid, fNaveed,   'Can you help me with wiring?',          true,  daysAgo(2)),
            _msg(fNaveed,   uJamshaid, 'Sure, tell me more details.',            true,  daysAgo(2)),
            _msg(uJamshaid, fNaveed,   'New room, ground floor.',                true,  daysAgo(2)),
            _msg(fNaveed,   uJamshaid, 'Okay I can come this weekend.',          false, daysAgo(1)),
            _msg(uJamshaid, fNaveed,   'hello',                                  false, daysAgo(1)),
          ]),

      _convDef(p1: uOlivia, p2: fAli,
          lastMsg: 'The pipe is fixed, please confirm payment.', lastSender: fAli,
          lastTime: daysAgo(5), unread: {uOlivia: 1, fAli: 0},
          msgs: [
            _msg(uOlivia, fAli, 'My bathroom pipe is leaking very badly.', true,  daysAgo(7)),
            _msg(fAli, uOlivia, 'I can come tomorrow morning.',             true,  daysAgo(7)),
            _msg(uOlivia, fAli, 'Please come before 10 AM.',               true,  daysAgo(6)),
            _msg(fAli, uOlivia, 'The pipe is fixed, please confirm payment.', false, daysAgo(5)),
          ]),

      _convDef(p1: uMia, p2: fKamran,
          lastMsg: 'I am on my way', lastSender: fKamran,
          lastTime: daysAgo(0, hours: 2), unread: {uMia: 1, fKamran: 0},
          msgs: [
            _msg(uMia,   fKamran, 'My AC is not working, can you fix it today?', true,  daysAgo(0, hours: 4)),
            _msg(fKamran, uMia,   'Yes, I can come in 2 hours.',                 true,  daysAgo(0, hours: 3)),
            _msg(uMia,   fKamran, 'Great! Please bring gas refill kit.',         true,  daysAgo(0, hours: 3)),
            _msg(fKamran, uMia,   'I am on my way',                              false, daysAgo(0, hours: 2)),
          ]),

      _convDef(p1: uNoah, p2: fBilal,
          lastMsg: 'Engine repair done, total bill Rs. 4500', lastSender: fBilal,
          lastTime: daysAgo(10), unread: {uNoah: 0, fBilal: 0},
          msgs: [
            _msg(uNoah,  fBilal, 'My car engine is making a strange noise.', true, daysAgo(12)),
            _msg(fBilal, uNoah,  'Send me the model and year of your car.',   true, daysAgo(12)),
            _msg(uNoah,  fBilal, 'Toyota Corolla 2018.',                      true, daysAgo(11)),
            _msg(fBilal, uNoah,  'Engine repair done, total bill Rs. 4500',   true, daysAgo(10)),
          ]),

      _convDef(p1: uDavid, p2: fZara,
          lastMsg: 'Can you come Friday morning?', lastSender: uDavid,
          lastTime: daysAgo(0, hours: 5), unread: {uDavid: 0, fZara: 1},
          msgs: [
            _msg(uDavid, fZara, 'I need wiring fixed in my shop.',       true,  daysAgo(1)),
            _msg(fZara,  uDavid, 'Sure, what area are you in?',          true,  daysAgo(1)),
            _msg(uDavid, fZara, 'Can you come Friday morning?',          false, daysAgo(0, hours: 5)),
          ]),

      _convDef(p1: uCarol, p2: fUsman,
          lastMsg: 'I will bring all fittings, no worries.', lastSender: fUsman,
          lastTime: daysAgo(2), unread: {uCarol: 1, fUsman: 0},
          msgs: [
            _msg(uCarol, fUsman, 'I need full bathroom pipe installation.',        true,  daysAgo(3)),
            _msg(fUsman, uCarol, 'Okay, what is the size of the bathroom?',        true,  daysAgo(3)),
            _msg(uCarol, fUsman, 'Standard size, 2 toilets and a shower.',         true,  daysAgo(2)),
            _msg(fUsman, uCarol, 'I will bring all fittings, no worries.',         false, daysAgo(2)),
          ]),

      _convDef(p1: uAlice, p2: fSara,
          lastMsg: 'Done! Your car is ready for pickup.', lastSender: fSara,
          lastTime: daysAgo(4), unread: {uAlice: 0, fSara: 0},
          msgs: [
            _msg(uAlice, fSara, 'Car engine needs full service.',          true, daysAgo(6)),
            _msg(fSara,  uAlice, 'Bring it in tomorrow at 10 AM.',         true, daysAgo(5)),
            _msg(fSara,  uAlice, 'Done! Your car is ready for pickup.',    true, daysAgo(4)),
          ]),

      _convDef(p1: uEmma, p2: fTariq,
          lastMsg: 'AC is fully fixed now.', lastSender: fTariq,
          lastTime: daysAgo(3), unread: {uEmma: 1, fTariq: 0},
          msgs: [
            _msg(uEmma,  fTariq, 'My AC stopped working suddenly.',        true,  daysAgo(5)),
            _msg(fTariq, uEmma,  'Most likely a capacitor issue. I can check tomorrow.', true, daysAgo(4)),
            _msg(fTariq, uEmma,  'AC is fully fixed now.',                 false, daysAgo(3)),
          ]),
    ];

    for (final c in convs) {
      final p1 = c['p1'] as String;
      final p2 = c['p2'] as String;
      final convId = '${p1}_$p2';
      final msgs = c['msgs'] as List<Map<String, dynamic>>;
      final unread = c['unread'] as Map<String, int>;

      final ref = _db.collection('conversations').doc(convId);
      await ref.set({
        'participants': [p1, p2],
        'participantAvatars': {p1: '', p2: ''},
        'participantNames':   {p1: '', p2: ''},
        'fcmTokens':          {p1: '', p2: ''},
        'lastMessage':        c['lastMsg'],
        'lastMessageSenderId': c['lastSender'],
        'lastMessageTime':    c['lastTime'],
        'unreadCount':        unread,
      });

      for (final m in msgs) {
        await ref.collection('messages').add(m);
      }
    }
    print('  ✓ conversations done');
  }

  static Map<String, dynamic> _convDef({
    required String p1, required String p2,
    required String lastMsg, required String lastSender, required Timestamp lastTime,
    required Map<String, int> unread, required List<Map<String, dynamic>> msgs,
  }) =>
      {'p1': p1, 'p2': p2, 'lastMsg': lastMsg, 'lastSender': lastSender,
        'lastTime': lastTime, 'unread': unread, 'msgs': msgs};

  static Map<String, dynamic> _msg(
      String sender, String receiver, String text, bool isRead, Timestamp at) =>
      {'senderId': sender, 'receiverId': receiver, 'text': text,
        'type': 'text', 'isRead': isRead, 'createdAt': at};

  // ═══════════════════════════════════════════════════════════════
  // WALLETS  (all 19 unique real UIDs)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> seedWallets() async {
    print('  Seeding wallets...');

    final fixerIds = {fKamran, fNaveed, fAli, fBilal, fZara, fUsman, fSara, fTariq, fNadia, fOmar};

    final wallets = {
      // Users
      uJamshaid: 1500, uOlivia: 3000,  uNoah: 2500,
      uMia: 800,       uDavid: 4200,   uCarol: 5000,
      uAlice: 2200,    uAdmin: 0,       uEmma: 1800,
      // Fixxers
      fKamran: 8500,   fNaveed: 12000,  fAli: 6500,
      fBilal: 9000,    fZara: 3500,     fUsman: 7200,
      fSara: 4800,     fTariq: 3100,    fNadia: 5500,
      fOmar: 2900,
    };

    final batch = _db.batch();
    wallets.forEach((uid, balance) {
      batch.set(
        _db.collection('wallets').doc(uid),
        {
          'userId': uid,
          'balance': balance,
          'currency': 'PKR',
          'role': fixerIds.contains(uid) ? 'fixer' : 'user',
          'transactions': [],
          'createdAt': daysAgo(20),
          'updatedAt': daysAgo(1),
        },
        SetOptions(merge: true),
      );
    });
    await batch.commit();
    print('  ✓ wallets done');
  }
}