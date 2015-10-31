var speed = 0;
var fuel = props.globals.getNode("consumables/fuel/tank/level-m3");
var fuel_lev = 0;
var cranking = props.globals.getNode("engines/engine/cranking");
var running = props.globals.getNode("/engines/engine/running");
var gear = props.globals.getNode("/engines/engine/gear");
var clutch = props.globals.getNode("/engines/engine/clutch");
var rpm = props.globals.getNode("/engines/engine/rpm");
var throttle = props.globals.getNode("/engines/engine/throttle");
var rev_throttle = props.globals.getNode("/engines/engine/rev_throttle");
var elevator = props.globals.getNode("/controls/flight/elevator");
var wiper = props.globals.getNode("/controls/wiper/deg");
var wiper_deg = 0;
var k = 0;
var turn_sec = 0;
var gear_prev = 0;
var mbrake = 0;
var tbrake = 0;

var loop = func {

	if (gear_prev != gear.getValue()) {
	 if (clutch.getValue() == 1) {
	  gear_prev = gear.getValue();
	  gui.popupTip(sprintf("Gear: %d", gear_prev));
	 } else {gear.setValue(gear_prev)}
	}




      if (elevator.getValue() < 0) {elevator.setValue(0);}
      speed = getprop("velocities/groundspeed-kt");

     if ((gear.getValue() == 0) or (clutch.getValue() == 1)) {
	 k = 0;
	 if (running.getValue() == 1) {rpm.setValue(400+3100*elevator.getValue())} else {rpm.setValue(0)};
      }
	else if (gear.getValue() == 1) {
	 k = 198;
	 rpm.setValue(k*speed);
      }
	else if (gear.getValue() == 2) {
       k =  69;
	 rpm.setValue(k*speed);
	}

	
	if ((gear.getValue() > 1) and (rpm.getValue() < 300) and (clutch.getValue() == 0)) {
	 running.setValue(0);
	}
	
	if ((running.getValue() == 1) and (gear.getValue() > 0)) { 
	 throttle.setValue(1.25*elevator.getValue()+0.1-rpm.getValue()/3100);
	} else throttle.setValue(0);

	if ((cranking.getValue() == 1) and (running.getValue() == 1)){
	 running.setValue(0);
	 cranking.setValue(0);
	}
	
	if ((cranking.getValue() == 1) and ((gear.getValue() == 0) or (clutch.getValue == 1)) and (fuel.getValue()>=0.00000129)) {
	 running.setValue(1);	 
	 cranking.setValue(0);
	}


	if (running.getValue() == 1) {
	 if (fuel.getValue() < 0.00000129) {
	  running.setValue(0);
	  }
	 else {
	  fuel_lev = fuel.getValue();
	  fuel.setValue(fuel_lev - (0.9*elevator.getValue()+0.1)*0.00000129);
	 }
	}

	if (running.getValue() == 1) {
	 if (gear.getValue() == -1) {
	  rpm.setValue(270*speed);
	  rev_throttle.setValue(0.9*elevator.getValue()+0.1-rpm.getValue()/3100);
	 } else rev_throttle.setValue(0);
	} else rev_throttle.setValue(0);
		
	cranking.setValue(0);


	turn_sec = turn_sec + 0.1;

	if ((turn_sec > 0.5) and ((getprop("controls/lighting/alarm") == 1) or (getprop("controls/lighting/turn") == -1))) {
	 setprop("controls/lighting/left_turn", 1)}
	else {setprop("controls/lighting/left_turn", 0)};

	if ((turn_sec > 0.5) and ((getprop("controls/lighting/alarm") == 1) or (getprop("controls/lighting/turn") == 1))) {
	 setprop("controls/lighting/right_turn", 1)}
	else {setprop("controls/lighting/right_turn", 0)};
	
	if (turn_sec > 1) {turn_sec = 0};
	
	if (getprop("/controls/gear/screen") == 0) {
	 wiper_deg = getprop("/controls/wiper/factor")*9+wiper_deg;
	 if (wiper_deg <= 90) {wiper.setValue(wiper_deg)} else {wiper.setValue(180-wiper_deg)};
	 if (wiper_deg >= 180) {wiper_deg = 0};
	}

	if ((getprop("/devices/status/keyboard/event/key") == 104) and (getprop("/devices/status/keyboard/event/pressed") == 1)) {
	 setprop("/controls/horn/horn", 1);
	} else {setprop ("/controls/horn/horn", 0)}

	mbrake = rpm.getValue()/3100-(1.0*elevator.getValue()+0.25*running.getValue());
	tbrake =  getprop("/controls/gear/brake-right");
	if ((gear.getValue() != 0) and (getprop("/gear/gear/rollspeed-ms") != 0) and (clutch.getValue() == 0) and (tbrake < mbrake)) {setprop("/engines/engine/rev_throttle", mbrake)}
	else {setprop("/controls/gear/brake-left", tbrake)};

  	if (gear.getValue() == 1) {
	 setprop("/controls/gearstick-x", -12);
	 setprop("/controls/gearstick-y", 0);
	}
      if (gear.getValue() == 2) {
	 setprop("/controls/gearstick-x", 12);
	 setprop("/controls/gearstick-y", 0);
	}
	if (gear.getValue() == -1) {
	 setprop("/controls/gearstick-x", 0);
	 setprop("/controls/gearstick-y", -18);
	}
	if (gear.getValue() == 0) {
	 setprop("/controls/gearstick-x", 0);
	 setprop("/controls/gearstick-y", 0);
	}	 
	
	settimer (loop, 0.1, 1);
}

loop();
aircraft.livery.init("Aircraft/FordT-flatbed/Models/Liveries", "sim/model/livery/name");
