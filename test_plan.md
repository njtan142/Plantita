1. **Create `CommentDialog` widget**:
   - Create a new file `user_app/lib/ui/widgets/comment_dialog.dart`.
   - The widget should display a bottom sheet or a dialog. Since it's for reels (short-form videos), a bottom sheet is typically better suited for comments.
   - It needs to show a list of existing comments. It will need to fetch these via `CommentRepository`.
   - It needs to have a text input field at the bottom to add a new comment, using `ReelProvider.addComment` to add a comment (which also calls the repository and updates the local count). Alternatively, we can use `CommentRepository` directly to add the comment to the backend and append to the local list, then notify `ReelProvider` to update the count. Actually, `ReelProvider.addComment(reelId, commentText)` will update the count and make the API call via `ReelRepository.addComment`, but we probably also want to see the new comment in the dialog immediately. Let's look at `ReelProvider`.

2. **Implement the logic to load comments**:
   - `CommentDialog` should be a `StatefulWidget`.
   - On `initState`, fetch comments via `getIt<CommentRepository>().fetchComments(reelId)`.
   - Display a loading indicator while fetching, an error message if it fails, or a `ListView.builder` if successful.

3. **Implement the logic to add comments**:
   - Add a `TextField` and a send button.
   - On send, call `Provider.of<ReelProvider>(context, listen: false).addComment(reelId, text)`. This handles the API call and updating the count on the Reel.
   - We also need to add the comment to the local list of the dialog so it shows up immediately, or refetch comments. Actually, `ReelProvider.addComment` does not return the created comment, it just returns void and updates the reel count. So we might need to construct a local `Comment` object to prepend to the list, or call `CommentRepository.addComment` which does the same. Let's just construct a dummy `Comment` to show locally, or refetch. Or just use `ReelProvider.addComment(reelId, commentText)` and also construct a local `Comment` object (since we don't get the created ID back from the provider). Wait, `Comment` requires an ID. We can use `const Uuid().v4()` or similar if available, or a generic ID. Or wait for a refetch. Refetching might be simpler and safer.

4. **Integrate into `ReelsView`**:
   - In `user_app/lib/ui/screens/reels_view.dart`, replace the `// TODO: Implement comment dialog` with:
     ```dart
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => CommentDialog(reelId: reel.id),
     );
     ```

Let's refine the `CommentDialog`.
