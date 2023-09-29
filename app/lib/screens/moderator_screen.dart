import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/events_grid.dart';

class ModeratorScreen extends StatelessWidget {
  const ModeratorScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('We open moderator screen!');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            children: <Widget>[
              Text('Жалобы', style: TextStyle(color: Colors.black)),
              Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.19),
                  child: IconButton(
                    icon: Icon(Icons.exit_to_app, color: Colors.black),
                    onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/');
                        Provider.of<Auth>(context, listen: false).logout();
                    },
                  ),
                ),
            ],
          )),
      body: EventsGrid(null, 4),
    );
  }
}
