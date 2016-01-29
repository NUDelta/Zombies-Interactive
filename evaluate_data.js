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

var plotly = require('plotly')("hspindell","obeoge4ez8")

var DataEvent = Parse.Object.extend("DataEvent");
var LocationUpdate = Parse.Object.extend("LocationUpdate");

var query = new Parse.Query(DataEvent);
query.ascending("updatedAt");
query.equalTo("interaction", "Find stop_sign");
// query.limit(10); // TODO remove eventually

query.find({
  success:function(dataEvents) {
    for (var i=0; i<dataEvents.length; i++) {
      
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
          
          if(locationUpdates.length <= 10){
            return;
          }
          lastSpeed = locationUpdates[0].get("speed");
          lastTime = locationUpdates[0].get("createdAt");
          
          times.push(lastTime);
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
            
            times.push(time);
            accels.push(accel);
            speeds.push(speed);
          }
          
          // graph acceleration over time
          var accelLine = {
            x: times,
            y: accels,
            type: 'line',
            name: "'acceleration'",
          };
          
          var speedLine = {
            x: times,
            y: speeds,
            type: 'line',
            name: "'speed'",
          };
          
          var data = [speeds, lines];
          var layout = {fileopt : "overwrite", filename : "simple-node-example"};

          plotly.plot(data, layout, function (err, msg) {
          	if (err) return console.log(err);
          	console.log(msg);
          });
          
          
          // use algorithm to find index i of accel change
          // var candidateLocation = locationUpdates[i].get("location");
          
          // save dataEvent.get("dataLabel") at candidateLocation
          
        }
      })
    }
  }
});
// for each dataEvent in dataEvents

  // query all LocationUpdates between dataEvent.startDate and dataEvent.endDate

  // for each locationUpdate in locationUpdates
    // print location
    // print speed


    // save these pairs and graph them? (Plotly)
    // time, lat, lon, speed
    // any way to see location on a map as well (or a reason to)?

