import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/data/datasources/abstract/auth/auth_remote_data_source.dart';
import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/parameters/auth_parameter.dart';
import 'package:digital_shores/core/utils/firebase_auth_exception_otp_parse.dart';
import 'package:digital_shores/core/utils/pin_hasher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthRemoteDataSourceFirebase implements AuthRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  AuthRemoteDataSourceFirebase({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  @override
  Future<void> deleteAccount(DeleteAccountParameter parameter) async {
    final userId = parameter.userId;

    final userDoc = await firestore.collection('users').doc(userId).get();

    // check user password
    // Get the stored salt and hashed PIN
    final storedSalt = userDoc.data()!['pin_salt'] as String;
    final storedHashedPin = userDoc.data()!['pin'] as String;

    // Verify the PIN
    if (!PinHasher.verifyPin(parameter.pin, storedHashedPin, storedSalt)) {
      throw CustomException('PIN salah');
    }

    await firestore.runTransaction(
      (transaction) async {
        // delete user image in storage
        // check if user has image
        final userDoc = await firestore.collection('users').doc(userId).get();

        for (final collection in kCollections) {
          // delete user record data in firestore
          final querySnapshot = await firestore
              .collection(collection)
              .where(
                'user_id',
                isEqualTo: userId,
              )
              .get();

          // if collection is administration_documents, delete the document_image in firestore
          for (final doc in querySnapshot.docs) {
            if (collection == 'administration_documents') {
              final docImages = await firestore
                  .collection('administration_images')
                  .where('document_id', isEqualTo: doc.id)
                  .get();

              for (final docImage in docImages.docs) {
                transaction.delete(docImage.reference);
              }
            }

            transaction.delete(doc.reference);
          }
        }

        // delete user documents in firebase storage if folder exist
        try {
          // check if folder exist
          final folder = await storage.ref('documents/$userId').listAll();
          if (folder.items.isNotEmpty) {
            await storage.ref('documents/$userId').delete();
          }
        } catch (_) {}

        // delete user data
        transaction.delete(userDoc.reference);
      },
    );
  }

  @override
  Future<UserDataModel> logIn(LogInParameter parameter) async {
    late UserDataModel userData;

    // First, get the user document by phone number only
    final userQuery = await firestore
        .collection('users')
        .where('phone_number', isEqualTo: parameter.phoneNumber)
        .get();

    if (userQuery.docs.isEmpty) {
      throw CustomException('Pengguna tidak ditemukan');
    }

    // Get the stored salt and hashed PIN
    final userDoc = userQuery.docs.first;
    userData = UserDataModel.fromJson(userDoc.data());
    final storedSalt = userDoc.data()['pin_salt'] as String;
    final storedHashedPin = userDoc.data()['pin'] as String;

    // Verify the PIN
    if (!PinHasher.verifyPin(parameter.pin, storedHashedPin, storedSalt)) {
      throw CustomException('PIN tidak valid');
    }

    return userData;
  }

  @override
  Future<void> logOut() async {
    // await firebaseAuth.signOut();
  }

  @override
  Future<UserDataModel> signUp(SignUpParameter parameter) async {
    // check if phone number already exist
    final userExist = await firestore
        .collection('users')
        .where('phone_number', isEqualTo: parameter.phoneNumber)
        .get();

    if (userExist.docs.isNotEmpty) {
      throw CustomException('Nomor handphone telah terdaftar');
    }

    // generate a unique salt for this user
    final salt = PinHasher.generateSalt();

    // hash the PIN with the salt
    final hashedPin = PinHasher.hashPin(parameter.pin, salt);

    final userDoc = firestore.collection('users').doc();

    await userDoc.set({
      'id': userDoc.id,
      'full_name': parameter.fullName,
      'phone_number': parameter.phoneNumber,
      'pin': hashedPin,
      'pin_salt': salt,
    });

    // create user data in firestore
    final userData = UserDataModel(
      id: userDoc.id,
      fullName: parameter.fullName,
      phoneNumber: parameter.phoneNumber,
    );
    return userData;
  }

  @override
  Future<UserDataModel> updateProfile(UpdateProfileParameter parameter) async {
    // update user data in firestore
    final userDoc = firestore.collection('users').doc(parameter.userId);

    // user data model
    final doc = await userDoc.get();

    final oldUserData = UserDataModel.fromJson(doc.data()!);

    final newUserData = oldUserData.copyWith(
      fullName: parameter.fullName,
      phoneNumber: parameter.phoneNumber,
      occupation: parameter.occupation,
      address: parameter.address,
      groupName: parameter.groupName,
      instructorName: parameter.instructorName,
    );

    // update user data model
    await userDoc.update(newUserData.toJson());

    return newUserData;
  }

  @override
  Future<void> registerPhoneNumber(RegisterPhoneNumberParameter parameter) async {
    // send OTP to phone number
    await auth.verifyPhoneNumber(
      phoneNumber: parameter.phoneNumber,
      verificationCompleted: parameter.verificationCompleted,
      verificationFailed: parameter.verificationFailed,
      codeSent: parameter.codeSent,
      codeAutoRetrievalTimeout: parameter.codeAutoRetrievalTimeout,
      forceResendingToken: parameter.forceResendingToken,
    );
  }

  @override
  Future<UserDataModel> verifyOtp(VerifyOtpParameter parameter) async {
    try {
      // sign in with phone number and OTP
      final userCredential = await auth.signInWithCredential(parameter.credential);

      if (userCredential.user == null) {
        throw CustomException('Pengguna tidak ditemukan');
      }

      final userId = userCredential.user!.uid;
      final phoneNumber = userCredential.user!.phoneNumber!;

      // if parameter.fullname is null, then user is sign in. else, user is sign up, create new data in firestore
      late UserDataModel userData;
      if (parameter.fullName != null) {
        final userDoc = firestore.collection('users').doc(userId);

        // create user data in firestore
        await userDoc.set({
          'id': userId,
          'full_name': parameter.fullName,
          'phone_number': phoneNumber,
        });

        userData = UserDataModel(
          id: userDoc.id,
          fullName: parameter.fullName!,
          phoneNumber: phoneNumber,
        );
      }
      // user login
      else {
        // if user is not yet registered in firestore, throw error
        // get user data
        final userDoc =
            await firestore.collection('users').where('phone_number', isEqualTo: phoneNumber).get();
        if (userDoc.docs.isEmpty) {
          await auth.signOut();
          throw CustomException('Pengguna tidak ditemukan. Silakan membuat akun');
        }
        userData = UserDataModel.fromJson(userDoc.docs.first.data());
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      throw CustomException(FirebaseAuthExceptionOtpParse.parseExceptionCode(e.code));
    } on CustomException catch (e) {
      throw CustomException(e.message);
    }
  }
  
  @override
  Future<void> deleteAccountOtp(DeleteAccountOtpParameter parameter) async {
    late UserCredential? userCredential;
    try {
      
    
    // sign in with phone number and OTP
    userCredential = await auth.currentUser?.reauthenticateWithCredential(parameter.credential);
    } on FirebaseAuthException catch (e) {
      throw CustomException(FirebaseAuthExceptionOtpParse.parseExceptionCode(e.code));
    }

    if (userCredential == null) {
      throw CustomException('Pengguna tidak ditemukan');
    }

    if (userCredential.user == null) {
      throw CustomException('Pengguna tidak ditemukan');
    }

    final userId = userCredential.user!.uid;

    await firestore.runTransaction(
      (transaction) async {
        // delete user image in storage
        // check if user has image
        final userDoc = await firestore.collection('users').doc(userId).get();

        for (final collection in kCollections) {
          // delete user record data in firestore
          final querySnapshot = await firestore
              .collection(collection)
              .where(
                'user_id',
                isEqualTo: userId,
              )
              .get();

          // if collection is administration_documents, delete the document_image in firestore
          for (final doc in querySnapshot.docs) {
            if (collection == 'administration_documents') {
              final docImages = await firestore
                  .collection('administration_images')
                  .where('document_id', isEqualTo: doc.id)
                  .get();

              for (final docImage in docImages.docs) {
                transaction.delete(docImage.reference);
              }
            }

            transaction.delete(doc.reference);
          }
        }

        // delete user documents in firebase storage if folder exist
        try {
          // check if folder exist
          final folder = await storage.ref('documents/$userId').listAll();
          if (folder.items.isNotEmpty) {
            await storage.ref('documents/$userId').delete();
          }
        } catch (_) {}

        // delete user data
        transaction.delete(userDoc.reference);
      },
    );
  }
}
