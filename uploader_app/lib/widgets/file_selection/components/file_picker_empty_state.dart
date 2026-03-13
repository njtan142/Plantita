import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../../utils/responsive_config.dart';
import '../../common/custom_button.dart';

class FilePickerEmptyState extends StatelessWidget {
  final bool isDragOver;
  final Animation<double> dragAnimation;
  final ResponsiveConfig responsive;
  final VoidCallback onPickFiles;
  final VoidCallback onPickFromGallery;
  final Function(List<PlatformFile>) onFilesDropped;

  const FilePickerEmptyState({
    super.key,
    required this.isDragOver,
    required this.dragAnimation,
    required this.responsive,
    required this.onPickFiles,
    required this.onPickFromGallery,
    required this.onFilesDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlatformFile>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onFilesDropped([details.data]),
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: dragAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isDragOver ? dragAnimation.value : 1.0,
              child: Container(
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDragOver
                      ? Theme.of(context).colorScheme.primaryContainer.withAlpha(76)
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isDragOver
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: isDragOver ? 3 : 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDragOver ? Icons.file_upload : Icons.cloud_upload,
                        size: responsive.iconSize * 2,
                        color: isDragOver
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        isDragOver
                            ? 'Drop files here'
                            : 'Drag and drop files here\nor use the buttons below',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.bodyFontSize,
                          color: isDragOver
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            onPressed: onPickFiles,
                            text: 'Browse Files',
                            leadingIcon: const Icon(Icons.folder_open),
                            minimumSize: Size(140.w, 48.h),
                          ),
                          SizedBox(width: 16.w),
                          CustomButton(
                            onPressed: onPickFromGallery,
                            text: 'From Gallery',
                            leadingIcon: const Icon(Icons.photo_library),
                            minimumSize: Size(140.w, 48.h),
                            isOutlined: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
