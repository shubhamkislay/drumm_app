class Stats {
  int? business = 0;
  int? entertainment = 0;
  int? sports=0;
  int? health = 0;
  int? technology = 0;
  int? science = 0;
  int? politics = 0;
  int? general = 0;

  Stats();

  Map<String, dynamic> toJson() => {
    'business': business,
    'entertainment': entertainment,
    'sports': sports,
    'health': health,
    'technology': technology,
    'science': science,
    'politics': politics,
    'general': general,
  };

  Stats.fromSnapshot(snapshot)
      : business = snapshot.data()['business'],
        entertainment = snapshot.data()['entertainment'],
        sports = snapshot.data()['sports'],
        health = snapshot.data()['health'],
        technology = snapshot.data()['technology'],
        science = snapshot.data()['science'],
        politics = snapshot.data()['politics'],
        general = snapshot.data()['general'];

  Stats.fromAlgoliaSnapshot(snapshot)
      :
        business = snapshot['business'],
        entertainment = snapshot['entertainment'],
        sports = snapshot['sports'],
        health = snapshot['health'],
        technology = snapshot['technology'],
        science = snapshot['science'],
        politics = snapshot['politics'],
        general = snapshot['general'];

  Stats.fromJson(Map<String, dynamic> json)
      :
        business = json['business'],
        entertainment = json['entertainment'],
        sports = json['sports'],
        health = json['health'],
        technology = json['technology'],
        science = json['science'],
        politics = json['politics'],
        general = json['general'];
}
