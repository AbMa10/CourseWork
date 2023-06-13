import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/providers/profile.dart';

class Profiles with ChangeNotifier {
  List<Profile> _profiles;
  final String authToken;
  final String userId;

  static String curEmail;
  static String curProfileId;
  static Profile curProfile;

  Profiles(this.authToken, this.userId, this._profiles);

  List<Profile> get profiles {
    return [..._profiles];
  }

  Future<Profile> findById(String id) async {
    print("IDDDDDDDDDdd $id");
    var url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles/$id.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      print("RESPONSEPROFILE ${response.body}");
      final prodData = json.decode(response.body) as Map<String, dynamic>;
      if (prodData == null) {
        print("NULLNNNNNNNNNNn");
        return null;
      }
      Profile curProfile = Profile(
        id: id,
        firstName: prodData['firstName'],
        lastName: prodData['lastName'],
        username: prodData['username'],
        description: prodData['description'],
        email: prodData['email'],
        age: prodData['age'],
        male: prodData['male'],
        rating: prodData['rating'],
        countOfEvents: prodData['countOfEvents'],
      );
      print('USERNAMECUR ${curProfile.username}');
      return curProfile;
    } catch (error) {
      throw error;
    }
  }

  Future<void> checkIfAdded() async {
    print('START');
    await setEmail();
    print('MIDDLE');
    await fetchAndSetProfile();
    bool isAdded = false;
    print('CUR EMAIL ${curEmail}');
    for (Profile profile in _profiles) {
      print('NEW PROFILE ${profile.email}');
      if (profile.email == curEmail) {
        print('WE FIND CUR PROFILE');
        curProfile = profile;
        curProfileId = profile.id;
        isAdded = true;
      }
    }
    if (!isAdded) {
      await addProfile(curEmail);
    }
  }

  void setEmail() async {
    var url =
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyA4s3N3M8oSVu14OeizNiIiaioiqEDaH6w';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'idToken': authToken,
          },
        ),
      );
      final responseData = json.decode(response.body);
      curEmail = responseData['users'][0]['email'];
      //print("RESPONSE$responseData");
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProfile() async {
    var url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final profiles = json.decode(response.body);

      final List<Profile> loadedProfiles = [];
      extractedData.forEach((prodId, prodData) {
        print("RESP ${prodData}");
        loadedProfiles.add(
          Profile(
            id: prodId,
            firstName: prodData['firstName'],
            lastName: prodData['lastName'],
            username: prodData['username'],
            description: prodData['description'],
            email: prodData['email'],
            age: prodData['age'],
            male: prodData['male'],
            rating: prodData['rating'],
            countOfEvents: prodData['countOfEvents'],
          ),
        );
      });
      _profiles = loadedProfiles;
      notifyListeners();
    } catch (error) {
      print("ERRR");
      throw error;
    }
  }

  Future<void> addProfile(String email) async {
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'firstName': '',
          'lastName': '',
          'username': '',
          'description': '',
          'email': email,
          'age': '',
          'male': '',
          'countOfEvents': 0,
          'rating': 5,
        }),
      );

      final newProfile = Profile(
        firstName: '',
        lastName: '',
        username: '',
        description: '',
        email: email,
        age: '',
        male: '',
        countOfEvents: 0,
        rating: 5,
        id: json.decode(response.body)['name'],
      );
      curProfileId = json.decode(response.body)['name'];
      _profiles.add(newProfile);
      curProfile = newProfile;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  // В функции нет смысла, потому что для первой подгрузки профиля мы уже должны
  // знать его id, а мы его не знаем!!!

  // void setCurrentProfile() async {
  //   print('SET PROFILE $curProfileId');
  //   Uri url = Uri.parse(
  //       'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles/$curProfileId.json?auth=$authToken');
  //   final response = await http.get(url);

  //   final responseData = json.decode(response.body);
  //   if (responseData == null) {
  //     curProfileId = null;
  //     curProfile = null;
  //   } else {
  //     Profile loadedProfile = Profile(
  //     id: responseData['id'],
  //     firstName: responseData['firstName'],
  //     lastName: responseData['lastName'],
  //     username: responseData['username'],
  //     description: responseData['description'],
  //     email: responseData['email'],
  //     age: responseData['age'],
  //     male: responseData['male'],
  //     rating: responseData['rating'],
  //     countOfEvents: responseData['countOfEvents'],
  //   );
  //   print('CUR PROFILE ${loadedProfile}');
  //   curProfile = loadedProfile;
  //   curProfileId = curProfile.id;
  //   }
  // }

  Future<void> updateProfile(String id, Profile newProfile) async {
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles/$id.json?auth=$authToken';
    print('UPDATE RATING ${newProfile.rating}');
    await http.patch(
      Uri.parse(url),
      body: json.encode(
        {
          'firstName': newProfile.firstName,
          'lastName': newProfile.lastName,
          'username': newProfile.username,
          'description': newProfile.description,
          'email': newProfile.email,
          'age': newProfile.age,
          'male': newProfile.male,
          'countOfEvents': newProfile.countOfEvents,
          'rating': newProfile.rating,
        },
      ),
    );
    if (curProfile.id == newProfile.id) {
      curProfile = newProfile;
    }
    notifyListeners();
  }
}
