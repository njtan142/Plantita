import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../utils/responsive_config.dart';
import 'components/user_suggestion_item.dart';
import 'components/selected_user_card.dart';

class UserSearchDropdown extends StatefulWidget {
  final UserModel? selectedUser;
  final Function(UserModel?)? onUserSelected;
  final String? hintText;
  final String? labelText;
  final bool enabled;

  const UserSearchDropdown({
    super.key,
    this.selectedUser,
    this.onUserSelected,
    this.hintText,
    this.labelText,
    this.enabled = true,
  });

  @override
  State<UserSearchDropdown> createState() => _UserSearchDropdownState();
}

class _UserSearchDropdownState extends State<UserSearchDropdown> {
  final TextEditingController _controller = TextEditingController();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.selectedUser;
    if (_currentUser != null) {
      _controller.text = _currentUser!.displayName;
    }
  }

  @override
  void didUpdateWidget(UserSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUser != oldWidget.selectedUser) {
      _currentUser = widget.selectedUser;
      if (_currentUser != null) {
        _controller.text = _currentUser!.displayName;
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _getUserSuggestions(String pattern) async {
    if (pattern.isEmpty) return [];

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final response = await userService.searchUsers(pattern);

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
    }

    return [];
  }

  void _onUserSelected(UserModel user) {
    setState(() {
      _currentUser = user;
      _controller.text = user.displayName;
    });

    if (widget.onUserSelected != null) {
      widget.onUserSelected!(user);
    }
  }

  void _clearSelection() {
    setState(() {
      _currentUser = null;
      _controller.clear();
    });

    if (widget.onUserSelected != null) {
      widget.onUserSelected!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

        TypeAheadFormField<UserModel>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search for a user...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withAlpha((255 * 0.6).round()),
                fontSize: responsive.bodyFontSize,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _currentUser != null
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _clearSelection,
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.5).round()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withAlpha((255 * 0.5).round()),
                  width: 1,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
          suggestionsCallback: _getUserSuggestions,
          itemBuilder: (context, user) => UserSuggestionItem(
            user: user,
            responsive: responsive,
          ),
          onSuggestionSelected: _onUserSelected,
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            elevation: 4,
            color: theme.colorScheme.surface,
            shadowColor: Colors.black.withAlpha((255 * 0.1).round()),
            constraints: BoxConstraints(
              maxHeight: 300.h,
            ),
          ),
          noItemsFoundBuilder: (context) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'No users found',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: responsive.bodyFontSize,
              ),
            ),
          ),
          loadingBuilder: (context) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Searching...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: responsive.bodyFontSize,
                  ),
                ),
              ],
            ),
          ),
          errorBuilder: (context, error) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Error searching users: ${error.toString()}',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: responsive.bodyFontSize,
              ),
            ),
          ),
          animationDuration: const Duration(milliseconds: 300),
          debounceDuration: const Duration(milliseconds: 300),
          hideOnLoading: false,
          hideOnEmpty: false,
          hideOnError: false,
          keepSuggestionsOnLoading: false,
        ),

        if (_currentUser != null) 
          SelectedUserCard(
            user: _currentUser!,
            responsive: responsive,
          ),
      ],
    );
  }
}
