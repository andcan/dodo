import 'dart:html';
import 'package:polymer/polymer.dart';

const String ELEMENT_NAME = 'menu-bar';
const String ITEM_CONTAINER = '${ELEMENT_NAME}-item-container';
/**
 * 
 */
@CustomTag(ELEMENT_NAME)
class MenuBar extends PolymerElement {
  
  
  UListElement item_container;  
  

  MenuBar.created() : super.created() {
  }
  
  void enteredView () {
    super.enteredView();
    item_container = $['#${ITEM_CONTAINER}'];
  }
}

