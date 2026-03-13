import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_config.dart';
import '../common/custom_button.dart';
import 'components/file_picker_header.dart';
import 'components/file_picker_empty_state.dart';
import 'components/file_picker_card.dart';

class FilePickerInterface extends StatefulWidget {
  final UserModel? selectedUser;
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

    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }

    if (files.length > remainingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only added $remainingSlots files. Maximum ${widget.maxFiles} files allowed.',
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

    if (widget.onFilesSelected != null) {
      widget.onFilesSelected!(_selectedFiles);
    }
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });

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
          FilePickerHeader(
            selectedUser: widget.selectedUser,
            selectedFilesCount: _selectedFiles.length,
            maxFiles: widget.maxFiles,
            responsive: responsive,
          ),

          Expanded(
            child: _selectedFiles.isEmpty
                ? FilePickerEmptyState(
                    isDragOver: _isDragOver,
                    dragAnimation: _dragAnimation,
                    responsive: responsive,
                    onPickFiles: _pickFiles,
                    onPickFromGallery: _pickFromGallery,
                    onFilesDropped: (files) => _addFiles(files),
                  )
                : _buildFileGrid(responsive),
          ),

          _buildBottomControls(responsive),
        ],
      ),
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
                child: FilePickerCard(
                  file: _selectedFiles[index],
                  onRemove: () => _removeFile(index),
                  responsive: responsive,
                ),
              ),
            ),
          );
        },
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
}
