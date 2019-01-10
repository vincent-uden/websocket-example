// Opens a websocket to the server. The port can be whatever
// but should be different from the file serving port
// (9292 in Sinatra by default). I use 4567 as an example
let socket = new WebSocket("ws://localhost:4567");
// A unique identifier we'll get from the server
let myId = null;

// Is called everytime a message is recieved from the server
socket.onmessage = function(event) {
    // Get the message from the event object
    let contents = event.data;
    // Parse the string into a JSON object
    let jsonObj = JSON.parse(contents);
    console.log(jsonObj);

    // Check which action will be handled
    if (jsonObj.action == "connect") {
        console.log("Connected");
        // Save the id, otherwise the server wont
        // know who we are
        myId = jsonObj.id;
    }
    if (jsonObj.action == "inc") {
        // Find the counter
        let counter = document.getElementById("counter");
        // Set its text
        counter.textContent = jsonObj.number;
    }
}

// Is called when the connection has been established
socket.onopen = function(event) {
    sendMessage("connect");
}

// Wrapper function for sending a JSON object
// The JSON object has no requirements, I made up the 
// clientName and action variables
function sendMessage(action) {
    let obj = {
        clientName: "Test Client",
        action: action,
        id: myId
    };
    socket.send(JSON.stringify(obj));
}

function inc() {
    sendMessage("inc");
}