
class Rest
	constructor: (@app, @prefix = "/#{@constructor.name}") ->
		console.log "creating Rest > #{@constructor.name}"

		@entity = @constructor.name.toLowerCase()

		app.param "#{@entity}_id", (req, res, next, id) =>
			req.params = {} unless req.params
			req.params.id = id
			next()

		@reg "get", "read" if @read
		@reg "post", "create" if @create
		@reg "put", "update" if @update
		@reg "delete", "delete" if @delete

		@regid "get", "readid" if @readid
		@regid "post", "createid" if @createid
		@regid "put", "updateid" if @updateid
		@regid "delete", "deleteid" if @deleteid

	reg: (method, cb) ->
		@app[method] @prefix, (req, res) => @[cb] req, res

	regid: (method, cb) ->
		@app[method] "#{@prefix}/:#{@entity}_id", (req, res) => @[cb] req, res

module.exports = Rest
