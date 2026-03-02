import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkableTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;

  const LinkableTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.clip,
    this.maxLines,
  });

  Future<void> _onOpen(LinkableElement link) async {
    final uri = Uri.parse(link.url);
    if (!await launchUrl(uri)) {
      debugPrint('Não foi possível abrir: \${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectableLinkify(
      onOpen: _onOpen,
      text: text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      linkStyle: textStyle?.copyWith(
        color: Colors.blueAccent,
        decoration: TextDecoration.underline,
      ),
      options: const LinkifyOptions(humanize: false),
    );
  }
}
