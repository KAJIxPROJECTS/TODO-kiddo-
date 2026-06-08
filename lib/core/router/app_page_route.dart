import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Animatable<double> _pageFadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
  CurveTween(curve: Curves.easeInOut),
);
final Animatable<Offset> _pageSlideTween = Tween<Offset>(
  begin: const Offset(0.0, 0.1),
  end: Offset.zero,
).chain(
  CurveTween(curve: Curves.easeInOut),
);

class AppPageRoute<T> extends CustomTransitionPage<T> {
  AppPageRoute({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(_pageFadeTween),
              child: SlideTransition(
                position: animation.drive(_pageSlideTween),
                child: child,
              ),
            );
          },
        );
}

class AppRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget child;

  AppRouteBuilder({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(_pageFadeTween),
              child: SlideTransition(
                position: animation.drive(_pageSlideTween),
                child: child,
              ),
            );
          },
        );
}
