import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_models.dart'; // Corrected import path
import '../../../services/api_service.dart'; // Adjusted relative path

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.userName,
  });

  final Message message;
  final bool isMe;
  final String userName;

  Widget _buildAttachment(BuildContext context) {
    if (message.attachmentUrl == null) {
      return const SizedBox.shrink();
    }

    final fullUrl = ApiService.baseUrl + message.attachmentUrl!;

    switch (message.attachmentType) {
      case 'image':
        return GestureDetector(
          onTap: () {
            // TODO: Implement image preview
            print('Tapped on image: $fullUrl');
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          ),
        );
      case 'video':
        return GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl));
            } else {
              // TODO: Handle error or show a snackbar
              print('Could not launch $fullUrl');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, size: 24.0),
                const SizedBox(width: 8.0),
                Text('Video: ${Uri.parse(message.attachmentUrl!).pathSegments.last}'),
              ],
            ),
          ),
        );
      case 'audio':
        return GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl));
            } else {
              print('Could not launch $fullUrl');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.audiotrack, size: 24.0),
                const SizedBox(width: 8.0),
                Text('Audio: ${Uri.parse(message.attachmentUrl!).pathSegments.last}'),
              ],
            ),
          ),
        );
      case 'pdf':
        return GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl));
            } else {
              print('Could not launch $fullUrl');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, size: 24.0),
                const SizedBox(width: 8.0),
                Text('PDF: ${Uri.parse(message.attachmentUrl!).pathSegments.last}'),
              ],
            ),
          ),
        );
      case 'file':
      default:
        return GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(fullUrl))) {
              await launchUrl(Uri.parse(fullUrl));
            } else {
              print('Could not launch $fullUrl');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insert_drive_file, size: 24.0),
                const SizedBox(width: 8.0),
                Text('File: ${Uri.parse(message.attachmentUrl!).pathSegments.last}'),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  userName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            if (message.content != null && message.content!.isNotEmpty) Text(message.content!),
            if (message.attachmentUrl != null) _buildAttachment(context),
            Text(
              '${message.createdAt.hour}:${message.createdAt.minute}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}