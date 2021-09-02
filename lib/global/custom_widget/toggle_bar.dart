/*
 * @author paiman <paiman@ide2sen.com>
 *
 */

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ruangkeluarga/global/global.dart';

class ToggleBar extends StatefulWidget {
  final TextStyle labelTextStyle;
  final Color backgroundColor;

  // final BoxBorder backgroundBorder;
  final Color selectedTabColor;
  final Color selectedTextColor;
  final Color textColor;
  final List<String> labels;
  final Function(int) onSelectionUpdated;
  final int initialValue;
  final double paddingSize;

  ToggleBar({
    required this.labels,
    this.backgroundColor = cOrtuGrey,
    // this.backgroundBorder,
    this.selectedTabColor = cPrimaryBg,
    this.selectedTextColor = Colors.white,
    this.textColor = cPrimaryBg,
    this.initialValue = 0,
    this.paddingSize = 10,
    this.labelTextStyle = const TextStyle(),
    required this.onSelectionUpdated,
  });

  @override
  State<StatefulWidget> createState() {
    return _ToggleBarState();
  }
}

class _ToggleBarState extends State<ToggleBar> {
  LinkedHashMap<String, bool> _hashMap = LinkedHashMap();
  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = widget.initialValue;
    _hashMap = LinkedHashMap.fromIterable(widget.labels, value: (value) => value = false);
    _hashMap[widget.labels[_selectedIndex]] = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final labelCount = widget.labels.length;
    return Container(
      margin: EdgeInsets.only(top: widget.paddingSize, bottom: widget.paddingSize),
      width: ((MediaQuery.of(context).size.width) - (widget.paddingSize * labelCount)),
      height: 40,
      decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: labelCount,
        scrollDirection: Axis.horizontal,
        itemExtent: ((MediaQuery.of(context).size.width) - (widget.paddingSize * labelCount)) / (labelCount),
        itemBuilder: (context, index) {
          return GestureDetector(
              child: Container(
                margin: EdgeInsets.all(2.5),
                // width: ((MediaQuery.of(context).size.width) - (widget.paddingSize * labelCount)) / (labelCount),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(_hashMap.keys.elementAt(index),
                      textAlign: TextAlign.center,
                      style: widget.labelTextStyle.apply(color: _hashMap.values.elementAt(index) ? widget.selectedTextColor : widget.textColor)),
                ),
                decoration:
                    BoxDecoration(color: _hashMap.values.elementAt(index) ? widget.selectedTabColor : null, borderRadius: BorderRadius.circular(50)),
              ),
              onHorizontalDragUpdate: (dragUpdate) async {
                int calculatedIndex =
                    ((labelCount * (dragUpdate.globalPosition.dx / (MediaQuery.of(context).size.width - 32))).round() - 1).clamp(0, labelCount - 1);

                if (calculatedIndex != _selectedIndex) {
                  _updateSelection(calculatedIndex);
                }
              },
              onTap: () async {
                if (index != _selectedIndex) {
                  _updateSelection(index);
                }
              });
        },
      ),
    );
  }

  _updateSelection(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onSelectionUpdated(_selectedIndex);
      _hashMap.updateAll((label, selected) => selected = false);
      _hashMap[_hashMap.keys.elementAt(index)] = true;
    });
  }
}
