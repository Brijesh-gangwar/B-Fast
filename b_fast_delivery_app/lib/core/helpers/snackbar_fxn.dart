import 'package:flutter/material.dart';


void showCustomMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  late final OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 80, 
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _MessageCard(
          message: message,
          onClose: () => overlayEntry.remove(),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);


  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) overlayEntry.remove();
  });
}


class _MessageCard extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const _MessageCard({required this.message, required this.onClose});

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, color: Colors.black87, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
