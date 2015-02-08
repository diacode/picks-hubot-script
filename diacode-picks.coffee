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

apiEndpoint = process.env.HUBOT_PICKS_DISCOVER_URL
watchedRoom = process.env.HUBOT_PICKS_ROOM
userEmail = process.env.HUBOT_PICKS_EMAIL
apiToken = process.env.HUBOT_PICKS_API_TOKEN

# ==============
# Custom methods
# ==============

# validateConfiguration: Checks all ENV variables are properly set
validateConfiguration = (msg) ->
  if !apiEndpoint || !watchedRoom || !userEmail || !apiToken 
    msg.send "You have to set these four environment variables:"
    msg.send "HUBOT_PICKS_DISCOVER_URL, HUBOT_PICKS_ROOM, HUBOT_PICKS_EMAIL, HUBOT_PICKS_API_TOKEN"
    return false
  else return true

# validateRoom: Returns true if the message room matches HUBOT_PICKS_ROM environment variable 
validateRoom = (msg) ->
  msg.envelope.room == watchedRoom

# sendApiRequest: Make api requests
sendApiRequest = (msg, endPoint, params, method, callback) ->
  stringParams = JSON.stringify(params)

  request = msg.http(endPoint)
    .headers(
      'Accept': 'application/json'
      'Content-Length': stringParams.length
      'Content-Type': 'application/json'
      'auth-email': userEmail
      'auth-token': apiToken
    )

  # TODO: Figure out how to call post, put, or anyother method depending on 'method' param
  request.post(stringParams) (err, res, body) ->
    if err
      msg.send "Encountered an error :( #{err}"
      return

    if res.statusCode < 200 || res.statusCode > 299
      msg.send "Request didn't come back HTTP 200 :("
      return

    linkData = null

    try
      linkData = JSON.parse(body)
      callback(linkData)
    catch error
      msg.send "Ran into an error parsing JSON response :("
      return

# ======================
# Bot action definitions
# ======================
addLink = (msg) ->
  return unless validateConfiguration(msg)
  return unless validateRoom(msg)

  params = 
    link:
      url: msg.message.text

  sendApiRequest(msg, apiEndpoint, params, 'post', (linkData) ->
    # TODO: Show link preview fetched by the api
    msg.send "Link processed and saved with ID #{linkData.link.id}"
  )    

editLink = (msg) ->
  return unless validateConfiguration(msg)
  return unless validateRoom(msg)

  editionRegex = /^!edit ([0-9]+) (title|description) (.*)$/i
  matches = approvalRegex.exec(msg.message.text)
  linkId = matches[1]

  params = {}
  params.link = {}

  params.link[matches[2]] = matches[3]

  sendApiRequest(msg, "#{apiEndpoint}/#{linkId}", params, 'put', (linkData) ->
    msg.send "Link #{linkId} updated successfully"
  )

approveLink = (msg) ->
  return unless validateConfiguration(msg)
  return unless validateRoom(msg)

  approvalRegex = /^!approve ([0-9]+)$/i
  matches = approvalRegex.exec(msg.message.text)
  linkId = matches[1]

  params = 
    link:
      approved: true

  sendApiRequest(msg, "#{apiEndpoint}/#{linkId}", params, 'put', (linkData) ->
    msg.send "Link #{linkId} approved successfully"
  )

module.exports = (robot) ->
  robot.hear /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i, addLink
  robot.hear /^!edit ([0-9]+) (title|description) (.*)$/i, editLink
  robot.hear /^!approve ([0-9]+)$/i, approveLink
