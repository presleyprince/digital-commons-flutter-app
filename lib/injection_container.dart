import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/data/datasources/abstract/auth/auth_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/auth/auth_remote_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_remote_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_remote_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_remote_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/weather/weather_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/weather/weather_remote_data_source.dart';
import 'package:digital_shores/app/data/datasources/firebase/administration_remote_data_source_firebase.dart';
import 'package:digital_shores/app/data/datasources/firebase/auth_remote_data_source_firebase.dart';
import 'package:digital_shores/app/data/datasources/firebase/finance_remote_data_source_firebase.dart';
import 'package:digital_shores/app/data/datasources/firebase/information_remote_data_source_firebase.dart';
import 'package:digital_shores/app/data/datasources/local_impl/administration_local_data_source_impl.dart';
import 'package:digital_shores/app/data/datasources/local_impl/auth_local_data_source_impl.dart';
import 'package:digital_shores/app/data/datasources/local_impl/finance_local_data_source_impl.dart';
import 'package:digital_shores/app/data/datasources/local_impl/information_local_data_source_impl.dart';
import 'package:digital_shores/app/data/datasources/local_impl/weather_local_data_source_impl.dart';
import 'package:digital_shores/app/data/datasources/remote_impl/weather_remote_data_source_impl.dart';
import 'package:digital_shores/app/data/repositories/administration_repository_impl.dart';
import 'package:digital_shores/app/data/repositories/auth_repository_impl.dart';
import 'package:digital_shores/app/data/repositories/finance_repository_impl.dart';
import 'package:digital_shores/app/data/repositories/information_repository_impl.dart';
import 'package:digital_shores/app/data/repositories/weather_repository_impl.dart';
import 'package:digital_shores/app/domain/repositories/administration_repository.dart';
import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/app/domain/repositories/finance_repository.dart';
import 'package:digital_shores/app/domain/repositories/information_repository.dart';
import 'package:digital_shores/app/domain/repositories/weather_repository.dart';
import 'package:digital_shores/app/presentation/provider/add_information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/delete_account_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/onboarding_notifier.dart';
import 'package:digital_shores/app/presentation/provider/otp_notifier.dart';
import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;
Future<void> init() async {
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AdministrationRepository>(
    () => AdministrationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<InformationRepository>(
    () => InformationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceFirebase(
      firestore: sl(),
      storage: sl(),
      auth: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceFirebase(
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<FinanceLocalDataSource>(
    () => FinanceLocalDataSourceImpl(
      databaseHelper: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<AdministrationRemoteDataSource>(
    () => AdministrationRemoteDataSourceFirebase(
      firestore: sl(),
      firebaseStorage: sl(),
    ),
  );
  sl.registerLazySingleton<AdministrationLocalDataSource>(
    () => AdministrationLocalDataSourceImpl(
      databaseHelper: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<InformationRemoteDataSource>(
    () => InformationRemoteDataSourceFirebase(
      firestore: sl(),
      firebaseStorage: sl(),
    ),
  );
  sl.registerLazySingleton<InformationLocalDataSource>(
    () => InformationLocalDataSourceImpl(
      databaseHelper: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(
      client: sl(),
    ),
  );
  sl.registerLazySingleton<WeatherLocalDataSource>(
    () => WeatherLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Provider
  // sl.enableRegisteringMultipleInstancesOfOneType();
  sl.registerFactory(() => OnboardingNotifier());
  sl.registerFactory(() => AuthNotifier(repository: sl()));
  sl.registerFactory(() => OtpNotifier(repository: sl()));
  sl.registerFactory(() => DeleteAccountNotifier(repository: sl()));
  // sl.registerFactory(() => LoginNotifier(repository: sl()));
  // sl.registerFactory(() => SignupNotifier(repository: sl()));
  sl.registerFactory(() => FinanceNotifier(repository: sl()));
  sl.registerFactory(() => FinanceHistoryNotifier(repository: sl()));
  sl.registerFactory(() => AdministrationNotifier(repository: sl()));
  sl.registerFactory(() => InformationNotifier(repository: sl()));
  sl.registerFactory(() => AddInformationNotifier(repository: sl()));
  sl.registerFactory(() => WeatherNotifier(repository: sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
