// Script for identifying objects in "speed up/slow down" interactions
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

var query = new Parse.Query(DataEvent);
var interaction = "Find stop_sign"
// query.ascending("updatedAt");
// query.equalTo("interaction", interaction);
var dataEventId = "askFhUnedq";
var experienceId;
var dataLabel;

query.equalTo("objectId", "askFhUnedq");

query.find({
  success:function(dataEvents) {
    for (var i=0; i<dataEvents.length; i++) {
      experience = dataEvents[0].get("experience");
      dataLabel = dataEvents[0].get("dataLabel");
      
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
          
          if(locationUpdates.length < 22){
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
          
          var data = [accelLine, speedLine];
          var fname = interaction + "_" + locationUpdates[0].get("experience").id;
          // TODO for filename, use experienceID-interaction combo
          var layout = {
            title: interaction + " (Exp. " + locationUpdates[0].get("experience").id + ")",
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
          
          //TODO
          // var CLUSTER_DISTANCE = 0.01; // miles
          // // use algorithm to find index i of accel change
          // var candidateIdx = 0;
          // var candidateLocation = locationUpdates[candidateIdx].get("location");
          //
          // var worldObjectQuery = new Parse.Query(WorldObject);
          // // query WorldObject for object in very close proximity
          // worldObjectQuery.withinMiles("location", candidateLocation, CLUSTER_DISTANCE);
          // worldObjectQuery.equalTo("dataLabel", dataLabel);
          //
          // // FIXME will there be scope issues with the variables used, such as candidateLocation?
          // worldObjectQuery.find({
          //   success: function(worldObjects) {
          //     if(worldObjects.length == 0) {
          //       var worldObject = new WorldObject();
          //       worldObject.set("location", candidateLocation);
          //       worldObject.set("experience", experience);
          //       worldObject.set("interaction", interaction);
          //       worldObject.set("verified", false);
          //       worldObject.save(null, {
          //         success: function(worldObject) {
          //           alert('New WorldObject created with objectId: ' + worldObject.id);
          //         },
          //         error: function(worldObject, error) {
          //           alert('Failed to create new WorldObject, with error code: ' + error.message);
          //         }
          //       });
          //     }
          //   },
          //   error: function(error) {
          //     alert("Error: " + error.code + " " + error.message);
          //   }
          // });
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
// for each dataEvent in dataEvents

  // query all LocationUpdates between dataEvent.startDate and dataEvent.endDate

  // for each locationUpdate in locationUpdates
    // print location
    // print speed


    // save these pairs and graph them? (Plotly)
    // time, lat, lon, speed
    // any way to see location on a map as well (or a reason to)?

