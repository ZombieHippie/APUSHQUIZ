var http = require('http'),
    WebSocketServer = require('ws').Server,
    wss = new WebSocketServer({port: 238});

var clients = [];
var date = new Date();

var currentQuestion = 0;
var question = "q::What do we associate with Jay's Treaty and John Jay himself?::The Gettysburg Address::The 50'45 or Fight::Could make his way to Georgia by the light of torches leading the way::XYZ Affairs::3";

wss.on('connection', function (ws) {
    //// Initialize Client
    console.log(date.getDate() +" - "+ date.getHours() +":"+ date.getMinutes() + " A client has connected");
    ws.send(question, function () { /* ignore errors */ });
    for (var i = 0; i < clients.length; i++) {
        clients[i].send("s::Another quizzer joined!");
    }
    clients.push(ws);
    ws.send("s::Now there are " + clients.length + " quizzers connected");

    //// Events
    ws.on('close', function (ws) {
        var whoToSplice = -1;
        for (var i = 0; i < clients.length; i++) {
            if (clients[i].readyState == 3) {
                whoToSplice = i;
            }
        }
        if (whoToSplice != -1) {
            clients.splice(whoToSplice, 1);
            console.log(date.getDate() +" - "+ date.getHours() +":"+ date.getMinutes() + "Removed a client from server");
            for (var i = 0; i < clients.length; i++) {
                clients[i].send("s::A quizzer dropped out");
            }
        }
    });
    ws.onmessage = function (message) {
        currentQuestion++;
        var fs = require('fs');
        var qs = fs.readFileSync('f/allquestions.txt').toString().split("\n");
        if (currentQuestion >= qs.length) {
            currentQuestion = 0;
        }
        question = qs[currentQuestion];
        for (var i = 0; i < clients.length; i++) {
            clients[i].send(question, function () { /* ignore errors */ });
        }
    }
});

/*
What do we associate with Jay's Treaty and John Jay himself?

1. The Gettysburg Address
2. The 50'45 or Fight
3. Could make his way to Georgia by the light of torches leading the way
4. XYZ Affairs
*/