import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/data/models/comment.dart';
import 'package:user_app/data/repositories/comment_repository.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/main.dart'; // To access getIt

class CommentDialog extends StatefulWidget {
  final String reelId;

  const CommentDialog({Key? key, required this.reelId}) : super(key: key);

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = getIt<CommentRepository>();
      final comments = await repository.fetchComments(widget.reelId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Save the text to use it after clearing the controller
    final commentText = text;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Optimistically add to UI if we don't refetch
    final tempComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: commentText,
      userId: 'You', // Since we don't have user info easily accessible here, 'You' is a placeholder
      reelId: widget.reelId,
      timestamp: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, tempComment);
    });

    // Call provider to handle the comment count and generic reel repository logic
    final reelProvider = Provider.of<ReelProvider>(context, listen: false);
    await reelProvider.addComment(widget.reelId, commentText);

    // Optionally re-fetch to get real IDs and full correct list
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To fit bottom sheet height properly
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                : _errorMessage != null
                    ? Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Error: $_errorMessage')))
                    : _comments.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No comments yet.')))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    comment.userId.isNotEmpty ? comment.userId.substring(0, 1).toUpperCase() : 'U',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ),
                                title: Text(
                                  comment.userId,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(comment.text),
                                ),
                                trailing: Text(
                                  '${comment.timestamp.hour}:${comment.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              );
                            },
                          ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Account for keyboard
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _submitComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
