import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('wishlist');
  }

  // Add (upsert) a wishlist item
  Future<void> add(WishlistItem item) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    final docRef = col.doc(item.productId.toString());
    await docRef.set(item.toJson(), SetOptions(merge: true));
  }

  // Remove by productId
  Future<void> remove(int productId) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    await col.doc(productId.toString()).delete();
  }

  // Toggle by product object
  Future<void> toggle(dynamic product) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    final id = (product.id ?? 0) as int;
    final ref = col.doc(id.toString());
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set(WishlistItem.fromProduct(product).toJson());
    }
  }

  // Is product in wishlist?
  Future<bool> isInWishlist(int productId) async {
    final col = _col;
    if (col == null) return false;
    final snap = await col.doc(productId.toString()).get();
    return snap.exists;
  }

  // Stream for real-time UI
  Stream<List<WishlistItem>> stream() {
    final col = _col;
    if (col == null) return Stream.value([]);
    return col
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => WishlistItem.fromJson(d.data())).toList(),
        );
  }

  // One-shot fetch (if needed)
  Future<List<WishlistItem>> getAll() async {
    final col = _col;
    if (col == null) return [];
    final q = await col.orderBy('addedAt', descending: true).get();
    return q.docs.map((d) => WishlistItem.fromJson(d.data())).toList();
  }
}
