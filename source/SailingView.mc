using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.Timer;


class SailingView extends WatchUi.View {
    var mps_to_kts = 1.943844492;
    var m_to_nm = 0.000539957;
    var update_timer = null;
    var headingStr;    
    var _speed;
    var _maxspeed;

    function initialize() {
        System.println("Start position request");
        View.initialize();

         try {
            // code that might throw an exception
           
             // Enable the WHR or ANT HR sensor
            // FYI: if a Tempe is available it's data will be included in the .fit and seen on Garmin Connect
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE,Sensor.SENSOR_TEMPERATURE]);
            // add a listener (http://developer.garmin.com/connect-iq/programmers-guide/positioning-sensors/)
            //Sensor.enableSensorEvents( method( :onSensor ) );
            //System.println("Sensor rate : " + Sensor.getMaxSampleRate());
        }
        catch (ex) {
                Toybox.System.println(ex.getErrorMessage());
                ex.printStackTrace();
            
                // rethrow if you want to let it crash
                throw ex;
        }

        _maxspeed = 0;
        _speed = 0;

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, self.method(:onPosition));
        update_timer = new Timer.Timer();
        // onUpdate every 500ms
        update_timer.start(method(:refreshView), 500, true);
    }

    /*
     * FIT contributor for the whole session
     */
    function initializeFITsession() {
        System.println("initializeFITsession");
        
        // final values
        /*
        mSessTotalArrowField = mSession.createField(Ui.loadResource(Rez.Strings.archery_totalarrow),
            TOTAL_ARROWS_FIELD_ID, 
            FitContributor.DATA_TYPE_UINT32, 
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units=>Ui.loadResource(Rez.Strings.archery_unitarrow)}
            );
*/
    }

    function onPosition(info) {
        if (info == null || info.accuracy == null) {
            return;
        }

        if (info.accuracy != Position.QUALITY_GOOD) {
            return;
        }

        if ($.session == null) {
            System.println("Position usable. Start recording.");
            $.session = ActivityRecording.createSession({
                         :name=>"Sailing",
                         :sport=>ActivityRecording.SPORT_SAILING, // SPORT_SAILING 32                         
                        });

            initializeFITsession();

            $.session.start();
        }

        var heading = info.heading;
        headingStr = headingToStr(heading);
        var headingDeg = ((180 * heading ) /  Math.PI);
        if (headingDeg < 0) {
            headingDeg += 360;
        }
        headingStr += " - " + headingDeg.format("%d");
       //accuracy = info.accuracy;
        _speed = (info.speed * 1.943844492);
        _maxspeed = (_maxspeed < _speed ) ? _speed : _maxspeed;
        //System.println("speed "+ _speed + "(" + _maxspeed + ") heading : "+info.heading);
        
        //? Ui.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        return true;
    }

    function refreshView() {
        try {
            WatchUi.requestUpdate();
        } catch (ex) {
            System.println("Error.. Activity Info not available. " + ex.getErrorMessage());
        }
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        var height = dc.getHeight();
        var width = dc.getWidth();


        // Fill the entire background with Black.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, width, height);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        // battery info ?
        var battery = System.getSystemStats().battery;
        if (battery <= 30) {
            if (battery <= 10) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(width * 0.30 ,(height * 0.05), Graphics.FONT_MEDIUM, "B", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // heure
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var clockTime = System.getClockTime();
        var time = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");
        dc.drawText(width * 0.50 ,(height * 0.05), Graphics.FONT_MEDIUM, time, Graphics.TEXT_JUSTIFY_CENTER);

        try {
            if ($.session != null && $.session.isRecording()) {
                drawSailInfo(dc);
            }
        } catch (ex) {
            System.println("Error.. Activity Info not available. " + ex.getErrorMessage());
        }
    }

    function drawSailInfo(dc) {
        var height = dc.getHeight();
        var width = dc.getWidth();
        var activity = Activity.getActivityInfo();

        //TODO: draw a record icon
        //System.println("isRecording");
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(width * 0.7 ,(height * 0.10),  5);
		
        // Activity.Info maxSpeed in m/s
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        /*
        var maxSpeed = activity.maxSpeed;
        if (maxSpeed == null) { maxSpeed = 0; }
        maxSpeed = maxSpeed * mps_to_kts;
        maxSpeed = maxSpeed.format("%02.1f");
        */
        var maxSpeed = _maxspeed.format("%02.1f");
        dc.drawText(width * 0.88 ,(height * 0.43), Graphics.FONT_XTINY, maxSpeed, Graphics.TEXT_JUSTIFY_RIGHT);

        // Activity.Info currentSpeed in m/s
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        /*
        var speed = activity.currentSpeed;
        if (speed == null) { speed = 0; }
        var knots = (_speed * mps_to_kts).format("%02.1f");
        */
        var knots = _speed.format("%02.1f");
        dc.drawText(width * 0.70 ,(height * 0.30), Graphics.FONT_NUMBER_THAI_HOT, knots, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width * 0.90 ,(height * 0.57), Graphics.FONT_LARGE, "kts", Graphics.TEXT_JUSTIFY_VCENTER);

        //System.println("speed "+speed+" heading : "+headingStr );
        
        // Activity.Info elapsedDistance in meters
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var distance = activity.elapsedDistance;
        if (distance == null) { distance = 0; }
        distance = distance * m_to_nm;
        distance = distance.format("%02.2f");
        dc.drawText(width * 0.62, (height * 0.70), Graphics.FONT_TINY, distance, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width * 0.62, (height * 0.73), Graphics.FONT_XTINY, " nm", Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(width * 0.50, (height * 0.20), Graphics.FONT_MEDIUM, headingStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Activity.Info elapsedTime in ms
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timer = activity.elapsedTime;
        if (timer == null) { timer = 0; }
        timer = timer / 60 / 60 / 10;
        timer = (timer / 60).format("%02d") + ":" + (timer % 60).format("%02d");
        dc.drawText(width * 0.62, (height * 0.80), Graphics.FONT_TINY, timer, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width * 0.62, (height * 0.83), Graphics.FONT_XTINY, " h", Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }


function headingToStr(heading){
        var sixteenthPI = Math.PI / 16.0;
        if (heading < sixteenthPI and heading >= 0){
            return "N";
        }else if (heading < (3 * sixteenthPI)){ 
           return "NNE";
        }else if (heading < (5 * sixteenthPI)){ 
           return "NE";
        }else if (heading < (7 * sixteenthPI)){ 
           return "ENE";
        }else if (heading < (9 * sixteenthPI)){ 
           return "E";
        }else if (heading < (11 * sixteenthPI)){ 
           return "ESE";
        }else if (heading < (13 * sixteenthPI)){ 
           return "SE";
        }else if (heading < (15 * sixteenthPI)){ 
           return "SSE";
        }else if (heading < (17 * sixteenthPI)){ 
           return "S";
        }else if ((heading < 0 and heading > (15 * sixteenthPI) * -1)){ 
           return "SSW";
        }else if ((heading < 0 and heading > (14 * sixteenthPI) * -1)){ 
           return "SW";
        }else if ((heading < 0 and heading > (13 * sixteenthPI) * -1)){ 
           return "WSW";
        }else if ((heading < 0 and heading > (9 * sixteenthPI) * -1)){ 
           return "W";
        }else if ((heading < 0 and heading > (7 * sixteenthPI) * -1)){ 
           return "WNW";
        }else if ((heading < 0 and heading > (5 * sixteenthPI) * -1)){ 
           return "NW";
        }else if ((heading < 0 and heading > (3 * sixteenthPI) * -1)){ 
           return "NNW";
        }else {
            return "-";
        }
    }    
}
