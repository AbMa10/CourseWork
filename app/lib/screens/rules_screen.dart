import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  static const routeName = '/rulesScreen';
  String rules = "fdsjk";

  Widget createField(String text, BuildContext context) {
    return Expanded(
        child: Text(
      text,
      style: TextStyle(
        fontSize: 22,
        color: Theme.of(context).primaryColor,
      ),
    ));
  }

  Widget ruleField(String widgetText, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.all(10.0),
      child: createField(widgetText, context),
    );
  }

  String fText = '1.1. На фотографии не должно быть ссылок на другие сайты, а также логотипов.\n\n' +
      '1.2. Фото и изображения не должны нарушать авторские права их владельца, фотографа или возможных моделей.\n\n' +
      '1.3. На фото не должно быть элементов, которые можно расценить как оскорбительные, противозаконные или призывающие к насилию.\n\n' +
      '1.4. Если на фото кроме вас изображены и другие люди, убедитесь в том, что они согласны на публикацию своих изображений. Если на фото изображено не принадлежащее вам имущество, то необходимо согласие владельца имущества на публикацию данной фотографии.\n\n' +
      '1.5. Не допускается размещение в изображении контактных данных и регистрационных знаков, в том числе относящихся к третьим лицам.\n\n'
          '1.6. Не допускается размещение фотографий и прочих изображений эротического и порнографического характера.';

  String sText =
      'Карточки мероприятий должны быть составлены на государственном языке Российской Федерации –  русском, и содержать:\n\n' +
          '2.1. Заголовок объявления, описание мероприятия. Описание должно быть полным и достоверным, не содержать ссылок на сторонние ресурсы. В объявлении не допускается реклама товаров. Заголовок объявления не должен содержать цены, ссылки на сторонние интернет-ресурсы, email адреса, контактные данные.\n\n' +
          '2.2. Достоверную цену товара, работы или услуги. При этом цена товара (работы, услуги) обязательно должна указываться в российских рублях в специальном поле “Цена”.';

  String tText =
      'За нарушение любых из установлененых правил организация Palm оставляет за собой право удалить созданное мероприяие, однако пользователь сможет повторно создать мероприятие уже без нарушений.';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Правила', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ruleField('1. Требования к фотографиям', context),
              ruleField(fText, context),
              ruleField('2. Требования к текстовым полям мероприятия', context),
              ruleField(sText, context),
              ruleField(tText, context),
            ],
          ),
        ),
      ),
    );
  }
}

/*
1. Требования к фотографиям
1.1. На фотографии не должно быть ссылок на другие сайты, а также логотипов.




2. Требования к текстовым полям мероприятия
Карточки мероприятий должны быть составлены на государственном языке Российской Федерации –  русском, и содержать:
2.1. Заголовок объявления, описание мероприятия. Описание должно быть полным и достоверным, не содержать ссылок 
на сторонние ресурсы. В объявлении не допускается реклама товаров. Заголовок объявления не должен содержать цены, ссылки на сторонние интернет-ресурсы, 
email адреса, контактные данные.
'2.2. Достоверную цену товара, работы или услуги. При этом цена товара (работы, услуги) обязательно должна указываться в российских рублях в специальном поле “Цена”.';

За нарушение любых из установлененых правил организация Palm оставляет за собой право удалить созданное мероприяие, однако пользователь сможет 
повторно создать мероприятие уже без нарушений.
*/