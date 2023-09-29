import '../providers/profile.dart';
import '../providers/profiles.dart';
import '../screens/event_detail_screen.dart';
import '../screens/moderator_detail_screen.dart';
import '/providers/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/event.dart';
import '../screens/splash_screen.dart';

class EventsGrid extends StatefulWidget {
  int pageWeComeFrom;
  bool haveFinalData = false;
  int minPrice;
  int maxPrice;
  String selectedDate;

  // 1 - делаем главный экран (принимаем фильтры и выводим все мероприятия
  // 3 - делаем экран моих мероприятий
  // 2 - делаем экран избранных мероприятий
  // 4 - делаем экран для модератора

  Map<String, dynamic> selectedCategories;
  EventsGrid(this.selectedCategories, this.pageWeComeFrom,
      {this.minPrice = null, this.maxPrice = null, this.selectedDate});

  @override
  State<EventsGrid> createState() => _EventsGridState();
}

class _EventsGridState extends State<EventsGrid> {
  bool isLoading = false;
  List<Event> events;

  Map<String, String> eventIdCreatorEmail = Map();

  void findAllEvents() async {
    print('CAll find all event');
    await Provider.of<Events>(context, listen: false).fetchAndSetEvents(false);
    await Provider.of<Profiles>(context, listen: false).fetchAndSetProfile();
    List<Profile> curAllProfiles = Provider.of<Profiles>(context, listen: false).profiles;
    events = await Provider.of<Events>(context, listen: false).events;
    for (Event event in events) {
      String profileId = event.profileId;
      String eventId = event.id;
      Profile profile = curAllProfiles.firstWhere((prof) => prof.id == profileId);
      String profileEmail = profile.email;
      print('CCprofileEmail ${profileEmail}');
      print('CCeventId ${eventId}');
      print('CCprofileId ${profileId}');
      print('CCprofile ${profile}');
      eventIdCreatorEmail[eventId] = profileEmail;
      
    }
  }

  void findCorrectEvents() async {
    print('CAll find correct');
    await Provider.of<Events>(context, listen: false).fetchAndSetEvents(false);
    events = await Provider.of<Events>(context, listen: false).events;
    if (widget.selectedDate != null) {
      DateTime selecDate = DateTime.parse(widget.selectedDate);
      events.removeWhere((element) => !isDateCorrect(element, selecDate));
    }
    events.removeWhere((element) => !isPriceCorrect(element));

    for (String key in widget.selectedCategories.keys) {
      if (widget.selectedCategories[key] == true) {
        events.removeWhere((element) => !isAppropriate(element));
        break;
      }
    }
  }

  bool isDateCorrect(Event event, DateTime selectedDate) {
    DateTime eventDateTime = DateTime.parse(event.dateTime);
    if (selectedDate.year == eventDateTime.year) {
      if (selectedDate.month == eventDateTime.month) {
        if (selectedDate.day == eventDateTime.day) {
          return true;
        }
      }
    }
    return false;
  }

  bool isPriceCorrect(Event event) {
    print('curEventPrice ${event.price} minPrice${widget.minPrice}');
    print('curEventPrice ${event.price} maxPrice${widget.maxPrice}');
    if (int.parse(event.price) < widget.minPrice ||
        int.parse(event.price) > widget.maxPrice) {
      return false;
    }
    return true;
  }

  void findFavorite() async {
    await Provider.of<Events>(context, listen: false).fetchAndSetEvents();
    events = await Provider.of<Events>(context, listen: false).favoriteEvents;
  }

  void findMyEvents() async {
    await Provider.of<Events>(context, listen: false).fetchAndSetEvents(true);
    events = await Provider.of<Events>(context, listen: false).events;
  }

  bool isAppropriate(Event event) {
    for (String selectedFilter in widget.selectedCategories.keys) {
      if (event.categories[selectedFilter] == true) {
        if (widget.selectedCategories[selectedFilter] == true) {
          return true;
        }
      }
    }
    return false;
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    if (widget.pageWeComeFrom == 1) {
      await findCorrectEvents();
    } else if (widget.pageWeComeFrom == 2) {
      await findMyEvents();
    } else if (widget.pageWeComeFrom == 3) {
      await findFavorite();
    } else if (widget.pageWeComeFrom == 4) {
      await findAllEvents();
    }
    setState(() {
      widget.haveFinalData = true;
      isLoading = false;
    });
  }

  void openDetailScreen(String id) async {
    await Navigator.of(context).pushNamed(
      EventDetailScreen.routeName,
      arguments: id,
    );
    setState(() {
      widget.haveFinalData = false;
    });
  }

  void openModeratorDetailScreen(String id) async {
    await Navigator.of(context).pushNamed(
      ModeratorDetailScreen.routeName,
      arguments: id,
    );
    setState(() {
      widget.haveFinalData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('GRID BUiLD');
    if (!widget.haveFinalData) {
      fetchData();
    }

    if (isLoading) {
      return SplashScreen();
    }

    if (events == null || events.length == 0) {
      return Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Center(
          child: Text("У вас нет мероприятий",
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).primaryColor,
              )),
        ),
      );
    }

    Widget makeModeratorEventItem({
      final String id,
      final String title,
      final String imageUrl,
      final int amountOfComplaints,
      final String profileId,
    }) {
      String creatorEmail = eventIdCreatorEmail[id];
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () => openModeratorDetailScreen(id),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              width: 100,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Hero(
                          tag: id,
                          child: FadeInImage(
                            width: double.infinity,
                            height: 127,
                            fit: BoxFit.cover,
                            placeholder: AssetImage(
                                'assets/images/product-placeholder.png'),
                            image: NetworkImage(
                              imageUrl,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          width: 250,
                          color: Colors.black54,
                          child: Text(
                            title,
                            style: TextStyle(fontSize: 26, color: Colors.white),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text(
                          amountOfComplaints.toString() + ' жалоб(а)',
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(
                          creatorEmail,
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget makeEventItem({
      final String id,
      final String title,
      final String imageUrl,
      final String price,
      final String address,
      final String time,
    }) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () => openDetailScreen(id),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              width: 100,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Hero(
                          tag: id,
                          child: FadeInImage(
                            width: double.infinity,
                            height: 127,
                            fit: BoxFit.cover,
                            placeholder: AssetImage(
                                'assets/images/product-placeholder.png'),
                            image: NetworkImage(
                              imageUrl,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          width: 250,
                          color: Colors.black54,
                          child: Text(
                            title,
                            style: TextStyle(fontSize: 26, color: Colors.white),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  time.toString(),
                                  style: TextStyle(fontSize: 18),
                                  //  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  price.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: 350,
                          child: Row(
                            children: [
                              Icon(
                                Icons.place,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 250,
                                child: Text(
                                  address,
                                  style: TextStyle(fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: GridView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: events.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          // create: (c) => products[i], // first option
          value: events[i],
          // second option (if ChangeNotifierProvider.value() is used)
          child: widget.pageWeComeFrom == 4
              ? makeModeratorEventItem(
                  id: events[i].id,
                  title: events[i].name,
                  imageUrl: events[i].imagePath,
                  amountOfComplaints: events[i].countOfComplains,
                  profileId: events[i].profileId,
                )
              : makeEventItem(
                  id: events[i].id,
                  title: events[i].name,
                  price: events[i].price,
                  address: events[i].address.title,
                  time: events[i].dateTime,
                  imageUrl: events[i].imagePath,
                ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}
