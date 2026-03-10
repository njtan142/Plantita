import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/reel_provider.dart';

class CommentBottomSheet extends StatefulWidget {
  final String reelId;

  const CommentBottomSheet({Key? key, required this.reelId}) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ReelProvider>(context, listen: false).addComment(widget.reelId, text);
      _controller.clear();
      // Optionally close the bottom sheet after submitting:
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add padding to handle the keyboard safely
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // We could optionally list comments here if we fetch them.
            // For now, focusing on the input requirement.
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Comment input field',
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Send comment',
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: _submitComment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
