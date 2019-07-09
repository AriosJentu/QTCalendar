const SERVER_LOCATION = "http://planner.skillmasters.ga/api/v1/";
const S_EVENTS = SERVER_LOCATION+"events";
const S_EVENT_ID = S_EVENTS+"/";
const S_INSTANCES = S_EVENTS+"/instances";
const S_PATTERNS = SERVER_LOCATION+"patterns";
const S_PATTERN_ID = S_PATTERNS+"/";
const AUTH_NAME = "X-Firebase-Auth";
const AUTH_TOKEN = "serega_mem";

const ICONS = {
    back: "",
    refresh: "",
    account: "",
    new_evt: "",
    remove_evt: "",
    map: "",
    save: "",
    today: "",
    edit_evt: "",
    share: "",
    picker: ""
}

function encodeQueryData(data) {
   const ret = [];
   for (let d in data)
     ret.push(encodeURIComponent(d) + '=' + encodeURIComponent(data[d]));
   return "?"+ret.join('&');
}

function getVisibilityForDate(inputdate, afterfunc, errorfunc) {

    afterfunc(0);
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
                console.log("Error in Event Instances GET Request");
                errorfunc(request);
            }
        }
    }

    request.open("GET", url);
    request.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    request.send();
}

function getEventsForDate(inputdate, updatefunc, errorfunc) {

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
        array = []
        updatefunc(array);

        if (request.readyState === 4) {
            if (request.status === 200) {

                var jsonData = JSON.parse(request.responseText).data;

                var identifs = [];
                var patrids = [];

                if (jsonData.length === 0) {
                    return;
                }

                for (let i = 0; i < jsonData.length; i++) {
                    identifs.push("id=" + jsonData[i].event_id);
                    patrids.push("id=" + jsonData[i].pattern_id);
                }

                var requestEvents = new XMLHttpRequest();
                var url = S_EVENTS+"?"+identifs.join("&");

                requestEvents.onreadystatechange = function() {
                    if (requestEvents.readyState === 4) {
                        if (requestEvents.status === 200) {

                            var jsonEventsData = JSON.parse(requestEvents.responseText).data;

                            var requestPattern = new XMLHttpRequest();
                            var paturl = S_PATTERNS+"?"+patrids.join("&");

                            requestPattern.onreadystatechange = function() {

                                if (requestPattern.readyState === 4) {
                                    if (requestPattern.status === 200) {

                                        var jsonPatternData = JSON.parse(requestPattern.responseText).data;

                                        for (let i = 0; i < jsonPatternData.length; i++) {

                                            var eventElement = jsonEventsData[i];
                                            var patternElement = jsonPatternData[i];
                                            var eventInstElement = jsonData[i];

                                            var starttime = Number(eventInstElement.started_at);
                                            var endtime = Number(eventInstElement.ended_at);

                                            var eventData = {};

                                            eventData.id = eventElement.id;
                                            eventData.patrnid = patternElement.id;

                                            eventData.startTime = new Date(starttime);
                                            eventData.endTime = new Date(endtime);

                                            eventData.name = eventElement.name;
                                            eventData.details = eventElement.details;
                                            eventData.owner = eventElement.owner_id;
                                            eventData.location = eventElement.location;
                                            eventData.status = eventElement.status;

                                            eventData.excrule = patternElement.exrule;
                                            eventData.reprule = patternElement.rrule;
                                            eventData.timezone = patternElement.timezone;

                                            array.push(eventData);
                                            updatefunc(array);

                                        }


                                    } else {

                                        console.log("Error in Event Patterns GET Request");
                                        errorfunc(request);
                                    }
                                }
                            }

                            requestPattern.open("GET", paturl);
                            requestPattern.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
                            requestPattern.send()


                        } else {

                            console.log("Error in Event Elements GET Request");
                            errorfunc(request);
                        }
                    }
                }

                requestEvents.open("GET", url);
                requestEvents.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
                requestEvents.send()

            } else {
                console.log("Error in Event Instances GET Request");
                errorfunc(request);
            }
        }
    }

    request.open("GET", url);
    request.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    request.send();
}

function postEventToServer(event, afterfunc, errorfunc, evtupdate = false) {

    var evturl = S_EVENTS;
    var type = "POST";
    if (evtupdate) {
        evturl = S_EVENT_ID+event.id;
        type = "PATCH";
    }

    var jsonForEvent = {};
    jsonForEvent.details = event.details;
    jsonForEvent.location = event.location;
    jsonForEvent.name = event.name;
    jsonForEvent.status = "";
    var evtJsonString = JSON.stringify(jsonForEvent);

    var requestEvent = new XMLHttpRequest();

    requestEvent.onreadystatechange = function() {

        if (requestEvent.readyState === 4) {
            if (requestEvent.status === 200) {

                var createdEventID = JSON.parse(requestEvent.responseText).data[0].id;

                var jsonForPattern = {}
                jsonForPattern.started_at = event.startTime.getTime();
                jsonForPattern.ended_at = event.endTime.getTime();
                jsonForPattern.timezone = event.timezone;
                jsonForPattern.exrule = event.excrule;
                jsonForPattern.rrule = event.reprule;
                var patJsonString = JSON.stringify(jsonForPattern);

                var url = S_PATTERNS+encodeQueryData({"event_id": createdEventID});
                if (evtupdate) {
                    url = S_PATTERN_ID+event.patrnid;
                }

                var requestPattern = new XMLHttpRequest();

                requestPattern.onreadystatechange = function() {

                    if (requestPattern.readyState === 4) {
                        if (requestPattern.status === 200) {
                            afterfunc();
                        } else {
                            console.log("Error in Pattern "+ type +" Request");
                            errorfunc(requestPattern);
                        }
                    }
                }

                console.log(patJsonString);

                console.log(url);
                requestPattern.open(type, url);
                requestPattern.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
                requestPattern.setRequestHeader("Content-Type", "application/json");
                requestPattern.send(patJsonString);

            } else {
                console.log("Error in Event "+ type +" Request");
                errorfunc(requestEvent);
            }
        }
    }


    requestEvent.open(type, evturl);
    requestEvent.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    requestEvent.setRequestHeader("Content-Type", "application/json");
    requestEvent.send(evtJsonString);
}

function deleteEventFromServer(event, afterfunc, errorfunc) {

    var request = new XMLHttpRequest();

    request.onreadystatechange = function() {

        if (request.readyState === 4) {
            if (request.status === 200) {
                afterfunc();
            } else {
                console.log("Error in Event DELETE Request");
                errorfunc(request);
            }
        }

    }

    request.open("DELETE", S_EVENT_ID+event.id);
    request.setRequestHeader(AUTH_NAME, AUTH_TOKEN);
    request.send();

}

function generateEmptyEvent() {

    var event = {};

    event.startTime = 0;
    event.endTime = 0;
    event.name = "Empty";
    event.details = "";
    event.owner = "";
    event.location = "";

    event.excrule = "";
    event.reprule = "";
    event.timezone = "";

    return event;
}

function generateRandomEvent(inputdate) {

    var event = {};

    var randstart = Math.floor(Math.random()*23);
    var randend = Math.floor(Math.random()*(23-randstart)) + randstart;

    var date = inputdate;
    date.setHours(randstart, 0, 0, 0);
    var start = date.getTime();
    date.setHours(randend, 59, 59, 999);
    var ends = date.getTime();

    event.startTime = new Date(start);
    event.endTime = new Date(ends);
    event.name = "[AJ] Test Event With Random Number " + Math.floor(Math.random()*1500);
    event.details = "[AJ] Test Event Details With Random Number " + Math.floor(Math.random()*1500);
    event.owner = "AriosJentu";
    event.location = "Vladivostok";

    event.excrule = "";
    event.reprule = "";
    event.timezone = "UTC";

    return event;
}

function generateUpdateForEvent(event) {

    event.name = "[AJ] Test Update Event With Random Number " + Math.floor(Math.random()*1500);
    event.details = "[AJ] Test Update Event Details With Random Number " + Math.floor(Math.random()*1500);

    return event;
}

function basicErrorFunc(request) {
    console.log("HTTP Request failed", request.readyState, request.status);
}
