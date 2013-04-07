
Rest = require "./rest"

fs = require "fs"
exec = require("child_process").exec
gm = require "gm"
path = require "path"
util = require "util"

MongoClient = require("mongodb").MongoClient
ObjectID = require("mongodb").ObjectID

class Docs extends Rest
	class Stickers extends Rest
		readid: (req, res) ->
			# res.send "sticker is here!"
			console.log req.body
			nonce = req.query.nonce or Date.now()
			console.log nonce
			entity_id = req.params.id
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log entity_id
					docs.findOne
						entity_id: ObjectID entity_id
					, (err, item) =>
						return @fail res, err, "sorry, unable to find document" if err
						stickers = item.stickers.filter (x) => x.updated > nonce
						res.send JSON.stringify
							stickers: stickers
							nonce: Date.now()
		createid: (req, res) ->
			data = JSON.parse req.body.json
			sticker = 
				text: data.text
				x: data.x
				y: data.y
				entity_id: ObjectID()
				page: data.page
				updated: Date.now()
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log req.params.id
					docs.findOne
						entity_id: ObjectID req.params.id
					, (err, item) =>
						return @fail res, err, "sorry, unable to find document" if err
						item.stickers.push sticker
						docs.save item, =>
			res.send JSON.stringify sticker
		updateid: (req, res) ->
			data = JSON.parse req.body.json
			console.log data
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log req.params.id
					docs.findOne
						"stickers.entity_id": ObjectID req.params.id
					, (err, item) =>
						console.log "found doc!"
						for sticker in item.stickers when "#{sticker.entity_id}" is "#{req.params.id}"
							console.log "found sticker!"
							sticker.text = data.text
							sticker.updated = Date.now()
							found = sticker
							break
						docs.save item, =>
						res.send JSON.stringify found
		deleteid: (req, res) ->
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log req.params.id
					docs.findOne
						"stickers.entity_id": ObjectID req.params.id
					, (err, item) =>
						console.log "found doc!"
						for sticker in item.stickers when "#{sticker.entity_id}" is "#{req.params.id}"
							console.log "found sticker!"
							# sticker.text = data.text
							sticker.deleted = true
							sticker.updated = Date.now()
							found = sticker
							break
						# item.stickers = item.stickers.filter (x) => "#{x.entity_id}" isnt "#{req.params.id}"
						docs.save item, =>
						res.send JSON.stringify
							result: "ok"

	class Thumbs extends Rest
		readid: (req, res) ->
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log req.params.id
					docs.findOne
						entity_id: ObjectID req.params.id
					, (err, item) =>
						return @fail res, err, "sorry, unable to find document" if err
						console.log item
						thumbPath = "#{process.env.PWD}/files/#{item.file_id}.thumb.jpg"
						fs.stat thumbPath, (err, stats) =>
							return @fail res, err, "sorry, unable to load thumbnail" if err
							res.writeHead 200, 
								"Content-Type": "image/jpg"
								"Content-Length": stats.size
							readStream = fs.createReadStream thumbPath
							util.pump readStream, res

	class Pages extends Rest
		readid: (req, res) ->
			MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
				return @fail res, err, "sorry, error occurred while db connecting" if err
				db.collection "docs", (err, docs) =>
					return @fail res, err, "sorry, error occurred while collection creating" if err
					console.log req.params.id
					entity_id = req.params.id.replace /-[^$]*$/, ""
					console.log "'#{entity_id}'"
					page = req.params.id.replace /^[^-]*-/, ""
					docs.findOne
						entity_id: ObjectID entity_id
					, (err, item) =>
						return @fail res, err, "sorry, unable to find document" if err
						console.log item
						thumbPath = "#{process.env.PWD}/files/#{item.file_id}-#{page}.jpg"
						fs.stat thumbPath, (err, stats) =>
							return @fail res, err, "sorry, unable to load thumbnail" if err
							res.writeHead 200, 
								"Content-Type": "image/jpg"
								"Content-Length": stats.size
							readStream = fs.createReadStream thumbPath
							util.pump readStream, res

	constructor: (@app, @prefix) ->
		@stickers = new Stickers @app, "#{@prefix}/stickers"
		@thumbs = new Thumbs @app, "#{@prefix}/thumbs"
		@pages = new Pages @app, "#{@prefix}/pages"
		super @app, @prefix

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
				docs.find().sort({_id: -1}).toArray (err, items) =>
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
		# console.log "i am here :)"
		# res.send "docs::readid#{req.params.id}"
		# doc = 
		# 	title: "hello world"
		# 	pages: 3
		# 	file_id: "h34g543jh5"
		# 	entity_id: "hgjhg324hj"
		# 	_id: "jahfkjsdahf"
		# res.render "docs_specific", doc: doc, pages: [1..doc.pages]
		MongoClient.connect "mongodb://localhost:27017/stickypdf", (err, db) =>
			return @fail res, err, "sorry, error occurred while db connecting" if err
			db.collection "docs", (err, docs) =>
				return @fail res, err, "sorry, error occurred while collection creating" if err
				docs.findOne
					entity_id: ObjectID req.params.id
				, (err, item) =>
					return @fail res, err, "sorry, error occurred while retreiving item" if err
					doc = item
					doc.stickers = doc.stickers.filter (x) => x.page
					res.render "docs_specific", doc: doc, pages: [1..doc.page_cnt]


	createid: (req, res) ->
		console.log "i am here :)"
		res.send "docs::createid#{req.params.id}\n"

exports.Docs = Docs
