import '../providers/profile.dart';
import '../providers/profiles.dart';
import '/providers/event.dart';
import '/screens/creating_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/build_detail_field.dart';
import '../providers/auth.dart';
import '../providers/events.dart';
import 'comments_screen.dart';

class ModeratorDetailScreen extends StatefulWidget {
  static const routeName = '/moderator-detail';

  @override
  State<ModeratorDetailScreen> createState() => _ModeratorDetailScreenState();
}

class _ModeratorDetailScreenState extends State<ModeratorDetailScreen> {
  String creatorUsername = 'Организатор';

  Event loadedEvent;
  Profile profile;
  void setUsername(String profileId) async {
    profile = await Provider.of<Profiles>(
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
                profile.wasDeleted = 'true';
                print("TTTTTTTTTTTTT ${profile.id}");
                await Provider.of<Profiles>(context, listen: false)
                    .updateProfile(profile.id, profile, flag: true);
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

    print('loadedEvent.profileId ${loadedEvent.profileId}');

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
            Container(
              padding: EdgeInsets.only(left: 230),
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  delEvent();
                },
              ),
            ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
