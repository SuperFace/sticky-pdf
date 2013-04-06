
Rest = require "./rest"

class Docs extends Rest
	class Stickers extends Rest
		read: (read, res) ->
			res.send "sticker is here!"
		create: (read, res) ->
			res.send "sticker is here!"

	constructor: (@app, @prefix) ->
		@stickers = new Stickers @app, "#{@prefix}/stickers"
		super @app, @prefix

	read: (req, res) ->
		console.log "get list of documents"
		docs = [
			entity_id: "h45gm432k", title: "Hello world"
			entity_id: "34jh5gjh2", title: "Test task, level 3"
			entity_id: "34jh5gjh3", title: "Test task, level 1"
			entity_id: "34jh5gjh4", title: "Test task, level 2"
			entity_id: "34jh5gjh5", title: "Test task, level 4"
			entity_id: "34jh5gjh6", title: "Test task, level 5"
			entity_id: "34jh5gjh7", title: "Test task, level 6"
		]
		console.log "render it"
		res.render "docs", docs: docs
	create: (req, res) ->
		res.send "docs::create"
	update: (req, res) ->
		res.send "docs::update"
	delete: (req, res) ->
		res.send "docs::delete"

	readid: (req, res) ->
		console.log "i am here :)"
		res.send "docs::readid#{req.params.id}"

	createid: (req, res) ->
		console.log "i am here :)"
		res.send "docs::createid#{req.params.id}\n"

exports.Docs = Docs
