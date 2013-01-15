# Client questionaire

$ = Zepto

connection = 0

$ ->
  $('#footer').text('Waiting for the game to Start...')
  wsUri = "ws://192.168.0.2:238/"
  wss = new window.WebSocket(wsUri)
  connection = new Connection(wss)

loserTimeout = 0
numberOfAnswers = 0
gameStarted = false
hasWon = false
reset = false
answer = 1

getConnection= ->
  connection

startGame= ->
  gameStarted = true
  $('#footer').text('Ready.')


submitAnswer= (ans) ->
  if loserTimeout == 0 and !hasWon
      console.log("Compare '" + ans + "' == '" + answer + "'")
      if ans == answer
        winner();
      else
        loser();

delay = (ms, func) -> setTimeout func, ms
    
winner= ->
  $('#footer').text('Winner you are!')
  hasWon = true
  getConnection().Send('F')

loser= ->
  $('#footer').text('Loser you be!')
  loserTimeout = 8
  delay 1000, -> timeout()

saySorry= ->
  $('#footer').text('Someone beat you to the punch!')
  reset = true

timeout= ->
  if reset
    reset = false
    return
  if loserTimeout <= 1
    $('#footer').text('Answer again')
    loserTimeout = 0
  else
    loserTimeout-= 1
    writeTimeout()
    delay 1000, -> timeout()

writeTimeout= ->
  $('#footer').text('Answer again in ')
  $('#footer').append(loserTimeout)
  $('#footer').append('s')

interpretQuestion= (dA) ->
  console.log(dA)
  saySorry() if numberOfAnswers > 0 and !hasWon
  numberOfAnswers = 0
  $('#theAnswers').text('')
  addAnswer A for A in dA[2..dA.length-2]
  $('#theQuestion').text(dA[1])
  console.log(dA[dA.length-1])
  answer = parseInt( dA[dA.length-1] , 10)
  console.log(answer)
  hasWon = false

addAnswer=(A) ->
  numberOfAnswers++
  ans="<li class='answer a"+numberOfAnswers+"' onclick='submitAnswer("+numberOfAnswers+");'>"+A+"</li>"
  console.log(numberOfAnswers)
  $('#theAnswers').append(ans)

class Connection
  constructor: (@wss) ->
    @wss.onopen= -> startGame()
    @wss.onmessage= (evt)-> getConnection().Receive(evt)

  Receive: (msg) ->
    dA = msg.data.split("::")
    interpretQuestion(dA) if dA[0] == 'q'
    $('#notice').text(dA[1]) if dA[0] =='s'

  Send: (msg) ->
    @wss.send(msg)