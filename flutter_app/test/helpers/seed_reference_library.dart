import 'package:checklist_voyage_v1/domain/models/checklist_models.dart';
import 'package:checklist_voyage_v1/domain/repositories/library_repository.dart';

class ReferenceLibraryIds {
  const ReferenceLibraryIds({
    required this.essentialOwner,
    required this.passportItem,
    required this.participantOwner,
    required this.shirtItem,
    required this.flightOwner,
    required this.trainOwner,
    required this.hotelOwner,
    required this.campingOwner,
    required this.personalOwner,
    required this.personalItem,
  });

  final String essentialOwner;
  final String passportItem;
  final String participantOwner;
  final String shirtItem;
  final String flightOwner;
  final String trainOwner;
  final String hotelOwner;
  final String campingOwner;
  final String personalOwner;
  final String personalItem;
}

Future<ReferenceLibraryIds> seedReferenceLibrary(
  LibraryRepository repository,
) async {
  final essentialOwner = await repository.createOwner(
    name: 'Essentiel',
    kind: LibraryOwnerKind.general,
    generationRole: GenerationRole.essential,
  );
  final essentialCategory = await repository.createCategory(
    essentialOwner,
    'Documents',
  );
  final passportItem = await repository.createItem(
    categoryId: essentialCategory,
    name: 'Passeport',
    defaultQuantity: 2,
  );

  final participantOwner = await repository.createOwner(
    name: 'Alex',
    kind: LibraryOwnerKind.familyMember,
    generationRole: GenerationRole.participant,
  );
  final participantCategory = await repository.createCategory(
    participantOwner,
    'Vêtements',
  );
  final shirtItem = await repository.createItem(
    categoryId: participantCategory,
    name: 'T-shirt',
    defaultQuantity: 4,
  );

  final flightOwner = await _choiceOwner(
    repository,
    'Trajet - Avion',
    GenerationRole.transport,
    'Billet avion',
  );
  final trainOwner = await _choiceOwner(
    repository,
    'Trajet - Train',
    GenerationRole.transport,
    'Billet train',
  );
  final hotelOwner = await _choiceOwner(
    repository,
    'Logement - Hôtel',
    GenerationRole.lodging,
    'Réservation hôtel',
  );
  final campingOwner = await _choiceOwner(
    repository,
    'Logement - Camping',
    GenerationRole.lodging,
    'Réservation camping',
  );

  final personalOwner = await repository.createOwner(
    name: 'Privé',
    kind: LibraryOwnerKind.personal,
    generationRole: GenerationRole.participant,
  );
  final personalCategory = await repository.createCategory(
    personalOwner,
    'Personnel',
  );
  final personalItem = await repository.createItem(
    categoryId: personalCategory,
    name: 'Objet privé',
    defaultQuantity: 1,
  );

  return ReferenceLibraryIds(
    essentialOwner: essentialOwner,
    passportItem: passportItem,
    participantOwner: participantOwner,
    shirtItem: shirtItem,
    flightOwner: flightOwner,
    trainOwner: trainOwner,
    hotelOwner: hotelOwner,
    campingOwner: campingOwner,
    personalOwner: personalOwner,
    personalItem: personalItem,
  );
}

Future<String> _choiceOwner(
  LibraryRepository repository,
  String name,
  GenerationRole role,
  String itemName,
) async {
  final owner = await repository.createOwner(
    name: name,
    kind: LibraryOwnerKind.general,
    generationRole: role,
  );
  final category = await repository.createCategory(owner, name);
  await repository.createItem(
    categoryId: category,
    name: itemName,
    defaultQuantity: 1,
  );
  return owner;
}
