# Description
#   This plugin will listen for links in the specified HUBOT_PICKS_ROOM. 
#   Each link detected will be sent to HUBOT_PICKS_DISCOVER_URL where it'll be processed.
#
# Configuration:
#   HUBOT_PICKS_DISCOVER_URL
#   HUBOT_PICKS_ROOM
#   HUBOT_PICKS_EMAIL
#   HUBOT_PICKS_API_TOKEN
#
# Commands:
#   <link> - Will send a link to Diacode Picks API
#
# Author:
#   hopsor

module.exports = (robot) ->
  apiEndpoint = process.env.HUBOT_PICKS_DISCOVER_URL
  watchedRoom = process.env.HUBOT_PICKS_ROOM
  userEmail = process.env.HUBOT_PICKS_EMAIL
  apiToken = process.env.HUBOT_PICKS_API_TOKEN

  robot.hear /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i, (msg) ->
    # Checking ENV variables before sending the link
    if !apiEndpoint || !watchedRoom || !userEmail || !apiToken 
      msg.send "You have to set these four environment variables:"
      msg.send "HUBOT_PICKS_DISCOVER_URL, HUBOT_PICKS_ROOM, HUBOT_PICKS_EMAIL, HUBOT_PICKS_API_TOKEN"
      return

    # Checking message room matches HUBOT_PICKS_ROM environment variable
    if msg.envelope.room == watchedRoom
      params = 
        "link":
          "url": msg.message.text

      stringParams = JSON.stringify(params)

      msg.http(apiEndpoint)
        .headers(
          'Accept': 'application/json'
          'Content-Length': stringParams.length
          'Content-Type': 'application/json'
          'auth-email': userEmail
          'auth-token': apiToken
        )        
        .post(stringParams) (err, res, body) ->
          if err
            msg.send "Encountered an error :( #{err}"
            return

          if res.statusCode < 200 || res.statusCode > 299
            msg.send "Request didn't come back HTTP 200 :("
            return

          linkData = null

          try
            linkData = JSON.parse(body)
          catch error
            msg.send "Ran into an error parsing JSON :("
            return

          msg.send "Link processed and saved with ID #{linkData.link.id}"
