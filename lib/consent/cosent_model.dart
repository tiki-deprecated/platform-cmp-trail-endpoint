import '../tiki_sdk_destination.dart';
import 'consent_repository.dart';

class ConsentModel{

  /// The ideintifier of where the 
  TikiSdkDestination destination;  
  
  /// Optional description of the consent.
  String? about;
  
  /// Optional reward description the user will receive for this consent.
  String? reward;

  /// Transaction ID corresponding to the ownership mint for the data source.
  String assetRef;

  ConsentModel(this.assetRef, this.destination, {this.about, this.reward});

  ConsentModel.fromMap(Map<String, dynamic> map) : 
    assetRef = map[ConsentRepository.columnAssetRef], 
    destination = TikiSdkDestination.fromJson(map[ConsentRepository.columnDestination]), 
    about = map[ConsentRepository.columnAbout], 
    reward = map[ConsentRepository.columnReward];
}