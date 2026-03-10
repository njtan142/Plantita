#!/bin/bash
sed -i -e '/class UserService {/i \
class _CachedSearchUser {\
  final UserModel user;\
  final String usernameLower;\
  final String firstNameLower;\
  final String lastNameLower;\
  final String emailLower;\
\
  _CachedSearchUser(this.user)\
      : usernameLower = user.username.toLowerCase(),\
        firstNameLower = user.firstName.toLowerCase(),\
        lastNameLower = user.lastName.toLowerCase(),\
        emailLower = user.email.toLowerCase();\
}\
' uploader_app/lib/services/user_service.dart
