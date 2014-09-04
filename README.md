http://www.tuicool.com/articles/Uzy2Uj

# Hubot Salesforce Adapter

## Description

This adapter for hubot allows you to publish/subscribe messages from Salesforce's chatter application. It
uses [nforce](https://github.com/kevinohara80/nforce) to authenticate, subscribe to a push topic, and post feed item's
via the REST API.

## Installation

* Add `hubot-salesforce` as a dependency in your hubot's `package.json`
* Install dependencies with `npm install`
* Run hubot with `bin/hubot -a salesforce`

## Preqs

This [article](https://github.com/kevinohara80/nforce) provides the configuration needed in Salesforce for this to work.
Basically, you need to create a connected application, custom object to store feed item data, push topic, and a trigger to
copy data from the actual feed item store to your custom object.

## Usage

You will need to set some environment variables to use this adapter.

Required
export SALESFORCE_CLIENT_ID=client-id
export SALESFORCE_CLIENT_SECRET=client-user
export SALESFORCE_USERNAME=hubot-salesforce-username
export SALESFORCE_PASSWORD=hubot-salesforce-password+token - Salesforce docs about OAuth talk about this
export SALESFORCE_CHATTER_TOPIC=push-topic-name
export SALESFORCE_USER_ID=hubot-salesforce-user-id
export SALESFORCE_FEEDS=chatter-feed-id1,chatter-feed-id2

Optional
export SALESFORCE_ENVIRONMENT=(production or sandbox)
export SALESFORCE_REDIRECT_URL=callback-url-for-connected-app
export SALESFORCE_API_VERSION=v30.0

## Copyright
Copyright &copy; Peter Washburn. MIT License; see LICENSE for further details.
