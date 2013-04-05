
Rest = require "./rest"

class Docs extends Rest
	class Sticker extends Rest
		read: (read, res) ->
			res.send "sticker is here!"
		create: (read, res) ->
			res.send "sticker is here!"

	constructor: (@app, @prefix) ->
		@sticker = new Sticker @app, "#{@prefix}/sticker"
		super @app, @prefix

	read: (req, res) ->
		res.send "docs::read"
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
