import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../providers/event.dart';
import 'popup_categories.dart';

class CategoriesWidget extends StatefulWidget {
  Event curEvent;
  Map<String, dynamic> redactedEvent;
  CategoriesWidget(this.curEvent, this.redactedEvent);

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  Future<void> func() async {
    FocusScope.of(context).unfocus();
    dynamic newCategories = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PopUpDialog(
          // screen: 2,
          oldCategories: widget.curEvent.categories,
        ).build(context),
      ),
    ) as Map<String, dynamic>;
    // print('CATEGORIESSSSS ${newCategories}');
    setState(() {
      widget.redactedEvent['categories'] = newCategories;
      widget.curEvent.categories = newCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    String showCorCat(Map<String, dynamic> cat) {
      String res = '';
      for (String curCat in cat.keys) {
        if (cat[curCat] == true) {
          res += curCat + ', ';
        }
      }
      if (res.isEmpty) {
        res = 'Категории не выбраны';
      } else {
        res = res.substring(0, res.length - 2);
      }
      return res;
    }

    return Container(
      width: double.infinity,
      child: TextButton(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.curEvent.categories == '' ||
                    widget.curEvent.categories == null
                ? 'Категории'
                : showCorCat(widget.curEvent.categories),
            style:
                TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: func,
      ),
    );
  }
}
