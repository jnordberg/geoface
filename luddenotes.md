# geoface

## features

- logga in med facebook för identitet
- hitta användare i området
- skicka meddelanden fram och tillbaka
- byt till ny
- bli vänner på facebook vid mutual agreement

## komponent: växeln

### model: mottagare

```
{uid: "516251607",
 point: [59.33630, 18.02872]}
```

### när användaren ringer upp växeln

1. växeln letar efter en mottagare i väntelista

   a. ingen hittades och sista försöket, användare läggs i väntelista

   b. ingen hittades, bredda sökparameter och försök igen

2. mottagare tas ur väntelista

3. de två mottagarna kopplas ihop, knock-knock initieras

### hitta en mottagare i väntelista

```
def score(user_a, user_b):
  return distance(user.point, user2.point)

def match(user, waitlist):
  for uid2 in waitlist.keys():
    user2 = waitlist.pop(uid2)
    if score(user, user2) <= thresh:
      return user2
    waitlist[uid2] = user2
```

## protokoll: knock-knock

1. växel skickar knock-meddelande till de två parterna

2. de två parterna skickar sin respektive identitet

3. and the rest is history


```
C> type: 'hello', profile: …, location: …
S> ok: true
```


## i framtiden

- notifications
- history
- fler sökparametrar (geo, grupp, vänner, vänners vänner)