import '/screens/search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/address_widget.dart';
import '../widgets/date_widget.dart';
import '../widgets/categories_widget.dart';
import '../providers/event.dart';
import '../providers/events.dart';
import '../widgets/image_input.dart';

class CreatingEventScreen extends StatefulWidget {
  static const routeName = '/creating-event';

  const CreatingEventScreen({Key key}) : super(key: key);

  @override
  State<CreatingEventScreen> createState() => _CreatingEventScreenState();
}

class _CreatingEventScreenState extends State<CreatingEventScreen> {
  SearchPlacesScreen searchPlacesScreen = SearchPlacesScreen();
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  List<dynamic> curComments;
  List<dynamic> curCommentators;
  Map<String, dynamic> redactedEvent = {
    'id': null,
    'dateTime': '',
    'description': '',
    'name': '',
    'price': '',
    'address': '',
    'extraInformation': '',
    'imageUrl': '',
    'categories': {
      'Спорт': false,
      'Развлечения': false,
      'Вечеринки': false,
      'Прогулка': false,
      'Искусство': false,
      'Обучение': false,
      'Концерт': false,
      'Настольные игры': false,
      'Гастрономия': false,
    },
    'creatorId': '',
  };
  bool showDateTime = false;

  Event event;
  bool alreadyBuild = false;
  Map<String, dynamic> oldCategories;
  Set<Marker> markersList = {};

  GoogleMapController googleMapController;

  int screen;

  // 1 - с центрального
  // 2 - при создании
  // 3 - при редактировании

  void copyData() {
    print("redactedEvent['imageUrl'] ${redactedEvent['imageUrl']}");
    event = Event(
      id: redactedEvent['id'],
      dateTime: redactedEvent['dateTime'],
      description: redactedEvent['description'],
      name: redactedEvent['name'],
      price: redactedEvent['price'],
      address: redactedEvent['address'],
      extraInformation: redactedEvent['extraInformation'],
      imagePath: redactedEvent['imageUrl'],
      creatorId: redactedEvent['creatorId'],
      categories: redactedEvent['categories'],
    );
  }

  bool categoriesCorrect() {
    for (String category in event.categories.keys) {
      if (event.categories[category] == true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> validate() async {
    // if (event.dateTime != '' && event.dateTime != null)
    if (event.imagePath != '' && event.description != null) {
      if (event.description != '' && event.description != null) {
        if (event.name != '' && event.name != null) {
          if (event.price != '' && event.price != null) {
            if (event.address != '' && event.address != null) {
              if (event.extraInformation != '' &&
                  event.extraInformation != null) {
                if (categoriesCorrect()) {
                  return true;
                }
                print('Categories not input');
              }
              print('ExtraInfo not input');
            }
            print('Address not input');
          }
          print('Price not input');
        }
        print('Name not input');
      }
      print('Image not found');
    }
    print('Description not input');

    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred!'),
        content:
            Text('Вы не прошли валидацию. Какое-то из полей осталось пустым!'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _saveForm() async {
    _form.currentState.save();
    if (!await validate()) {
      return;
    }
    try {
      event.comments = curComments;
      event.commentators = curCommentators;
      if (event.id != null) {
        await Provider.of<Events>(context, listen: false)
            .updateEvent(event.id, event);
      } else {
        // event.imagePath =
        //     'https://foni.club/uploads/posts/2022-12/1672339955_foni-club-p-kartinki-na-telefon-yarkie-visokogo-kaches-3.jpg';
        await Provider.of<Events>(context, listen: false).addEvent(event);
      }
    } catch (error) {
      print("ERROR $error");
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
    Navigator.of(context).pop(event);
  }

  Widget makeField(
    String curInitialValue,
    String curLabelText,
    String fieldName,
  ) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: (fieldName == 'address')
          ? AddressWidget(event, redactedEvent)
          : (fieldName == 'dateTime')
              ? DateWidget(event, redactedEvent)
              : (fieldName == 'categories')
                  ? CategoriesWidget(event, redactedEvent)
                  : (fieldName == 'price')
                      ? TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: curInitialValue,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            labelText: curLabelText,
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          textInputAction: TextInputAction.next,
                          // focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: ((value) =>
                              value.isEmpty ? 'Please provide a name' : null),
                          onSaved: (value) {
                            redactedEvent[fieldName] = value;
                            copyData();
                          })
                      : TextFormField(
                          initialValue: curInitialValue,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            labelText: curLabelText,
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          textInputAction: TextInputAction.next,
                          // focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: ((value) =>
                              value.isEmpty ? 'Please provide a name' : null),
                          onSaved: (value) {
                            redactedEvent[fieldName] = value;
                            copyData();
                          },
                        ),
    );
  }

  void copyStartValues(Event event) {
    redactedEvent['id'] = event.id;
    redactedEvent['dateTime'] = event.dateTime;
    redactedEvent['description'] = event.description;
    redactedEvent['name'] = event.name;
    redactedEvent['price'] = event.price;
    redactedEvent['address'] = event.address;
    redactedEvent['extraInformation'] = event.extraInformation;
    redactedEvent['imageUrl'] = event.imagePath;
    redactedEvent['creatorId'] = event.creatorId;
    redactedEvent['isFavorite'] = event.isFavorite;
    redactedEvent['categories'] = event.categories;
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyBuild) {
      event = ModalRoute.of(context).settings.arguments as Event;
      curComments = event.comments;
      curCommentators = event.commentators;
      copyStartValues(event);
      alreadyBuild = true;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title:
              Text('Создание события', style: TextStyle(color: Colors.black))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          //color: Color.fromARGB(255, 2, 55, 69),
          child: Column(
            children: <Widget>[
              ImageInput(event, redactedEvent),
              SizedBox(height: 20),
              // LocationInput(_selectPlace),
              SizedBox(height: 20),
              Container(
                // color: Color.fromARGB(255, 2, 55, 69),
                child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      makeField(event.name, 'Название', 'name'),
                      makeField(event.price, 'Цена', 'price'),
                      makeField(
                          event.dateTime == null
                              ? ''
                              : event.dateTime.toString(),
                          'Время',
                          'dateTime'),
                      makeField(event.description, 'Описание', 'description'),
                      makeField(
                          event.address.title, event.address.title, 'address'),
                      makeField(event.extraInformation,
                          'Дополнительная информация', 'extraInformation'),
                      makeField('', '', 'categories'),
                      Container(
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(25)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(20)))),
                          child: Text(
                            "Сохранить",
                            style: TextStyle(
                              fontSize: 19,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: _saveForm,
                        ),
                      ),
                    ],
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
