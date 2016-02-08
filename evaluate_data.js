// Script for identifying objects in "speed up/slow down" interactions
Array.prototype.average = function () {
    var sum = 0, j = 0; 
   for (var i = 0; i < this.length, isFinite(this[i]); i++) { 
          sum += parseFloat(this[i]); ++j; 
    } 
   return j ? sum / j : 0; 
}

Array.prototype.sum = Array.prototype.sum || function() {
  return this.reduce(function(sum, a) { return sum + Number(a) }, 0);
}
//====================================

var plotly = require('plotly')("hspindell","obeoge4ez8")
var Parse = require('parse/node');

PARSE_APP_ID="ZVDFIiZs7dvGqL8eRaKT0mdNMxCwMCzaiTu2yVlO"
PARSE_CLIENT_KEY="GaGy7ZngizyPHSVVbFy0Q5spus9SJD33NKivzP4m"

PARSE_APP_ID_DEV="fEzVacO5gJMMaZBveiq5WWacZhqacHX6lw3CimcB"
PARSE_CLIENT_KEY_DEV="XapgjW7Twg14nZD31MMrm8T0Jy0MXmaOqckyuPOV"

var args = process.argv.slice(2);

if (args.length < 1) {
  console.log("Insufficient input arguments\nusage: node evaluate_data.js <dev/prod>\n");
  return;
} else if (args[0] == "prod") {
  Parse.initialize(PARSE_APP_ID, PARSE_CLIENT_KEY);
} else {
  Parse.initialize(PARSE_APP_ID_DEV, PARSE_CLIENT_KEY_DEV);
}

var DataEvent = Parse.Object.extend("DataEvent");
var LocationUpdate = Parse.Object.extend("LocationUpdate");
var WorldObject = Parse.Object.extend("WorldObject");

// ===========================================================
var CLUSTER_DISTANCE = 0.01; // miles

var query = new Parse.Query(DataEvent);
var interactionTitle = "Find fire_hydrant"
// query.ascending("updatedAt");
// query.equalTo("interaction", interactionTitle);
var dataEventId = "ja5rHDFNyG";
var experienceId = "ZgVEYsAmo4";
var dataLabel;

query.equalTo("objectId", dataEventId);


query.find({
  success:function(dataEvents) {
    for (var i=0; i<dataEvents.length; i++) {
      experience = dataEvents[0].get("experience");
      dataLabel = dataEvents[0].get("label");
      
      var dataQuery = new Parse.Query(LocationUpdate);
      dataQuery.equalTo("experience", dataEvents[i].get("experience"));
      dataQuery.greaterThan("createdAt", dataEvents[i].get("startDate"));
      dataQuery.lessThan("createdAt", dataEvents[i].get("endDate"));
      dataQuery.limit(1000);
      dataQuery.ascending("createdAt");
      
      dataQuery.find({
        success:function(locationUpdates) {
          console.log("\nFound " + locationUpdates.length + " updates for data event");
          times = [];
          accels = [];
          speeds = [];
          
          if(locationUpdates.length < 20){
            return;
          }
          
          lastSpeed = locationUpdates[0].get("speed");
          lastTime = locationUpdates[0].get("createdAt");
          
          times.push(getTimeString(lastTime));
          accels.push(0);
          speeds.push(lastSpeed);
          
          for (var j=1; j<locationUpdates.length; j++) {
            speed = locationUpdates[j].get("speed");
            time = locationUpdates[j].get("createdAt");
            
            deltaS = speed - lastSpeed;
            deltaT = time - lastTime;
            accel = 1000*deltaS/deltaT
            
            console.log("accel: " + accel);

            lastSpeed = speed;
            lastTime = time;
            
            times.push(getTimeString(time));
            accels.push(accel);
            speeds.push(speed);
          }

          var candidateIdx = findSlowdownPoint(times,accels,speeds,locationUpdates);
          if (candidateIdx != -1) {
            console.log("Found WorldObject candidate...");
            var candidateLocation = locationUpdates[candidateIdx].get("location");
            plotSpeedOverTime(times,accels,speeds, candidateIdx, experienceId,interactionTitle);
            saveWorldObject(candidateLocation,dataLabel,CLUSTER_DISTANCE,experienceId, interactionTitle);
          } else {
            console.log("Did not find WorldObject candidate from this DataEvent.");
          }
        }
      })
    }
  }
});

function getTimeString(d){
  seconds = d.getSeconds();
  minutes = d.getMinutes();
  hour = d.getHours();
  milliSeconds = d.getMilliseconds();
  
  return [hour,minutes,seconds,milliSeconds].join(':')
}


function findSlowdownPoint(times, accels, speeds, locationUpdates){
  // TODO fake-extend data to allow for more windows
  // 3 seconds is 4 data points
  var intervalSize = 2;
  var intervalAvgSpeeds = [];
  
  var lastIntervalSum = speeds.slice(0,intervalSize).sum();
  intervalAvgSpeeds.push(lastIntervalSum/intervalSize);
  for(var i=1; i<(locationUpdates.length + 1 - intervalSize); i++) {
    var intervalSum = lastIntervalSum - speeds[i-1] + speeds[i+intervalSize-1];
    intervalAvgSpeeds.push(intervalSum/intervalSize);
    lastIntervalSum = intervalSum;
  }

  var slowedDownLastInterval = false;
  for(var i=1;i<intervalAvgSpeeds.length;i++) {
    // if runner is going faster or equal speed as last interval
    if( (intervalAvgSpeeds[i] - intervalAvgSpeeds[i-1]) >= -0.) {
      slowedDownLastInterval = false;
    } else if (slowedDownLastInterval == false) { // if runner has slowed down now but hadn't slowed down previously
      slowedDownLastInterval = true;
    } else { // if runner has slowed down two intervals in a row
      console.log("Slowed down two intervals in a row");
      console.log(i-1);
      console.log(intervalAvgSpeeds[i-1]);
      // i-1 was the first index we noticed a decrease
      return i-1;
    }
  }
  return -1;
}

function saveWorldObject(candidateLocation, dataLabel, clusterDistance, experienceId, interactionTitle) {
  var worldObjectQuery = new Parse.Query(WorldObject);
  // query WorldObject for object in very close proximity
  worldObjectQuery.withinMiles("location", candidateLocation, clusterDistance);
  worldObjectQuery.equalTo("label", dataLabel);
  worldObjectQuery.find({
    success: function(worldObjects) {
      if(worldObjects.length == 0) {
        var worldObject = new WorldObject();
        worldObject.set("label", dataLabel);
        worldObject.set("location", candidateLocation);
        worldObject.set("experience", experienceId);
        worldObject.set("interaction", interactionTitle);
        worldObject.set("verified", false);
        worldObject.save(null, {
          success: function(worldObject) {
            console.log('New WorldObject created with objectId: ' + worldObject.id);
          },
          error: function(worldObject, error) {
            console.log('Failed to create new WorldObject, with error code: ' + error.message);
          }
        });
      } else {
        console.log("Did not save new WorldObject: Object with same label and close location already exists");
      }
    },
    error: function(error) {
      console.log("Error: " + error.code + " " + error.message);
    }
  });
}

function plotSpeedOverTime(times, accels, speeds, objectIdx, experienceId, interactionTitle){
  // graph acceleration over time
  var accelLine = {
    x: times,
    y: accels,
    type: 'line',
    name: "acceleration (m/s/s)",
  };
  
  var speedLine = {
    x: times,
    y: speeds,
    type: 'line',
    name: "speed (m/s)",
  };
  
  var objectLine = {
    x: [times[objectIdx],times[objectIdx]],
    y: [accels[objectIdx], speeds[objectIdx]],
    mode: "markers",
    type: 'scatter',
    name: "object presence",
  };
  
  var data = [accelLine, speedLine, objectLine];
  var fname = interactionTitle + "_" + experienceId;
  
  // TODO for filename, use experienceID-interaction combo
  var layout = {
    title: interactionTitle + " (Exp. " + experienceId + ")",
    xaxis: {
      title:"timestamp",
      titlefont: {
        family: "Courier New, monospace",
        size: 18,
        color: "#7f7f7f"
      }
    }
  };
  var graphOptions = {layout: layout, filename: fname, fileopt: "overwrite"};
  plotly.plot(data, graphOptions, function (err, msg) {
  	if (err) return console.log(err);
  	console.log(msg);
  });
}
