
Rest = require "./rest"
fs = require "fs"
exec = require("child_process").exec
gm = require "gm"
path = require "path"
MongoClient = require("mongodb").MongoClient
ObjectID = require("mongodb").ObjectID

class Docs extends Rest
	class Stickers extends Rest
		read: (read, res) ->
			res.send "sticker is here!"
		create: (read, res) ->
			res.send "sticker is here!"

	constructor: (@app, @prefix) ->
		@stickers = new Stickers @app, "#{@prefix}/stickers"
		super @app, @prefix

	fail: (res, err, msg) =>
		console.log err
		res.send msg
	condition: (variable, cb) => 
		(val) =>
			if val is undefined
				return variable
			else
				variable = val
				cb()

	read: (req, res) ->
		console.log "get list of documents"
		# docs = [
		# 	{entity_id: "h45gm432k", title: "Hello world"}
		# 	{entity_id: "34jh5gjh2", title: "Test task, level 3"}
		# 	{entity_id: "34jh5gjh3", title: "Test task, level 1"}
		# 	{entity_id: "34jh5gjh4", title: "Test task, level 2"}
		# 	{entity_id: "34jh5gjh5", title: "Test task, level 4"}
		# 	{entity_id: "34jh5gjh6", title: "Test task, level 5"}
		# 	{entity_id: "34jh5gjh7", title: "Test task, level 6"}
		# ]
		# console.log "render it"
		# console.log docs
		# res.render "docs", docs: docs
		MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
			return @fail res, err, "sorry, error occurred while db connecting" if err
			db.collection "docs", (err, docs) =>
				return @fail res, err, "sorry, error occurred while collection creating" if err
				docs.find().toArray (err, items) =>
					@fail res, err, "sorry, unable to load documents" if err
					docslist = items
					res.render "docs", docs: docslist
	create: (req, res) ->
		# res.send "docs::create"
		entityId = ObjectID()
		conditions = {}
		cb = =>
			console.log "cb is here"
			console.log conditions
			for key, value of conditions
				if value() is false
					return
			res.redirect "/docs/#{entityId}"
		conditions.rename = @condition false, cb
		conditions.render = @condition false, cb
		conditions.thumb = @condition false, cb
		conditions.save = @condition false, cb
		console.log "move file to our directory"
		fileId = ObjectID()
		newPath = "#{process.env.PWD}/files/#{fileId}.pdf"
		jpgPath = "#{process.env.PWD}/files/#{fileId}-%d.jpg"
		jpgPathFirst = "#{process.env.PWD}/files/#{fileId}-1.jpg"
		thumbPath = "#{process.env.PWD}/files/#{fileId}.thumb.jpg"
		title = req.files.document.name.replace /\.pdf$/, ""
		fs.readFile req.files.document.path, (err, data) =>
			return @fail res, err, "sorry, error occurred while uploading your pdf" if err
			fs.writeFile newPath, data, (err) =>
				return @fail res, err, "sorry, error occurred while uploading your pdf" if err
				conditions.rename true
				console.log "render file to jpg"
				exec "gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r144 -sOutputFile=#{jpgPath} #{newPath}", (err, stdout) =>
					return @fail res, err, "sorry, error occurred while rendering your pdf" if err
					# pageCount = stdout[stdout.length - 1]
					stdout = stdout.split "\n"
					stdout = stdout.filter (x) => x.match "Page"
					pageCount = parseInt stdout[stdout.length - 1].replace "Page ", ""
					console.log pageCount
					conditions.render true
					console.log "create thumbnail"
					gm("#{jpgPathFirst}").thumb 100, 100, "#{thumbPath}", 90, (err) =>
						return @fail res, err, "sorry, error occurred while rendering thumbnail of your pdf" if err
						conditions.thumb true
						console.log "create doc object"
						doc = 
							entity_id: entityId
							file_id: fileId
							stickers: []
							page_cnt: pageCount
							title: title
						console.log "save it to mongo"
						MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
							return @fail res, err, "sorry, error occurred while db connecting" if err
							db.collection "docs", (err, docs) =>
								return @fail res, err, "sorry, error occurred while collection creating" if err
								docs.insert doc, { w: 1, j: 1 }, (err, result) =>
									return @fail res, err, "sorry, error occurred while saving document" if err
									console.log result
									conditions.save true
				
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
