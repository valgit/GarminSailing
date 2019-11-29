using Toybox.WatchUi;
using Toybox.System;

class SailingMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :wind) {
            System.println("set wind direction");
        } else if (item == :item_2) {
            System.println("item 2");
        }
    }

}