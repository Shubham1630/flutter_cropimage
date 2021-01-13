import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'edge_painter.dart';
import 'magnifier.dart';
import 'touch_bubble.dart';

class EdgeDetectionShape extends StatefulWidget {
  EdgeDetectionShape({
    @required this.renderedImageSize,
    @required this.originalImageSize,

  });

  final Size renderedImageSize;
  final Size originalImageSize;


  @override
  _EdgeDetectionShapeState createState() => _EdgeDetectionShapeState();
}

class _EdgeDetectionShapeState extends State<EdgeDetectionShape> {
  double edgeDraggerSize;

  Offset topLeft = ui.Offset(0,0);
  Offset topRight =  ui.Offset(0,0) ;
  Offset bottomLeft =  ui.Offset(0,0);
  Offset bottomRight =  ui.Offset(0,0);

  List<Offset> points;

  double renderedImageWidth;
  double renderedImageHeight;
  double top;
  double left;

  Offset currentDragPosition;

  @override
  void didChangeDependencies() {
    double shortestSide = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    edgeDraggerSize = shortestSide / 12;
    super.didChangeDependencies();
  }

  @override
  void initState() {

    _calculateDimensionValues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Magnifier(
        visible: currentDragPosition != null,
        position: currentDragPosition,
        child: Stack(
          children: [
            _getTouchBubbles(),
            CustomPaint(
                painter: EdgePainter(
                    points: points,
                    color: Theme.of(context).accentColor.withOpacity(0.5)
                )
            )
          ],
        )
    );
  }

  void _calculateDimensionValues() {
    top = 0.0;
    left = 0.0;

    double widthFactor = widget.renderedImageSize.width / widget.originalImageSize.width;
    double heightFactor = widget.renderedImageSize.height / widget.originalImageSize.height;
    double sizeFactor = min(widthFactor, heightFactor);

    renderedImageHeight = widget.originalImageSize.height * sizeFactor;
    top = ((widget.renderedImageSize.height - renderedImageHeight) / 2);

    renderedImageWidth = widget.originalImageSize.width * sizeFactor;
    left = ((widget.renderedImageSize.width - renderedImageWidth) / 2);
  }

  Offset _getNewPositionAfterDrag(Offset position, double renderedImageWidth, double renderedImageHeight) {
    return Offset(
        position.dx / renderedImageWidth,
        position.dy / renderedImageHeight
    );
  }

  Offset _clampOffset(Offset givenOffset) {
    double absoluteX = givenOffset.dx * renderedImageWidth;
    double absoluteY = givenOffset.dy * renderedImageHeight;

    return Offset(
        absoluteX.clamp(0.0, renderedImageWidth) / renderedImageWidth,
        absoluteY.clamp(0.0, renderedImageHeight) / renderedImageHeight
    );
  }

  Widget _getTouchBubbles() {
    points = [
      Offset(
          left + topLeft.dx * renderedImageWidth,
          top + topRight.dy * renderedImageHeight
      ),
      Offset(
          left + topRight.dx * renderedImageWidth,
          top + topRight.dy * renderedImageHeight
      ),
      Offset(
          left + bottomRight.dx * renderedImageWidth,
          top + (bottomRight.dy * renderedImageHeight)
      ),
      Offset(
          left + bottomLeft.dx * renderedImageWidth,
          top + bottomLeft.dy * renderedImageHeight
      ),
      Offset(
          left + topLeft.dx * renderedImageWidth,
          top + topRight.dy * renderedImageHeight
      ),

    ];

    final Function onDragFinished = () {
      currentDragPosition = null;
      setState(() {});
    };

    return Container(
      width: widget.renderedImageSize.width,
      height: widget.renderedImageSize.height,
      child: Stack(
        children: [
          Positioned(
              child: TouchBubble(
                  size: edgeDraggerSize,
                  onDrag: (position) {
                    setState(() {
                      currentDragPosition = Offset(points[0].dx, points[0].dy);
                      Offset newTopLeft = _getNewPositionAfterDrag(
                          position, renderedImageWidth, renderedImageHeight
                      );
                      topLeft = _clampOffset(
                          topLeft + newTopLeft
                      );
                    });
                  },
                  onDragFinished: onDragFinished
              ),
              left: points[0].dx - (edgeDraggerSize / 2),
              top: points[0].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
              child: TouchBubble(
                  size: edgeDraggerSize,
                  onDrag: (position) {
                    setState(() {
                      Offset newTopRight = _getNewPositionAfterDrag(
                          position, renderedImageWidth, renderedImageHeight
                      );
                      topRight = _clampOffset(
                          topRight + newTopRight
                      );
                      currentDragPosition = Offset(points[1].dx, points[1].dy);
                    });
                  },
                  onDragFinished: onDragFinished
              ),
              left: points[1].dx - (edgeDraggerSize / 2),
              top: points[1].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
              child: TouchBubble(
                  size: edgeDraggerSize,
                  onDrag: (position) {
                    setState(() {
                      Offset newBottomRight = _getNewPositionAfterDrag(
                          position, renderedImageWidth, renderedImageHeight
                      );
                      bottomRight = _clampOffset(
                          bottomRight + newBottomRight
                      );
                      currentDragPosition = Offset(points[2].dx, points[2].dy);
                    });
                  },
                  onDragFinished: onDragFinished
              ),
              left: points[2].dx - (edgeDraggerSize / 2),
              top: points[2].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
              child: TouchBubble(
                  size: edgeDraggerSize,
                  onDrag: (position) {
                    setState(() {
                      Offset newBottomLeft = _getNewPositionAfterDrag(
                          position, renderedImageWidth, renderedImageHeight
                      );
                      bottomLeft = _clampOffset(
                          bottomLeft + newBottomLeft
                      );
                      currentDragPosition = Offset(points[3].dx, points[3].dy);
                    });
                  },
                  onDragFinished: onDragFinished
              ),
              left: points[3].dx - (edgeDraggerSize / 2),
              top: points[3].dy - (edgeDraggerSize / 2)
          ),
        ],
      ),
    );
  }
}