import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../../utils/responsive_config.dart';

class FilePickerCard extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final ResponsiveConfig responsive;

  const FilePickerCard({
    super.key,
    required this.file,
    required this.onRemove,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (file.bytes != null && _isImageFile(file.extension))
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                file.bytes!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFileIcon(context);
                },
              ),
            )
          else
            _buildFileIcon(context),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha((255 * 0.7).round()),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatFileSize(file.size),
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white.withAlpha((255 * 0.8).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 8.w,
            right: 8.h,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.5).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(file.extension),
            size: 48.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 8.h),
          Text(
            file.extension?.toUpperCase() ?? 'FILE',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String? extension) {
    if (extension == null) return false;
    final ext = extension.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;

    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
