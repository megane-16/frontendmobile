import '../models/quiz_model.dart';

class QuizRepository {
  String normalizeSchoolKey(String? schoolName) {
    final value = (schoolName ?? '').toLowerCase();
    final compact = value.replaceAll(RegExp(r'[^a-z0-9]'), '');

    if (compact.contains('kopa')) return 'kopa';
    if (compact.contains('paris')) return 'paris';
    return 'paris';
  }

  List<String> getSchoolModules(String? schoolName) {
    final schoolKey = normalizeSchoolKey(schoolName);

    if (schoolKey == 'kopa') {
      return [
        'Gestion de la priorité à droite',
        'Conduite en ville et respect du code',
        'Analyse des panneaux et intersections',
        'Sécurité et prévention des risques',
      ];
    }

    return [
      'Signalisation et contraintes de circulation',
      'Priorités, intersections et rond-points',
      'Vitesse, sécurité et distances',
      'Conduite en agglomération et autoroute',
    ];
  }

  List<Question> getOfficialExamQuestions({int count = 20}) {
    final List<Question> examBank = [
      // 1. Signalisation et Panneaux
      Question(
        text: "Que signifie ce panneau de signalisation triangulaire bordé de rouge ?",
        options: [
          "Une interdiction temporaire",
          "Un signal de danger immédiat ou avancé",
          "Une obligation de bifurquer",
          "Une fin de prescription",
        ],
        correctAnswerIndex: 1,
        explanation: "Tous les panneaux triangulaires avec une bordure rouge annoncent un danger (à 50m en agglomération, 150m hors agglomération).",
        imageUrl: "assets/images/quiz/attention.png",
      ),
      Question(
        text: "À la vue de ce panneau, je dois m'attendre à :",
        options: [
          "Une présence éventuelle de piétons ou cyclistes à proximité",
          "Une voie réservée exclusivement aux vélos",
          "Une interdiction aux deux-roues",
          "Une obligation d'accélérer",
        ],
        correctAnswerIndex: 0,
        explanation: "Ce panneau de danger signale un débouché ou une traversée fréquente de cyclistes ou d'usagers vulnérables.",
        imageUrl: "assets/images/quiz/bicycle-warning-sign-modern-square-pedestrian-crossing-road-sign-against-blue-sky.jpg",
      ),
      Question(
        text: "Ce panneau indique que la circulation s'effectue :",
        options: [
          "En sens unique",
          "En double sens prioritaire",
          "Sur une piste réservée",
          "Avec obligation de tourner",
        ],
        correctAnswerIndex: 0,
        explanation: "Le panneau carré bleu comportant une flèche blanche indique une chaussée à sens unique.",
        imageUrl: "assets/images/quiz/une-maniere.png",
      ),
      Question(
        text: "Ce panneau m'interdit formellement l'accès dans cette direction :",
        options: [
          "Oui, c'est un sens interdit pour tous les véhicules",
          "Non, seulement pour les véhicules lourds",
          "Oui, sauf pour les riverains",
          "Non, c'est un arrêt facultatif",
        ],
        correctAnswerIndex: 0,
        explanation: "Le panneau rond à fond rouge barré d'une bande blanche horizontale constitue un sens interdit absolu.",
        imageUrl: "assets/images/quiz/entree-interdite.png",
      ),
      Question(
        text: "À l'approche de cette zone de travaux, quel comportement adopter ?",
        options: [
          "Ralentir, augmenter la distance de sécurité et veiller au personnel",
          "Accélérer pour ne pas gêner le chantier",
          "Klaxonner pour prévenir les ouvriers",
          "Maintenir ma vitesse maximale autorisée",
        ],
        correctAnswerIndex: 0,
        explanation: "La présence de travaux impose une vigilance accrue, une réduction de la vitesse et le respect des déviations éventuelles.",
        imageUrl: "assets/images/quiz/travaux-routiers.png",
      ),
      Question(
        text: "Sur cette portion de route, ma vitesse ne doit pas dépasser :",
        options: [
          "70 km/h",
          "80 km/h",
          "90 km/h",
          "110 km/h",
        ],
        correctAnswerIndex: 1,
        explanation: "Le panneau rond cerclé de rouge fixe la limitation de vitesse maximale absolue à 80 km/h.",
        imageUrl: "assets/images/quiz/limite-de-vitesse-80.png",
      ),
      Question(
        text: "Ce panneau annonce que la chaussée :",
        options: [
          "Va rétrécir des deux côtés",
          "Va s'élargir sur la droite",
          "Est glissante par temps de pluie",
          "Se termine en impasse",
        ],
        correctAnswerIndex: 0,
        explanation: "Ce signal triangulaire indique un rétrécissement symétrique de la voie de circulation.",
        imageUrl: "assets/images/quiz/panneau-de-signalisation-de-route-etroite.png",
      ),

      // 2. Priorités et Intersections
      Question(
        text: "À une intersection sans aucune signalisation, quelle règle s'applique ?",
        options: [
          "Priorité au véhicule le plus rapide",
          "Priorité à droite stricte",
          "Priorité à gauche",
          "Priorité au véhicule le plus volumineux",
        ],
        correctAnswerIndex: 1,
        explanation: "En l'absence totale de panneaux ou de feux, la règle fondamentale du Code de la route est la priorité à droite.",
      ),
      Question(
        text: "Dans un rond-point giratoire (panneau 'Cédez le passage' à l'entrée), qui a la priorité ?",
        options: [
          "Les véhicules qui s'engagent",
          "Les véhicules déjà engagés sur l'anneau",
          "Les véhicules arrivant de gauche uniquement",
          "Le premier véhicule qui klaxonne",
        ],
        correctAnswerIndex: 1,
        explanation: "Dans un carrefour à sens giratoire, les usagers circulant sur l'anneau sont prioritaires.",
      ),
      Question(
        text: "Je tourne à gauche à un carrefour. Dois-je céder le passage au véhicule arrivant en face ?",
        options: [
          "Oui, car je coupe sa trajectoire",
          "Non, j'ai la priorité car je suis engagé",
          "Seulement s'il me fait des appels de phares",
          "Non, la priorité appartient à celui qui tourne",
        ],
        correctAnswerIndex: 0,
        explanation: "En tournant à gauche, on coupe l'axe de circulation opposé : on doit toujours céder le passage aux usagers venant d'en face.",
      ),
      Question(
        text: "Face à un feu tricolore clignotant au jaune/orange au centre, quelle règle s'applique ?",
        options: [
          "Le passage est strictement interdit",
          "Je passe avec prudence en respectant la signalisation ou la priorité à droite",
          "Le feu va passer directement au vert",
          "Je dois obligatoirement m'arrêter 3 secondes",
        ],
        correctAnswerIndex: 1,
        explanation: "Un feu jaune clignotant invite à la prudence et indique que les feux ne régulent plus ; on applique les panneaux ou la priorité à droite.",
      ),

      // 3. Sécurité routière, distances et freinage
      Question(
        text: "Sur chaussée mouillée, par combien la distance de freinage est-elle multipliée ?",
        options: [
          "Elle ne change pas",
          "Multipliée par 1,5",
          "Multipliée par 2",
          "Multipliée par 3",
        ],
        correctAnswerIndex: 2,
        explanation: "L'adhérence des pneumatiques étant réduite de moitié sur sol mouillé, la distance de freinage est doublée.",
      ),
      Question(
        text: "Quel est le temps de réaction moyen d'un conducteur attentif et en bonne condition physique ?",
        options: [
          "0,2 seconde",
          "Environ 1 seconde",
          "3 secondes",
          "5 secondes",
        ],
        correctAnswerIndex: 1,
        explanation: "En moyenne, le temps de réaction est de 1 seconde (pendant laquelle le véhicule continue d'avancer à sa vitesse initiale).",
      ),
      Question(
        text: "En agglomération, quelle distance latérale minimale faut-il laisser pour dépasser un piéton ou un cycliste ?",
        options: [
          "0,50 mètre",
          "1 mètre",
          "1,50 mètre",
          "2 mètres",
        ],
        correctAnswerIndex: 1,
        explanation: "L'intervalle de sécurité latéral est d'au moins 1 mètre en agglomération (et 1,50 mètre hors agglomération).",
      ),
      Question(
        text: "Le port de la ceinture de sécurité est obligatoire :",
        options: [
          "Uniquement pour le conducteur et le passager avant",
          "Uniquement sur autoroute et voie rapide",
          "À l'avant comme à l'arrière pour tous les occupants",
          "Facultatif sur les trajets courts en ville",
        ],
        correctAnswerIndex: 2,
        explanation: "La ceinture est obligatoire pour tous les passagers à chaque place équipée, quel que soit le type de trajet.",
      ),
      Question(
        text: "À partir de quel taux d'alcoolémie la conduite devient-elle passible de sanctions légales (permis classique) ?",
        options: [
          "0,2 g/l de sang",
          "0,5 g/l de sang",
          "0,8 g/l de sang",
          "1,0 g/l de sang",
        ],
        correctAnswerIndex: 1,
        explanation: "Le seuil légal d'interdiction pour les conducteurs confirmés est fixé à 0,5 g d'alcool par litre de sang (soit 0,25 mg/l d'air expiré).",
      ),

      // 4. Conduite sur autoroute et dépassements
      Question(
        text: "Sur autoroute, est-il autorisé de circuler ou stationner sur la bande d'arrêt d'urgence pour passer un appel ?",
        options: [
          "Oui, si on met les feux de détresse",
          "Non, c'est strictement interdit sauf en cas d'urgence absolue",
          "Oui, si l'arrêt dure moins de 2 minutes",
          "Oui, sur la voie de droite",
        ],
        correctAnswerIndex: 1,
        explanation: "La bande d'arrêt d'urgence est réservée exclusivement aux arrêts d'extrême urgence et aux véhicules de secours.",
      ),
      Question(
        text: "Avant d'effectuer un dépassement sur route, quelle est la première action à réaliser ?",
        options: [
          "Accélérer franchement",
          "Contrôler les rétroviseurs et l'angle mort, puis mettre le clignotant",
          "Klaxonner le véhicule dépassé",
          "Faire des appels de phares",
        ],
        correctAnswerIndex: 1,
        explanation: "Tout changement de trajectoire commence par la vérification visuelle (rétroviseurs + angles morts) et l'avertissement clignotant.",
      ),

      // 5. Premiers secours et Éco-conduite
      Question(
        text: "En cas d'accident corporel sur la route, quel est le premier réflexe à adopter ?",
        options: [
          "Donner à boire au blessé",
          "Protéger les lieux pour éviter un suraccident (baliser, gilet, feux de détresse)",
          "Déplacer immédiatement la victime hors du véhicule",
          "Appeler son assurance auto",
        ],
        correctAnswerIndex: 1,
        explanation: "La démarche vitale est la règle P.A.S : 1. Protéger, 2. Alerter les secours (112 / 15 / 18), 3. Secourir sans geste imprudent.",
      ),
      Question(
        text: "Pour pratiquer une éco-conduite efficace, il est recommandé de :",
        options: [
          "Passer les rapports de vitesse à bas régime et anticiper les ralentissements",
          "Rouler au point mort dans les descentes",
          "Accélérer fort entre chaque feu rouge",
          "Couper le moteur en roulant",
        ],
        correctAnswerIndex: 0,
        explanation: "Anticiper le trafic et adopter une conduite souple à bas régime permet de réduire jusqu'à 20% de carburant et d'émissions polluantes.",
      ),
    ];

    examBank.shuffle();
    return examBank.take(count).toList();
  }

  List<Question> getQuestionsForSchool(String? schoolName, {int count = 25}) {
    return getOfficialExamQuestions(count: count);
  }

  List<Question> generateSchoolExamQuestions(
    String? schoolName, {
    int count = 15,
  }) {
    return getOfficialExamQuestions(count: count);
  }

  List<Question> getMockQuestions() {
    return [
      // 1. Signalisation avec vos nouvelles images
      Question(
        text: "Que signifie ce panneau de forme triangulaire bordé de rouge ?",
        options: [
          "Une interdiction",
          "Un danger",
          "Une obligation",
          "Une indication",
        ],
        correctAnswerIndex: 1,
        explanation:
            "Les panneaux triangulaires bordés de rouge signalent toujours un danger.",
        imageUrl: "assets/images/quiz/attention.png",
      ),
      Question(
        text: "Ce panneau indique que la circulation s'effectue :",
        options: ["En double sens", "En sens unique", "Sur une voie privée"],
        correctAnswerIndex: 1,
        explanation:
            "Le panneau carré bleu avec une flèche blanche indique une route à sens unique.",
        imageUrl: "assets/images/quiz/une-maniere.png",
      ),
      Question(
        text: "Ce panneau m'interdit l'accès à cette rue :",
        options: [
          "Oui, pour tous les véhicules",
          "Non, seulement pour les camions",
          "Oui, mais je peux faire marche arrière",
        ],
        correctAnswerIndex: 0,
        explanation:
            "Le panneau rond rouge avec une barre horizontale blanche signifie 'Sens interdit'.",
        imageUrl: "assets/images/quiz/entree-interdite.png",
      ),
      Question(
        text: "À la vue de ce panneau, je dois :",
        options: [
          "Accélérer pour passer vite",
          "Ralentir et faire attention aux ouvriers",
          "Changer de direction",
        ],
        correctAnswerIndex: 1,
        explanation:
            "Ce panneau annonce des travaux. La prudence et une vitesse réduite sont obligatoires.",
        imageUrl: "assets/images/quiz/travaux-routiers.png",
      ),
      Question(
        text: "Sur cette route, ma vitesse est limitée à :",
        options: ["70 km/h", "80 km/h", "90 km/h"],
        correctAnswerIndex: 1,
        explanation:
            "Le chiffre inscrit sur le panneau de prescription indique la vitesse maximale autorisée.",
        imageUrl: "assets/images/quiz/limite-de-vitesse-80.png",
      ),
      Question(
        text: "Ce panneau de danger prévient que :",
        options: [
          "La route va s'élargir",
          "La chaussée va rétrécir",
          "Le passage est interdit aux voitures",
        ],
        correctAnswerIndex: 1,
        explanation: "Il s'agit d'un signal de chaussée rétrécie.",
        imageUrl:
            "assets/images/quiz/panneau-de-signalisation-de-route-etroite.png",
      ),
      Question(
        text: "Ce panneau annonce la proximité :",
        options: [
          "D'une piste cyclable",
          "D'un passage pour piétons",
          "D'un danger lié aux cyclistes",
        ],
        correctAnswerIndex: 2,
        explanation:
            "Ce panneau de danger prévient du passage fréquent de cyclistes.",
        imageUrl:
            "assets/images/quiz/bicycle-warning-sign-modern-square-pedestrian-crossing-road-sign-against-blue-sky.jpg",
      ),

      // Suite du quiz théorique
      Question(
        text:
            "Face à un feu rouge, je peux tourner à droite si un panneau de signalisation me l'autorise :",
        options: [
          "Oui, mais je dois céder le passage",
          "Oui, j'ai la priorité",
          "Non, le feu rouge est absolu",
        ],
        correctAnswerIndex: 0,
        explanation:
            "Un panneau (souvent une flèche jaune clignotante) peut autoriser à tourner à droite, mais le conducteur doit céder le passage aux piétons et aux véhicules de la voie transversale.",
      ),
      Question(
        text: "Ce panneau indique une fin de priorité :",
        options: ["Vrai", "Faux"],
        correctAnswerIndex: 0,
        explanation:
            "Le panneau 'losange jaune barré' indique que la route sur laquelle vous circulez n'est plus prioritaire.",
      ),
      Question(
        text: "À cette intersection sans signalisation, qui passe en premier ?",
        options: [
          "Moi",
          "Le véhicule venant de droite",
          "Le véhicule venant de gauche",
        ],
        correctAnswerIndex: 1,
        explanation:
            "En l'absence de signalisation, la règle de la priorité à droite s'applique.",
      ),
      Question(
        text:
            "Je souhaite tourner à gauche. Je dois céder le passage au véhicule venant en face :",
        options: ["Oui", "Non"],
        correctAnswerIndex: 0,
        explanation:
            "Lorsqu'on tourne à gauche, on doit céder le passage aux véhicules venant d'en face qui vont tout droit ou tournent à droite.",
      ),
      Question(
        text:
            "Dans un rond-point, je dois céder le passage à ceux qui sont déjà engagés :",
        options: [
          "Toujours",
          "Seulement si un panneau 'Cédez le passage' est présent",
          "Jamais",
        ],
        correctAnswerIndex: 0,
        explanation:
            "Dans la quasi-totalité des carrefours à sens giratoire, les usagers circulant sur l'anneau ont la priorité.",
      ),
      Question(
        text:
            "La distance de freinage est multipliée par combien sur route mouillée ?",
        options: ["1.5", "2", "3", "4"],
        correctAnswerIndex: 1,
        explanation:
            "L'adhérence étant réduite de moitié sur route mouillée, la distance de freinage est doublée.",
      ),
      Question(
        text: "Le temps de réaction moyen d'un conducteur vigilant est de :",
        options: ["0.5 seconde", "1 seconde", "2 secondes"],
        correctAnswerIndex: 1,
        explanation:
            "Le temps de réaction est d'environ 1 seconde pour un conducteur en bonne santé et attentif.",
      ),
      Question(
        text: "Circuler avec des pneus sous-gonflés peut entraîner :",
        options: [
          "Une baisse de consommation",
          "Une meilleure tenue de route",
          "Un risque d'éclatement",
        ],
        correctAnswerIndex: 2,
        explanation:
            "Le sous-gonflage provoque un échauffement excessif du pneu, pouvant mener à son éclatement et augmente la consommation de carburant.",
      ),
      Question(
        text: "L'alcool commence à agir sur le cerveau dès le premier verre :",
        options: ["Vrai", "Faux"],
        correctAnswerIndex: 0,
        explanation:
            "Dès le premier verre, les capacités visuelles et le jugement sont altérés.",
      ),
      Question(
        text: "Manger un repas copieux permet d'éliminer l'alcool plus vite :",
        options: ["Vrai", "Faux"],
        correctAnswerIndex: 1,
        explanation:
            "Manger ralentit l'absorption de l'alcool dans le sang mais n'accélère en aucun cas son élimination par le foie.",
      ),
      Question(
        text:
            "Sur autoroute, la circulation sur la bande d'arrêt d'urgence est autorisée pour dépasser en cas de bouchon :",
        options: ["Oui", "Non"],
        correctAnswerIndex: 1,
        explanation:
            "La bande d'arrêt d'urgence est strictement réservée aux arrêts de détresse et aux véhicules de secours.",
      ),
      Question(
        text:
            "Je peux faire marche arrière sur autoroute si j'ai raté ma sortie :",
        options: ["Oui, prudemment", "Non, c'est formellement interdit"],
        correctAnswerIndex: 1,
        explanation:
            "Faire marche arrière ou demi-tour sur autoroute est extrêmement dangereux et strictement interdit.",
      ),
      Question(
        text:
            "Pour dépasser un cycliste en agglomération, je dois laisser un espace latéral d'au moins :",
        options: ["0.5 mètre", "1 mètre", "1.5 mètre"],
        correctAnswerIndex: 1,
        explanation:
            "En agglomération, l'espace latéral de sécurité doit être d'au moins 1 mètre (1.5m hors agglomération).",
      ),
      Question(
        text:
            "Lors d'un croisement difficile en pente, c'est au véhicule qui descend de s'arrêter :",
        options: ["Vrai", "Faux"],
        correctAnswerIndex: 0,
        explanation:
            "Le véhicule qui descend doit toujours s'arrêter le premier car il lui est plus facile de repartir.",
      ),
      Question(
        text: "Pratiquer l'éco-conduite permet de réduire sa consommation de :",
        options: ["5%", "15% environ", "50%"],
        correctAnswerIndex: 1,
        explanation:
            "Une conduite souple et anticipée permet d'économiser environ 15% de carburant.",
      ),
      Question(
        text:
            "Le contrôle technique d'un véhicule léger doit être effectué tous les :",
        options: ["An", "2 ans", "5 ans"],
        correctAnswerIndex: 1,
        explanation:
            "Après le premier contrôle (aux 4 ans du véhicule), il doit être renouvelé tous les 2 ans.",
      ),
      Question(
        text:
            "L'ABS empêche le blocage des roues lors d'un freinage d'urgence :",
        options: ["Oui", "Non"],
        correctAnswerIndex: 0,
        explanation:
            "L'ABS (Anti-lock Braking System) permet de garder le contrôle de la direction en évitant que les roues ne se bloquent.",
      ),
      Question(
        text: "En cas d'accident, quel est l'ordre des actions à effectuer ?",
        options: [
          "Alerter, Protéger, Secourir",
          "Protéger, Alerter, Secourir",
          "Secourir, Protéger, Alerter",
        ],
        correctAnswerIndex: 1,
        explanation:
            "L'ordre PAS : Protéger (soi-même et les autres), Alerter (les secours), Secourir (les victimes).",
      ),
    ];
  }
}
