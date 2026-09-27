import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

/// Contract for loading and saving expenses.
///
/// A Firestore-backed implementation can be added here later without coupling
/// the UI directly to Firebase.
abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchExpenses();

  Future<void> saveExpense(Expense expense);

  Future<void> deleteExpense(String id);
}

/// Firestore implementation using one top-level collection for this app.
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(this._firestore);

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  @override
  Stream<List<Expense>> watchExpenses() => _expenses
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => Expense.fromMap(doc.id, doc.data()))
                .toList(),
      );

  @override
  Future<void> saveExpense(Expense expense) async {
    final document =
        expense.id.isEmpty ? _expenses.doc() : _expenses.doc(expense.id);

    // Firestore updates its local cache before the server acknowledges a
    // write. Complete on that local snapshot so the form doesn't spin forever
    // when the device is offline or Firebase is still being configured.
    final locallySaved = document
        .snapshots(includeMetadataChanges: true)
        .firstWhere(
          (snapshot) => snapshot.exists && snapshot.metadata.hasPendingWrites,
        )
        .then<void>((_) {});
    final serverWrite = document.set(expense.toMap());

    // If the server responds first (or rejects the write immediately), retain
    // that result; otherwise the optimistic local write is enough to finish
    // the UI action while Firestore continues syncing in the background.
    await Future.any<void>([locallySaved, serverWrite]);
  }

  @override
  Future<void> deleteExpense(String id) => _expenses.doc(id).delete();
}
