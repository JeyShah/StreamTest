import 'package:get_it/get_it.dart';
import 'services/video_api.dart';
import 'services/video_api_http.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<VideoApi>(
    () => VideoApiHttp(baseUrl: 'https://apistg.gpsina.com/api'),
  );
}