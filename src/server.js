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
    picker: "",
    accept: ""
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

                                            eventData.selectedDate = inputdate;

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

                //Date conversion to timezone
                var localtz = -(new Date()).getTimezoneOffset()/60
                //var startTime = convertDateFromToTimezone(event.startTime, event.timezone, localtz);
                //var endTime = convertDateFromToTimezone(event.endTime, event.timezone, localtz);

                jsonForPattern.started_at = event.startTime.getTime();
                jsonForPattern.ended_at = event.endTime.getTime();
                jsonForPattern.timezone = event.timezone;
                jsonForPattern.exrule = event.excrule;
                jsonForPattern.rrule = event.reprule;
                var patJsonString = JSON.stringify(jsonForPattern);

                console.log(jsonForPattern.started_at, jsonForPattern.ended_at)

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
    event.name = "";
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

const jsondata = JSON.parse('[{"offset": -11, "value": "(GMT-11:00) Pago Pago", "timezones": ["Pacific/Niue", "Pacific/Pago_Pago"]}, {"offset": -10, "value": "(GMT-10:00) Tahiti", "timezones": ["Pacific/Honolulu", "Pacific/Rarotonga", "Pacific/Tahiti"]}, {"offset": -9, "value": "(GMT-09:00) Gambier", "timezones": ["America/Anchorage", "Pacific/Gambier"]}, {"offset": -8, "value": "(GMT-08:00) Pitcairn", "timezones": ["America/Los_Angeles", "America/Tijuana", "America/Vancouver", "America/Whitehorse", "Pacific/Pitcairn"]}, {"offset": -7, "value": "(GMT-07:00) Mountain Time - Yellowknife", "timezones": ["America/Dawson_Creek", "America/Denver", "America/Edmonton", "America/Hermosillo", "America/Mazatlan", "America/Phoenix", "America/Yellowknife"]}, {"offset": -6, "value": "(GMT-06:00) Galapagos", "timezones": ["America/Belize", "America/Chicago", "America/Costa_Rica", "America/El_Salvador", "America/Guatemala", "America/Managua", "America/Mexico_City", "America/Regina", "America/Tegucigalpa", "America/Winnipeg", "Pacific/Galapagos"]}, {"offset": -5, "value": "(GMT-05:00) Easter Island", "timezones": ["America/Bogota", "America/Cancun", "America/Cayman", "America/Guayaquil", "America/Havana", "America/Iqaluit", "America/Jamaica", "America/Lima", "America/Nassau", "America/New_York", "America/Panama", "America/Port-au-Prince", "America/Rio_Branco", "America/Toronto", "Pacific/Easter"]}, {"offset": -3, "value": "(GMT-03:00) Stanley", "timezones": ["America/Asuncion", "America/Campo_Grande", "America/Cuiaba", "America/Araguaina", "America/Argentina/Buenos_Aires", "America/Bahia", "America/Belem", "America/Cayenne", "America/Fortaleza", "America/Godthab", "America/Maceio", "America/Miquelon", "America/Montevideo", "America/Paramaribo", "America/Recife", "America/Santiago", "Antarctica/Palmer", "Antarctica/Rothera", "Atlantic/Stanley"]}, {"offset": -4, "value": "(GMT-04:00) Bermuda", "timezones": ["America/Barbados", "America/Boa_Vista", "America/Curacao", "America/Grand_Turk", "America/Guyana", "America/Halifax", "America/La_Paz", "America/Manaus", "America/Martinique", "America/Port_of_Spain", "America/Porto_Velho", "America/Puerto_Rico", "America/Santo_Domingo", "America/Thule", "Atlantic/Bermuda"]}, {"offset": -2, "value": "(GMT-02:00) South Georgia", "timezones": ["America/Sao_Paulo", "America/Noronha", "Atlantic/South_Georgia"]}, {"offset": -1, "value": "(GMT-01:00) Cape Verde", "timezones": ["America/Scoresbysund", "Atlantic/Azores", "Atlantic/Cape_Verde"]}, {"offset": 0, "value": "(GMT+00:00) London", "timezones": ["Africa/Abidjan", "Africa/Accra", "Africa/Bissau", "Africa/Casablanca", "Africa/El_Aaiun", "Africa/Monrovia", "America/Danmarkshavn", "Atlantic/Canary", "Atlantic/Faroe", "Atlantic/Reykjavik", "Etc/GMT", "Europe/Dublin", "Europe/Lisbon", "Europe/London"]}, {"offset": 1, "value": "(GMT+01:00) Zurich", "timezones": ["Africa/Algiers", "Africa/Ceuta", "Africa/Lagos", "Africa/Ndjamena", "Africa/Tunis", "Europe/Amsterdam", "Europe/Andorra", "Europe/Belgrade", "Europe/Berlin", "Europe/Brussels", "Europe/Budapest", "Europe/Copenhagen", "Europe/Gibraltar", "Europe/Luxembourg", "Europe/Madrid", "Europe/Malta", "Europe/Monaco", "Europe/Oslo", "Europe/Paris", "Europe/Prague", "Europe/Rome", "Europe/Stockholm", "Europe/Tirane", "Europe/Vienna", "Europe/Warsaw", "Europe/Zurich"]}, {"offset": 2, "value": "(GMT+02:00) Vilnius", "timezones": ["Africa/Windhoek", "Africa/Cairo", "Africa/Johannesburg", "Africa/Maputo", "Africa/Tripoli", "Asia/Amman", "Asia/Beirut", "Asia/Damascus", "Asia/Gaza", "Asia/Jerusalem", "Asia/Nicosia", "Europe/Athens", "Europe/Bucharest", "Europe/Chisinau", "Europe/Helsinki", "Europe/Istanbul", "Europe/Kaliningrad", "Europe/Kiev", "Europe/Riga", "Europe/Sofia", "Europe/Tallinn", "Europe/Vilnius"]}, {"offset": 3, "value": "(GMT+03:00) Moscow+00 - Moscow", "timezones": ["Africa/Khartoum", "Africa/Nairobi", "Antarctica/Syowa", "Asia/Baghdad", "Asia/Qatar", "Asia/Riyadh", "Europe/Minsk", "Europe/Moscow"]}, {"offset": 4, "value": "(GMT+04:00) Reunion", "timezones": ["Asia/Baku", "Asia/Dubai", "Asia/Tbilisi", "Asia/Yerevan", "Europe/Samara", "Indian/Mahe", "Indian/Mauritius", "Indian/Reunion"]}, {"offset": 5, "value": "(GMT+05:00) Moscow+02 - Yekaterinburg", "timezones": ["Antarctica/Mawson", "Asia/Aqtau", "Asia/Aqtobe", "Asia/Ashgabat", "Asia/Dushanbe", "Asia/Karachi", "Asia/Tashkent", "Indian/Kerguelen", "Indian/Maldives", "Asia/Yekaterinburg"]}, {"offset": 6, "value": "(GMT+06:00) Moscow+03 - Omsk, Novosibirsk", "timezones": ["Antarctica/Vostok", "Asia/Almaty", "Asia/Bishkek", "Asia/Dhaka", "Asia/Thimphu", "Indian/Chagos", "Asia/Omsk"]}, {"offset": 7, "value": "(GMT+07:00) Christmas", "timezones": ["Antarctica/Davis", "Asia/Bangkok", "Asia/Hovd", "Asia/Jakarta", "Asia/Krasnoyarsk", "Asia/Saigon", "Asia/Ho_Chi_Minh", "Indian/Christmas"]}, {"offset": 8, "value": "(GMT+08:00) Singapore", "timezones": ["Antarctica/Casey", "Asia/Brunei", "Asia/Choibalsan", "Asia/Hong_Kong", "Asia/Irkutsk", "Asia/Kuala_Lumpur", "Asia/Macau", "Asia/Makassar", "Asia/Manila", "Asia/Shanghai", "Asia/Taipei", "Asia/Ulaanbaatar", "Australia/Perth", "Asia/Singapore"]}, {"offset": 9, "value": "(GMT+09:00) Moscow+06 - Yakutsk", "timezones": ["Asia/Dili", "Asia/Jayapura", "Asia/Seoul", "Asia/Tokyo", "Pacific/Palau", "Asia/Yakutsk"]}, {"offset": 10, "value": "(GMT+10:00) Moscow+07 - Vladivostok", "timezones": ["Antarctica/DumontDUrville", "Asia/Magadan", "Australia/Brisbane", "Pacific/Chuuk", "Pacific/Guam", "Pacific/Port_Moresby", "Asia/Vladivostok"]}, {"offset": 11, "value": "(GMT+11:00) Eastern Time - Melbourne, Sydney", "timezones": ["Australia/Hobart", "Pacific/Efate", "Pacific/Guadalcanal", "Pacific/Kosrae", "Pacific/Norfolk", "Pacific/Noumea", "Pacific/Pohnpei", "Australia/Sydney"]}, {"offset": 13, "value": "(GMT+13:00) Tongatapu", "timezones": ["Pacific/Auckland", "Pacific/Fiji", "Pacific/Enderbury", "Pacific/Fakaofo", "Pacific/Tongatapu"]}, {"offset": 12, "value": "(GMT+12:00) Moscow+09 - Petropavlovsk-Kamchatskiy", "timezones": ["Pacific/Funafuti", "Pacific/Kwajalein", "Pacific/Majuro", "Pacific/Nauru", "Pacific/Tarawa", "Pacific/Wake", "Pacific/Wallis", "Asia/Kamchatka"]}, {"offset": 14, "value": "(GMT+14:00) Kiritimati", "timezones": ["Pacific/Apia", "Pacific/Kiritimati"]}]');
var array = [];
var model = [];
for (var i = 0; i < jsondata.length; i++) {
    var element = jsondata[i];
    model[element.offset+11] = element.value
    array[element.offset+11] = element;
}

function getListOfTimezones() {
    return [model, array];
}

function getTimezoneIndex(value) {

    var defaultval = 0;

    for (var i = 0; i < array.length; i++) {

        var offset = array[i].offset.toString();
        if (offset === "0") {

            defaultval = i;

            if (value === "UTC") {
                return i;
            }
        }

        if (array[i].offset > 0) {
            offset = "+"+offset;
        }

        if (value === array[i].value || value === "GMT" + offset || value === array[i].offset) {
            return i;
        }

        for (var k in array[i].timezones) {
            if (value === array[i].timezones[k]) {
                return i;
            }
        }
    }

    return defaultval;
}

function getTimezoneStringFromOffset(offset) {
    return "GMT"+getStringOffset(offset);
}

function getTimezoneOffsetFromIndex(index) {
    return array[index].offset;
}

function getTimezoneOffset(value) {
    return getTimezoneOffsetFromIndex(getTimezoneIndex(value));
}

function getStringOffset(offset) {

    var offst = offset.toString();

    if (offset > 0) {
        offst = "+"+offst;
    } else if (offset === 0) {
        offst = "";
    }
    return offst
}

function getIntArray(size, ispad=true, offset=0) {
    var array = []
    for (var i = 0; i < size; i++) {array[i] = (ispad ? i.toString().padStart(2, "0") : i+offset);}
    return array
}

function convertDateFromToTimezone(date, timezoneFrom, timezoneTo) {

    var indexF = getTimezoneIndex(timezoneFrom);
    var indexT = getTimezoneIndex(timezoneTo);

    var ndate = new Date(date);
    ndate.setHours(ndate.getHours() - (array[indexF].offset - array[indexT].offset));
    return ndate
}

const types = {"Yearly": "YEARLY", "Monthly": "MONTHLY", "Weekly": "WEEKLY", "Daily": "DAILY", "Hourly":"HOURLY", "Never":""}
const formattypes = {"Yearly": "year", "Monthly": "month", "Weekly": "week", "Daily": "day", "Hourly":"hour", "Never":""}
function getRepeatTypes() {
    return Object.keys(types);
}

const monthes = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
function getMonthes() {
    return monthes;
}

const weekdaysarr = {"Monday": "MO", "Tuesday":"TU", "Wednesday":"WE", "Thursday":"TH", "Friday":"FR", "Saturday":"SA", "Sunday":"SU"}
function getWeeks() {
    var arrvdays = Object.values(weekdaysarr)

    var wdays = Object.values(weekdaysarr).join(",")
    arrvdays.push(wdays);

    var wweekdays = Object.values(weekdaysarr).slice(0, 5).join(",")
    arrvdays.push(wweekdays);

    var weekenddays = Object.values(weekdaysarr).slice(5, 7).join(",")
    arrvdays.push(weekenddays);

    var fullnames = Object.keys(weekdaysarr)
    fullnames.push("Day", "Weekday", "Weekend day")

    var narr = {}
    for (var i in fullnames) {
        narr[fullnames[i]] = arrvdays[i];
    }

    return [
        fullnames,
        arrvdays,
        narr
    ];
}

const ordinals = {"First": 1, "Second": 2, "Third":3, "Fourth": 4, "Last":-1}
function getOrdinals() {
    return Object.keys(ordinals)
}

function getEnding(number) {
    if (number === 1) {
       return "";
    }
    return "s";
}

function getOrdinalEnding(number) {
    if (number%100 - number%10 != 10) {
        switch (number%10) {
            case 1:
                return "st";
            case 2:
                return "nd";
            case 3:
                return "rd";
            default:
                return "th";
        }
    } else {
        return "th";
    }
}

function convertDate(date) {
  return date.getUTCFullYear() +
    (date.getUTCMonth() + 1).toString().padStart(2, "0") +
    date.getUTCDate().toString().padStart(2, "0") + 'T' +
    date.getUTCHours().toString().padStart(2, "0") +
    date.getUTCMinutes().toString().padStart(2, "0") +
    date.getUTCSeconds().toString().padStart(2, "0") +
    'Z';
};

function parseDate(isostr) {
    var year = Number(isostr.substring(0, 4));
    var month = Number(isostr.substring(4, 6))-1;
    var day = Number(isostr.substring(6, 8));
    var hour = Number(isostr.substring(9, 11));
    var minute = Number(isostr.substring(11, 13));
    var second = Number(isostr.substring(13, 15));
    var ndate = new Date(year, month, day, hour, minute, second)
    ndate.setHours(ndate.getHours() - (new Date).getTimezoneOffset()/60);
    return ndate;
}

function generateBuilderArray() {
    return {type:"", byday:[], bysetpos:"", bymonth:"", bymonthday:0, interval:0, count:0, until: 0}
}

function buildRRule(bArray) {

    var str = "FREQ="+types[bArray.type];

    if (bArray.type === "Never") return "";

    if (bArray.type === "Weekly") {
        str += ";BYDAY="
        var arr = [];
        for (var k in bArray.byday) {
            arr.push(getWeeks()[2][bArray.byday[k]]);
        }
        str += arr.join(",");
    }

    if (bArray.type === "Monthly") {
        if (bArray.bymonthday > 0) {
            str += ";BYMONTHDAY="+bArray.bymonthday;
        } else if (bArray.bysetpos) {
            str += ";BYSETPOS="+ordinals[bArray.bysetpos] + ";BYDAY="+getWeeks()[2][bArray.byday[0]];
        }
    }

    if (bArray.type === "Yearly") {
        if (bArray.bymonthday > 0) {

            str += ";BYMONTH=" + (monthes.indexOf(bArray.bymonth)+1);
            str += ";BYMONTHDAY="+bArray.bymonthday;

        } else if (bArray.bysetpos) {

            str += ";BYDAY="
            var darr = [];
            for (var s in bArray.byday) {
                darr.push(getWeeks()[2][bArray.byday[s]]);
            }
            str += darr.join(",");

            str += ";BYSETPOS="+ordinals[bArray.bysetpos] + ";BYMONTH=" + (monthes.indexOf(bArray.bymonth)+1);
        }
    }

    if (bArray.interval > 0) {
        str += ";INTERVAL="+Math.max(1, bArray.interval);
    }

    if (bArray.count > 0) {
        str += ";COUNT="+bArray.count;
    }

    if (bArray.until) {
        str += ";UNTIL="+convertDate(until);
    }

    return str;
}

function parseDays(str) {
    var days = str.split(",");
    for (var k in days) {
        days[k] = Object.keys(weekdaysarr)[Object.values(weekdaysarr).indexOf(days[k])];
    }
    return days;
}

const availableprops = {
    "FREQ": ["type", function(str) {return Object.keys(types)[Object.values(types).indexOf(str)]}],
    "BYDAY": ["byday", parseDays],
    "BYMONTHDAY": ["bymonthday", function(str) {return Number(str)}],
    "BYSETPOS": ["bysetpos", function(str) {return Object.keys(ordinals)[Object.values(ordinals).indexOf(Number(str))]}],
    "BYMONTH": ["bymonth", function(str) {return monthes[Number(str)-1]}],
    "INTERVAL": ["interval", function(str) {return Number(str)}],
    "COUNT": ["count", function(str) {return Number(str)}],
    "UNTIL": ["until", function(str) {return parseDate(str)}]
}

function convertRRuleToBuilderArray(rrule) {

    var arr = generateBuilderArray();
    var str = rrule;

    var whilestatement = true;
    while (whilestatement) {

        var indx = str.search("=");
        if (indx === -1) {
            whilestatement = false;
            break;
        }

        var prop = str.substring(0, indx);
        str = str.substring(indx+1);

        indx = str.search(";") >= 0 ? str.search(";") : str.length
        if (Object.keys(availableprops).indexOf(prop) === -1) {
            str = str.substring(0, indx);
            continue;
        }

        var value = str.substring(0, indx);
        str = str.substring(indx+1);

        arr[availableprops[prop][0]] = availableprops[prop][1](value);
    }

    if (!arr.type) {
        arr.type = Object.keys(types)[Object.values(types).indexOf("")];
    }

    if (arr.type === "Monthly" && arr.byday.length > 1) {
        switch (arr.byday.length) {
            case 2:
                arr.byday = ["Weekend day"];
                break;
            case 5:
                arr.byday = ["Weekday"];
                break;
            case 7:
                arr.byday = ["Day"];
                break;
            default:
                break;
        }
    }

    return arr
}

function convertRRuleToReadableString(rrule) {
    var arr = convertRRuleToBuilderArray(rrule)

    if (arr.type === "Never") {
        return "None";
    }

    var str = "Every ";

    if (arr.interval > 1) {
        str += arr.interval + " ";
    }

    if (arr.type === "Yearly") {
        arr.interval = 1;
    }

    str += formattypes[arr.type] + getEnding(arr.interval) + " ";

    if (arr.byday.length > 0 && !arr.bysetpos) {

        if (arr.byday.length === 7) {
            str += "every day ";
        } else if (arr.byday.length === 2 && arr.byday.indexOf("Saturday") >= 0 && arr.byday.indexOf("Sunday") >= 0) {
            str += "on weekend days";
        } else if (arr.byday.length === 5 && arr.byday.indexOf("Monday") >= 0 && arr.byday.indexOf("Tuesday") >= 0 && arr.byday.indexOf("Wednesday") >= 0 && arr.byday.indexOf("Thursday") >= 0  && arr.byday.indexOf("Friday") >= 0) {
            str += "on weekdays";
        } else {
            str += "on " + arr.byday.join(", ") + " ";
        }
    }

    if (arr.bysetpos) {
        str += "every " + arr.bysetpos.toLowerCase() + " " + arr.byday[0] + " of ";
        if (arr.type === "Monthly") {
            str += "month "
        } else {
            str += arr.bymonth + " ";
        }
    }

    if (arr.bymonthday > 0) {
        str += "on " + arr.bymonthday + getOrdinalEnding(arr.bymonthday) + " day of ";
        if (arr.type === "Monthly") {
            str += "month "
        } else {
            str += arr.bymonth + " ";
        }

    }

    if (arr.count > 0) {
        str += "for " + arr.count + " time" + getEnding(arr.count) + " "
    }

    if (arr.until !== 0) {
        var options = { year: 'numeric', month: 'long', day: 'numeric' };
        str += "until " + arr.until.toLocaleString(Qt.locale(), options);
    }

    return str;
}
