import '../providers/profile.dart';
import '../providers/profiles.dart';
import '../widgets/raiting_bar.dart';
import '/providers/event.dart';
import '/screens/creating_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/build_detail_field.dart';
import '../providers/auth.dart';
import '../providers/events.dart';
import 'comments_screen.dart';

class EventDetailScreen extends StatefulWidget {
  static const routeName = '/event-detail';

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isFavorite = false;
  String creatorUsername = 'Организатор';
  String currentUserId;
  Event loadedEvent;
  void setUsername(String profileId) async {
    Profile profile = await Provider.of<Profiles>(
      context,
      listen: false,
    ).findById(profileId);
    setState(() {
      creatorUsername = profile.username;
      haveFinalData = true;
    });
    print("FTTTNNNN $creatorUsername");
  }

  void setUser(String profileId) async {
    await setUsername(profileId);
  }

  void openComments() async {
    print('loadedEvent.comments ${loadedEvent.comments}');
    await Navigator.of(context).pushNamed(
      CommentsScreen.routeName,
      arguments: {loadedEvent.comments, loadedEvent.commentators, loadedEvent},
    );
  }

  bool haveFinalData = false;
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    final eventId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    loadedEvent = Provider.of<Events>(
      context,
      listen: false,
    ).findById(eventId);

    if (!haveFinalData) {
      final profileId = loadedEvent.profileId;
      // currentUserId = profileId;
      // print('currentUserId ${currentUserId}');
      setUser(profileId);
    }

    // loadedEvent.output(loadedEvent);

    bool isEventAvailableToEdit =
        (loadedEvent.creatorId == authData.userId) ? true : false;
    bool haveDelete = false;

    void deleteEvent(Event deleteEvent) async {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          // title: Text('Choose varient!'),
          content: Text(
            'Вы уверены, что хотите удалить мероприятие?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                // color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Нет',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onPressed: () {
                haveDelete = false;
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Container(
                // color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Да',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onPressed: () async {
                await Provider.of<Events>(context, listen: false)
                    .deleteEvent(deleteEvent.id);
                haveDelete = true;
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    void delEvent() async {
      await deleteEvent(loadedEvent);
      if (haveDelete == true) {
        Navigator.of(context).pop();
      }
    }

    // Provider.of<Event>(context, listen: false)
    //     .getOldFavStatus(authData.token, authData.userId, loadedEvent.id);
    void putLike() async {
      await Provider.of<Event>(context, listen: false).toggleFavoriteStatus(
          authData.token,
          authData.userId,
          loadedEvent.id,
          !loadedEvent.isFavorite);
      setState(() {
        loadedEvent.isFavorite = !loadedEvent.isFavorite;
      });
    }

    print('loadedEvent.profileId ${loadedEvent.profileId}');
    // print('currentUserId${currentUserId}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Container(
              height: 20,
              child: Image.asset('assets/images/palm-tree.png',
                  fit: BoxFit.fill, height: 80, width: 25, scale: 0.8),
            ),
            if (isEventAvailableToEdit)
              Row(children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.19),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      func(loadedEvent);
                    },
                  ),
                ),
                Container(
                  // padding: EdgeInsets.only(left: 170),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.black),
                    onPressed: () {
                      delEvent();
                    },
                  ),
                ),
              ])
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 6),
        height: double.infinity,
        width: double.infinity,
        color: Theme.of(context).colorScheme.secondary,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.height * 0.45,
                height: MediaQuery.of(context).size.height * 0.45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Image border
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(48), // Image radius
                    child:
                        Image.network(loadedEvent.imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
              Container(
                child: Text(
                  loadedEvent.name,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              DetailField(
                "Адрес",
                loadedEvent.address.title,
                address: loadedEvent.address,
              ),
              DetailField("Дата и время", loadedEvent.dateTime.toString()),
              DetailField(
                  "Полное описание мероприятия", loadedEvent.description),
              DetailField(
                  "Дополнительная информация", loadedEvent.extraInformation),
              DetailField("Организатор", creatorUsername,
                  idUser: loadedEvent.profileId),
              Container(
                  width: 350,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  margin: EdgeInsets.only(top: 10.0),
                  child: TextButton(
                    onPressed: openComments,
                    child: Text(
                      'Комментарии',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: loadedEvent.isFavorite
            ? Icon(
                Icons.favorite,
                color: Theme.of(context).primaryColor,
              )
            : Icon(
                Icons.favorite_border,
                color: Theme.of(context).primaryColor,
              ),
        onPressed: putLike,
      ),
    );
  }

  Future<void> func(Event loadedEvent) async {
    await Navigator.of(context)
        .pushNamed(CreatingEventScreen.routeName, arguments: loadedEvent);
    setState(() {});
  }
}
