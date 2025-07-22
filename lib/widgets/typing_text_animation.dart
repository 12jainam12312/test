import 'package:flutter/material.dart';

class TypingTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final VoidCallback? onComplete;

  const TypingTextAnimation({
    Key? key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 50),
    this.onComplete,
  }) : super(key: key);

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
      vsync: this,
    );

    _characterCount = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _characterCount.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _displayText,
                style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
              ),
              if (_characterCount.value < widget.text.length)
                TextSpan(
                  text: '|',
                  style: (widget.style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}