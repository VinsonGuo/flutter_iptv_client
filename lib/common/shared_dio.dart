import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final sharedDio = Dio()/*..interceptors.add(PrettyDioLogger())*/;

extension ResponseEx on Response<dynamic> {
  bool get isSuccess => statusCode == null ? false : (statusCode! >= 200 && statusCode! <= 300);
}