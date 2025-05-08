import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 注册新用户
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // 创建用户
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 创建用户文档
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        // 'lastLogin': FieldValue.serverTimestamp(),
        'accessTokens': {}, // 初始化空的access tokens map
      });

      return userCredential;
    } catch (e) {
      print("sign up error: $e");
      rethrow;
    }
  }

  // 登录
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 临时注释掉 Firestore 更新，排查问题
      // await firestore
      //     .collection('users')
      //     .doc(userCredential.user!.uid)
      //     .update({
      //   'lastLogin': FieldValue.serverTimestamp(),
      // });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 获取当前用户
  User? get currentUser => _auth.currentUser;

  // 监听认证状态变化
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 获取所有access tokens
  Future<Map<String, String>> getAccessTokens() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    final doc = await firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null || !data.containsKey('accessTokens')) return {};

    return Map<String, String>.from(data['accessTokens']);
  }

  // 获取特定institution的access token
  Future<String?> getAccessToken(String institutionId) async {
    final tokens = await getAccessTokens();
    return tokens[institutionId];
  }

  // 删除特定institution的access token
  Future<void> deleteAccessToken(String institutionId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // await firestore.collection('users').doc(userId).update({
    //   'accessTokens.$institutionId': FieldValue.delete(),
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
  }
}
