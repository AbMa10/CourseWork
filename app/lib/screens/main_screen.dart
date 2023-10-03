import '/screens/search_places_screen.dart';
import 'package:provider/provider.dart';
import '../providers/profiles.dart';
import '/screens/profile_screen.dart';
import '../widgets/popup_categories.dart';
import 'package:flutter/material.dart';

import '../providers/screen_number.dart';
import '../widgets/events_grid.dart';
import '../widgets/money_fields.dart';
import '../widgets/date_popup.dart';
import '../providers/address.dart';

class MainScreen extends StatefulWidget {
  static Address address;
  _MainScreenState state = _MainScreenState();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool firstScreen = false;
  int selectedPageIndex = 0;
  bool fromDetail = false;
  String selecDate = null;
  Map<String, dynamic> categoriesForEventsScreen = {
    'Спорт': false,
    'Развлечения': false,
    'Вечеринки': false,
    'Прогулка': false,
    'Искусство': false,
    'Обучение': false,
    'Концерт': false,
    'Настольные игры': false,
    'Гастрономия': false,
  };

  List<Map<String, Object>> _pages;

  bool alreadyCreated = false;

  @override
  void initState() {
    _pages = [
      {
        'page': SearchPlacesScreen(
          fromDetailScreen: false,
        ),
        'title': 'Карта',
      },
      {
        'title': 'Мероприятия',
      },
      {
        'page': ProfileScreen(),
        'title': 'Профиль',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    // print(index);
    setState(() {
      ScreenNumber.number_of_screen = index;
    });
  }

  void displayFirstScreen() {
    setState(() {
      ScreenNumber.number_of_screen = 0;
      firstScreen = true;
    });
  }

  Future<void> addProfile() async {
    try {
      print('SET PROFILE');
      await Provider.of<Profiles>(context, listen: false).checkIfAdded();
      final curProfile = Profiles.curProfile;
      if (curProfile.wasDeleted != "false") {
        String startStr =
            'В связи с поступившими жалобами были удалены следующие ваши мероприятия: ';
        String strToParse = curProfile.wasDeleted;
        print('String to parse');
        print(strToParse);
        List<String> eventsToDelete = strToParse.split('*');
        for (String eventName in eventsToDelete) {
          startStr += eventName + '\n';
          print('startStr');
          print(startStr);
        }
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(
              startStr,
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
                    'Закрыть',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
        curProfile.wasDeleted = "false";
        await Provider.of<Profiles>(context, listen: false)
            .updateProfile(curProfile.id, curProfile);
      }
    } catch (error) {
      throw error;
    }
  }

  void setProfile() async {
    await addProfile();
  }

  int newMinPrice = 0;
  int newMaxPrice = 1000000;
  @override
  Widget build(BuildContext context) {
    if (!firstScreen) {
      displayFirstScreen();
    }
    print("INDEX ${ScreenNumber.number_of_screen}");
    // for (var category in categoriesForEventsScreen.keys) {
    //   print('MAIN CATEGORY $category ${categoriesForEventsScreen[category]}');
    // }
    Provider.of<ScreenNumber>(context);
    // print("BUILDIK ${ScreenNumber.number_of_screen}");
    // print("DISPLAY12 ADDRESS ${address.title}");
    // if (!alreadyCreated) {
    setProfile();
    //alreadyCreated = true;
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Container(
              height: 19,
              child: Text(
                'Palm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 20,
              child: Image.asset('assets/images/palm-tree.png',
                  fit: BoxFit.fill, height: 80, width: 25, scale: 0.8),
            ),
          ],
        ),
      ),
      body: ScreenNumber.number_of_screen == 3
          ? SearchPlacesScreen(
              fromDetailScreen: true,
              address: MainScreen.address,
            )
          : (_pages[ScreenNumber.number_of_screen % 3]['title'] == 'Мероприятия'
              ? EventsGrid(
                  categoriesForEventsScreen,
                  1,
                  minPrice: newMinPrice,
                  maxPrice: newMaxPrice,
                  selectedDate: selecDate,
                )
              : _pages[ScreenNumber.number_of_screen % 3]['page']),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: ScreenNumber.number_of_screen % 3,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Карта',
            icon: Icon(Icons.map),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Мероприятия',
            icon: Icon(Icons.event),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Профиль',
            icon: Icon(Icons.account_box_outlined),
          ),
        ],
      ),
      floatingActionButton:
          _pages[ScreenNumber.number_of_screen % 3]['title'] == 'Мероприятия'
              ? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.filter_alt_rounded),
                          color: Theme.of(context).primaryColor,
                          onPressed: callPopUp,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.money),
                          color: Theme.of(context).primaryColor,
                          onPressed: callMoneyScreen,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        height: 50,
                        child: IconButton(
                          icon: Icon(Icons.timer_rounded),
                          color: Theme.of(context).primaryColor,
                          onPressed: callDateChooseScreen,
                        ),
                      )
                    ],
                  ),
                )
              : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void callDateChooseScreen() async {
    String newDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => DateChoose(
          newTime: selecDate,
        ).build(context),
      ),
    );
    setState(() {
      selecDate = newDate;
    });
  }

  void callMoneyScreen() async {
    List<String> prices = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MoneyChoose(
          minPrice: newMinPrice,
          maxPrice: newMaxPrice,
        ).build(context),
      ),
    ) as List<String>;
    setState(() {
      newMinPrice = int.parse(prices[0]);
      newMaxPrice = int.parse(prices[1]);
      print('newMinPrice ${newMinPrice}');
      print('newMaxPrice ${newMaxPrice}');
    });
  }

  Future<void> callPopUp() async {
    dynamic newCategories = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PopUpDialog(
          oldCategories: categoriesForEventsScreen,
        ).build(context),
      ),
    ) as Map<String, dynamic>;
    setFilters(newCategories);
  }

  void setFilters(Map<String, dynamic> newCategories) {
    setState(() {
      for (String key in newCategories.keys) {
        categoriesForEventsScreen[key] = newCategories[key];
      }
    });
  }
}
