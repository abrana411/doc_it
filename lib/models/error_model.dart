class ErrorModel {
  final String? error;
  final dynamic
      data; //since in case of error the error can be anything so dynamic type is best for this

  ErrorModel({required this.error, required this.data});
}
