import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // دالة تُستدعى تلقائياً عند تشغيل التطبيق للتحقق من تسجيل الدخول السابق
  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    // لا نستخدم notifyListeners هنا لأنها داخل الـ Constructor

    User? user = _auth.currentUser; // فحص هل يوجد جلسة نشطة في فايربيس
    if (user != null) {
      try {
        // جلب صلاحيات المستخدم من قاعدة البيانات
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _currentUser = UserModel(
            id: data['id'] ?? user.uid,
            name: data['name'] ?? 'مستخدم',
            email: data['email'] ?? user.email!,
            role: data['role'] ?? 'reader',
          );
        }
      } catch (e) {
        debugPrint('خطأ في استرجاع الجلسة: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // 1. إنشاء حساب موظف جديد وحفظ صلاحيته
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      // إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // إنشاء نموذج المستخدم
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email.trim(),
        role: role,
      );

      // حفظ البيانات في Firestore لكي نعرف صلاحياته لاحقاً
      await _firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً.';
      } else if (e.code == 'weak-password') {
        _errorMessage = 'كلمة المرور ضعيفة جداً.';
      } else {
        _errorMessage = 'حدث خطأ: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 2. تسجيل الدخول الفعلي عبر Firebase وجلب الصلاحيات
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // أ. المصادقة مع Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // ب. جلب بيانات المستخدم (لمعرفة الصلاحية) من Firestore
      DocumentSnapshot doc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentUser = UserModel(
          id: data['id'] ?? userCredential.user!.uid,
          name: data['name'] ?? 'مستخدم',
          email: data['email'] ?? email,
          role: data['role'] ?? 'reader',
        );
      } else {
        // إذا كان الحساب موجوداً في Auth ولم نجد وثيقته في Firestore
        _currentUser = UserModel(
          id: userCredential.user!.uid,
          name: 'حساب جديد',
          email: email,
          role: 'reader', // نعطيه صلاحية دنيا كإجراء أمني
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      } else {
        _errorMessage = 'حدث خطأ في تسجيل الدخول: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. تسجيل الخروج الفعلي
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
