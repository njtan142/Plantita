import 'package:file_picker/file_picker.dart';
import '../../models/user_model.dart';
import '../../models/upload_model.dart';

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

class UploadItem {
  final PlatformFile file;
  final UserModel? user;
  UploadStatus status;
  double progress;
  UploadResult? result;
  String? errorMessage;

  UploadItem({
    required this.file,
    this.user,
    required this.status,
    required this.progress,
    this.result,
    this.errorMessage,
  });
}
