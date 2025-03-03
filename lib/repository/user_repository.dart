import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/user_provider.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class UserRepository {
  final UserProvider _userProvider = UserProvider();
  final UserSessionRepository _userSessionRepository = UserSessionRepository();

  Future<void> fetchAndUpdateUserDetails() async {
    try {
      // Fetch the current UserSession
      final userSession = await _userSessionRepository.getUserSession();

      // Fetch user_id from the UserSession
      final int userId = userSession.user.userId;

      // Fetch user details from the backend
      final User userDetails = await _userProvider.getUserDetails(userId);

      // Update the UserSession with new user details
      final updatedUser = userSession.user.copyWith(
        username: userDetails.username,
        roleId: userDetails.roleId,
        passwordHash: userDetails.passwordHash,
        active: userDetails.active,
      );

      final updatedUserSession = userSession.copyWith(user: updatedUser);

      // Save the updated UserSession
      await _userSessionRepository.saveUserSession(updatedUserSession);

      print('User details updated. Role ID: ${updatedUserSession.user.roleId}');
    } catch (e) {
      print('Error updating user details: $e');
      rethrow;
    }
  }

  // Asynchronous method to get the role as a string based on roleId
  Future<String> getRole() async {
    try {
      // Fetch the current UserSession
      final userSession = await _userSessionRepository.getUserSession();

      // Get roleId from the user session
      final int roleId = userSession.user.roleId;

      // Map roleId to the corresponding role name
      switch (roleId) {
        case 1:
          return 'Admin';
        case 2:
          return 'Owner';
        case 3:
          return 'Worker';
        default:
          return 'Unknown Role';
      }
    } catch (e) {
      print('Error fetching role: $e');
      return 'Error';
    }
  }

  Future<String> getName() async {
    final userSession = await _userSessionRepository.getUserSession();
    return userSession
        .user.username; // Replace with your actual field if needed
  }
}
