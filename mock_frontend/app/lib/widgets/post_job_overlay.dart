import 'package:flutter/material.dart';
import '../widgets/post_job_modal.dart';

class PostJobOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const PostJobOverlay({
    super.key,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: PostJobModal(onClose: onClose, onSubmit: onSubmit),
        ),
      ),
    );
  }
}
