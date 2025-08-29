import 'package:flutter/material.dart';
import '../../models/kanban_model.dart';
import 'kanban_page_widgets.dart';

class KanbanDisplayWidget extends StatefulWidget {
  final KanbanModel kanbanData;
  final int currentPage;
  final Function(int) onPageChanged;

  const KanbanDisplayWidget({
    super.key,
    required this.kanbanData,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  _KanbanDisplayWidgetState createState() => _KanbanDisplayWidgetState();
}

class _KanbanDisplayWidgetState extends State<KanbanDisplayWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageDot(0),
              const SizedBox(width: 10),
              _buildPageDot(1),
            ],
          ),
        ),
        // Pages
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: widget.onPageChanged,
            children: [
              KanbanFirstPage(kanbanData: widget.kanbanData),
              KanbanSecondPage(kanbanData: widget.kanbanData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageDot(int page) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.currentPage == page ? Colors.white : Colors.white38,
      ),
    );
  }
}