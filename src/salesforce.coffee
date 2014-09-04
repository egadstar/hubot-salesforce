# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

nforce = require 'nforce'

class SalesForceChatter extends Adapter

  run: ->
    # Client Options
    @options =
      clientId: process.env.SALESFORCE_CLIENT_ID
      clientSecret: process.env.SALESFORCE_CLIENT_SECRET
      username: process.env.SALESFORCE_USERNAME
      password: process.env.SALESFORCE_PASSWORD
      chatterTopic: process.env.SALESFORCE_CHATTER_TOPIC
      userId: process.env.SALESFORCE_USER_ID
      redirectUrl: process.env.SALESFORCE_REDIRECT_URL || 'https://localhost.com'
      apiVersion: process.env.SALESFORCE_API_VERSION || 'v30.0'
      environment: process.env.SALESFORCE_ENVIRONMENT || 'production'
      feeds: process.env.SALESFORCE_FEEDS?.split(',') ? []

    # salesforce connection setup
    @org = nforce.createConnection(
      clientId: @options.clientId,
      clientSecret: @options.clientSecret,
      redirectUri: @options.redirectUrl,
      apiVersion: @options.apiVersion,
      environment: @options.environment,
      mode: 'single',
      autoRefresh: true
    )

    # oauth authentication
    @org.authenticate({ username: @options.username, password: @options.password }, (err, oauth) =>
      if err
        return @robot.logger.error err.stack

      @oauth = oauth

      #subscribe to a pushtopic
      str = @org.stream({ topic: @options.chatterTopic, oauth: oauth });

      str.on 'connect', =>
        @robot.logger.info "Robot: Connected to Salesforce push topic."

      str.on 'error', (err) =>
        @robot.logger.error err.stack

      str.on 'data', (data) =>
        isListeningToFeed = false
        for feed in @options.feeds
          if data.sobject.ParentId__c.indexOf(feed) != -1
            isListeningToFeed = true

        # make sure this isn't a hubot message and in one of the feeds elbot is suppose to acknowledge
        if data.sobject.User__c.indexOf(@options.userId) == -1 && isListeningToFeed
          message = new TextMessage data.sobject.Name__c, data.sobject.Body__c, "message-#{new Date()}"
          message.room = data.sobject.ParentId__c
          @receive message

    )

    @emit 'connected'

  send: (envelope, strings...) =>
    for str in strings
      feedItem = nforce.createSObject('FeedItem')
      feedItem.set('Body', str)
      feedItem.set('ParentId', envelope.room)
      feedItem.set('Type', 'TextPost')

      @org.insert({ sobject: feedItem, oauth: @oauth }, (err, resp) ->
        if err
          @robot.logger.error err.stack
      )

  reply: (envelope, strings...) ->
    for str in strings
      @send envelope, str


exports.use = (robot) ->
  new SalesForceChatter robot
