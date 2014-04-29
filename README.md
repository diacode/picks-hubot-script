# Diacode Picks Hubot script

Script to integrate Hubot with Diacode Picks.

## Configuration

You'll have to set these env variables in order to get the script working:

`HUBOT_PICKS_DISCOVER_URL`: Link creation url which should be `http://yourwebsite/api/links`
`HUBOT_PICKS_ROOM`: Name of the room where the bot will listen
`HUBOT_PICKS_EMAIL`: Bot email in Diacode Picks app
`HUBOT_PICKS_API_TOKEN`: Bot API token in Diacode Picks app

## Usage

Once you have your bot up and running you just need to write a link in `HUBOT_PICKS_ROOM` and it will be automatically sent to your Diacode Picks instance.
