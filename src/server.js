const SERVER_LOCATION = "http://planner.skillmasters.ga/api/v1/";
const S_EVENTS = SERVER_LOCATION+"events";
const S_EVENT_ID = S_EVENTS+"/";
const S_INSTANCES = S_EVENTS+"/instances";
const S_PATTERNS = SERVER_LOCATION+"patterns";
const AUTH_NAME = "X-Firebase-Auth";
const AUTH_TOKEN = "serega_mem";

function encodeQueryData(data) {
   const ret = [];
   for (let d in data)
     ret.push(encodeURIComponent(d) + '=' + encodeURIComponent(data[d]));
   return "?"+ret.join('&');
}

function getVisibilityForDate(inputdate, afterfunc) {

    var request = new XMLHttpRequest();

    var date = inputdate;
    date.setHours(0, 0, 0, 0);
    var start = date.getTime();
    date.setHours(23, 59, 59, 999);
    var ends = date.getTime();

    var dat = encodeQueryData({"from": start, "to": ends});
    var url = S_INSTANCES+dat;

    request.onreadystatechange = function() {
        if (request.readyState === 4) {
            if (request.status === 200) {
                var jsonRes = JSON.parse(request.responseText);
                afterfunc(jsonRes.count);
            } else {
                console.log("HTTP Request failed", request.status);
            }
        }
    }

    request.open("GET", url);
    request.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    request.send();
}

function getEventsForDate(inputdate, updatefunc) {

    var array = [];
    updatefunc(array);

    var request = new XMLHttpRequest();

    var date = inputdate;
    date.setHours(0, 0, 0, 0);
    var start = date.getTime();
    date.setHours(23, 59, 59, 999);
    var ends = date.getTime();

    var dat = encodeQueryData({"from": start, "to": ends});
    var url = S_INSTANCES+dat;

    request.onreadystatechange = function() {
        updatefunc(array);

        if (request.readyState === 4) {
            if (request.status === 200) {

                var jsonData = JSON.parse(request.responseText).data;

                for (var i = 0; i < jsonData.length; i++) {

                    var element = jsonData[i];

                    var dataArray = {};
                    var starttime = Number(element.started_at);
                    var endtime = Number(element.ended_at);

                    dataArray.id = element.event_id;
                    dataArray.patrnid = element.pattern_id;
                    dataArray.startTime = new Date(starttime);
                    dataArray.endTime = new Date(endtime);

                    var nrequest = new XMLHttpRequest();
                    var nurl = S_EVENT_ID+dataArray.id;

                    nrequest.onreadystatechange = function() {
                        if (nrequest.readyState === 4) {
                            if (nrequest.status === 200) {

                                var njsonData = JSON.parse(nrequest.responseText).data[0];

                                dataArray.name = njsonData.name;
                                dataArray.details = njsonData.details;
                                dataArray.owner = njsonData.owner_id;
                                dataArray.location = njsonData.location;

                                if (!(dataArray in array)) {
                                    array.push(dataArray);
                                }

                                updatefunc(array);
                            }
                        }
                    }

                    nrequest.open("GET", nurl);
                    nrequest.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
                    nrequest.send();

                }
            } else {
                console.log("HTTP Request failed", request.readyState, request.status);
            }
        }
    }

    request.open("GET", url);
    request.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    request.send();

}
