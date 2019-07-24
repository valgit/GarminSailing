using Toybox.WatchUi;

class SailingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
//        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailingMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

   // Handle the back action    
    function onBack() {     
        //System.println("onBack");
		// return false so that the InputDelegate method gets called. this will
        // allow us to know what kind of input cause the back behavior
        //return false;  // allow InputDelegate function to be called
        return true; // disable onBack
    }
    
	// Key pressed
    function onKey(key) {
    	//System.println("onKey : " + key);
    	/* maybe better ?
       	if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) {
            return onSelect();
        }
        */
        if (key.getKey() == WatchUi.KEY_ENTER) {            
            //System.println("Key pressed: ENTER");            
            // Pass the input to the controller
        	//mController.onStartStop();
        	WatchUi.pushView(new Rez.Menus.MainMenu(), new sailingMenuDelegate(), WatchUi.SLIDE_UP);
            return true;
        }
        // KEY_LAP KEY_START
        //System.println("Key pressed: " + key.getKey() );
        // next = 8
        // prev = 13
        return false; // allow InputDelegate function to be called
    }
}

/**
 * prepare the exit
 */
class sailingMenuDelegate extends WatchUi.MenuInputDelegate {

    // Constructor
    function initialize() {
        MenuInputDelegate.initialize();        
    }

    // Handle the menu input
    function onMenuItem(item) {
        if (item == :resume) {
        	System.println("resume");            
            return true;
        } else if (item == :save) {
            //mController.save();
            //TODO: better
            if ($.session != null && $.session.isRecording()) {
                $.session.stop();
                //mSessAvgTimePerEndField.setData(_maxspeed);                
                $.session.save();
                $.session = null;
                System.println("Session saved");
                System.exit();
            }            
            return true;
        } else { 
            //TODO: better
            if ($.session != null && $.session.isRecording()) {
                $.session.stop();
                $.session.discard();
                $.session = null;
                System.println("Session discard");
                System.exit();
            }                      
            return true;
        }
        return false;
    }


}