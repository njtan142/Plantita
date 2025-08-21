import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/file_selection_service.dart';
import '../../utils/responsive_config.dart';
import '../common/custom_button.dart';

class FilePickerInterface extends StatefulWidget {
  final User? selectedUser;
  final Function(List<PlatformFile> files)? onFilesSelected;
  final int maxFiles;
  final List<String> allowedExtensions;

  const FilePickerInterface({
    super.key,
    this.selectedUser,
    this.onFilesSelected,
    this.maxFiles = 10,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
  });

  @override
  State<FilePickerInterface> createState() => _FilePickerInterfaceState();
}

class _FilePickerInterfaceState extends State<FilePickerInterface>
    with TickerProviderStateMixin {
  final List<PlatformFile> _selectedFiles = [];
  bool _isDragOver = false;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _dragAnimationController;
  late Animation<double> _dragAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _dragAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _dragAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _dragAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _dragAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        _addFiles(result.files);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick files: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final platformFiles = images.map((image) async {
          final bytes = await image.readAsBytes();
          return PlatformFile(
            name: image.name,
            size: bytes.length,
            bytes: bytes,
            path: image.path,
          );
        }).toList();

        final files = await Future.wait(platformFiles);
        _addFiles(files);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick images: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFiles(List<PlatformFile> files) {
    final remainingSlots = widget.maxFiles - _selectedFiles.length;
    final filesToAdd = files.take(remainingSlots);

    setState(() {
      _selectedFiles.addAll(filesToAdd);
    });

    // Notify parent
    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }

    // Show message if some files were skipped
    if (files.length > remainingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only added ${remainingSlots} files. Maximum ${widget.maxFiles} files allowed.',
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    // Notify parent
    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });

    // Notify parent
    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header with user info and file count
          _buildHeader(responsive),

          // File selection area
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildEmptyState(responsive)
                : _buildFileGrid(responsive),
          ),

          // Bottom controls
          _buildBottomControls(responsive),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveConfig responsive) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User info (if available)
          if (widget.selectedUser != null)
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      widget.selectedUser!.displayName.isNotEmpty
                          ? widget.selectedUser!.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedUser!.displayName,
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (widget.selectedUser!.department != null)
                          Text(
                            widget.selectedUser!.department!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // File count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedFiles.length >= widget.maxFiles
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${_selectedFiles.length}/${widget.maxFiles}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: _selectedFiles.length >= widget.maxFiles
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveConfig responsive) {
    return DragTarget<PlatformFile>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragOver = true);
        _dragAnimationController.forward();
        return true;
      },
      onLeave: (data) {
        setState(() => _isDragOver = false);
        _dragAnimationController.reverse();
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _dragAnimationController.reverse();
        _addFiles([details.data]);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: _dragAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isDragOver ? _dragAnimation.value : 1.0,
              child: Container(
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _isDragOver
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: _isDragOver
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: _isDragOver ? 3 : 2,
                    style: _isDragOver ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isDragOver ? Icons.file_upload : Icons.cloud_upload,
                        size: responsive.iconSize * 2,
                        color: _isDragOver
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _isDragOver
                            ? 'Drop files here'
                            : 'Drag and drop files here\nor use the buttons below',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.bodyFontSize,
                          color: _isDragOver
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            onPressed: _pickFiles,
                            text: 'Browse Files',
                            leadingIcon: const Icon(Icons.folder_open),
                            minimumSize: Size(140.w, 48.h),
                          ),
                          SizedBox(width: 16.w),
                          CustomButton(
                            onPressed: _pickFromGallery,
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

  Widget _buildFileGrid(ResponsiveConfig responsive) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.isMobile ? 2 : 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.8,
        ),
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: responsive.isMobile ? 2 : 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildFileCard(_selectedFiles[index], index, responsive),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(PlatformFile file, int index, ResponsiveConfig responsive) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // File preview
          if (file.bytes != null && _isImageFile(file.extension))
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                file.bytes!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFileIcon(file, responsive);
                },
              ),
            )
          else
            _buildFileIcon(file, responsive),

          // File info overlay
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
                    Colors.black.withOpacity(0.7),
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
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 8.w,
            right: 8.h,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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

  Widget _buildFileIcon(PlatformFile file, ResponsiveConfig responsive) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
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

  Widget _buildBottomControls(ResponsiveConfig responsive) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_selectedFiles.isNotEmpty) ...[
            TextButton.icon(
              onPressed: _clearAllFiles,
              icon: Icon(
                Icons.clear_all,
                size: 18.sp,
              ),
              label: Text(
                'Clear All',
                style: TextStyle(fontSize: responsive.bodyFontSize),
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Row(
              children: [
                CustomButton(
                  onPressed: _pickFiles,
                  text: 'Add Files',
                  leadingIcon: const Icon(Icons.add),
                  minimumSize: Size(120.w, 48.h),
                  isOutlined: true,
                ),
                SizedBox(width: 16.w),
                CustomButton(
                  onPressed: _pickFromGallery,
                  text: 'Gallery',
                  leadingIcon: const Icon(Icons.photo_library),
                  minimumSize: Size(120.w, 48.h),
                  isOutlined: true,
                ),
              ],
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