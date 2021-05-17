import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'line_chart/line_chart_page2.dart';

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  int _currentPage = 0;

  final _controller = PageController(initialPage: 0);
  final _duration = Duration(milliseconds: 300);
  final _curve = Curves.easeInOutCubic;
  final _pages = [
    LineChartPage2(),
  ];

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: kIsWeb
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          controller: _controller,
          children: _pages,
        ),
      ),
      bottomNavigationBar: kIsWeb
          ? Container(
              padding: EdgeInsets.all(16),
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Visibility(
                    visible: _currentPage != 0,
                    child: FloatingActionButton(
                      onPressed: () => _controller.previousPage(
                          duration: _duration, curve: _curve),
                      child: Icon(Icons.chevron_left_rounded),
                    ),
                  ),
                  Spacer(),
                  Visibility(
                    visible: _currentPage != _pages.length - 1,
                    child: FloatingActionButton(
                      onPressed: () => _controller.nextPage(
                          duration: _duration, curve: _curve),
                      child: Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
