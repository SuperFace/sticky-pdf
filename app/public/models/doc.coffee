class StickerViewModel
	constructor: (sticker) ->
		@entity_id = ko.observable sticker.entity_id
		@page = ko.observable sticker.page
		@x = ko.observable sticker.x
		@y = ko.observable sticker.y
		@text = ko.observable sticker.text
		@updated = ko.observable sticker.updated
		@deleted = ko.observable sticker.deleted

class window.DocViewModel
	constructor: (entity_id, stickers) ->
		@active = ko.observable 1
		@liClass = (page) => 
			return ko.computed () => 
				return "active" if @active() is page
				return ""
		@activeSticker = ko.observable null
		@activeStickerElement = null
		@document_id = entity_id
		@stickers = ko.observableArray []
		for sticker in stickers
			@stickers.push new StickerViewModel sticker

	activate: (page) => =>
		@active page
		$(".doc-ctrl").removeClass "drag-blured"

	onDrag: (x, y) =>
		if x < 0 or y < 0
			$(".doc-ctrl").addClass "drag-blured"
		else
			$(".doc-ctrl").removeClass "drag-blured"
		@stickerFocus(@activeSticker()) false

	newSticker: (data, event) =>
		$element = data.target
		element = $element[0]
		offsetX = parseInt(String(element.style.left).replace /[^0-9-\.]/g, "") or 0
		offsetY = parseInt(String(element.style.top).replace /[^0-9-\.]/g, "") or 0
		zoom = parseFloat $element.css "zoom"
		[offx, offy] = [$element.offset().left * zoom, $element.offset().top * zoom]
		[clix, cliy] = [event.clientX - offx, event.clientY - offy]
		[clix, cliy] = [clix / zoom, cliy / zoom]
		console.log [offx, offy]
		console.log offsetX, offsetY
		console.log clix, cliy
		# if offsetX is 0 and offsetY is 0
			# offsetX = offsetX + offx
			# offsetY = offsetY + offy
			# console.log "dblclicked:", clix - offsetX, cliy - offsetY
			# [x, y] = [clix - offsetX, cliy - offsetY]
		# else
			# console.log "dblclicked:", clix, cliy
		[x, y] = [clix, cliy]
		console.log zoom
		# [x, y] = [x / zoom, y / zoom]
		$.ajax
			url: "/docs/stickers/#{@document_id}"
			type: "post"
			data: 
				json: JSON.stringify
					text: ""
					x: x
					y: y
					page: @active()
			dataType: "json"
			success: (sticker) =>
				# $(".doc-view > div").append(
				# 	"<div class=\"sticker\" style=\"left: #{sticker.x}px; top: #{sticker.y}px;\"  data-bind=\"click: stickerFocus('#{sticker.entity_id}'), attr: {contenteditable: editable('#{sticker.entity_id}')}\"> #{sticker.text} </div>"
				# 	# "<div class=\"sticker\" style=\"left: #{x}px; top: #{y}px;\" data-bind=\"focus: stickerFocus('new')\" contenteditable=true> </div>"
				# )
				@stickers.push new StickerViewModel sticker


	stickerFocus: (entity_id) => (data, event) =>
		# $element = data.target
		# console.log event.target
		console.log entity_id
		oldActiveSticker = @activeSticker()
		if @activeSticker() and (oldActiveSticker isnt entity_id or not data)
			console.log "saving sticker.."
			console.log @activeStickerElement
			text = $(@activeStickerElement).html()
			onlyText = $(@activeStickerElement).text()
			if onlyText isnt ""
				$.ajax
					url: "/docs/stickers/#{@activeSticker()}"
					type: "put"
					data: 
						json: JSON.stringify
							text: text
					dataType: "json"
					success: (data) =>
						# console.log @stickers()
						# console.log sticker
						# @stickers()[sticker].text = data.text 
						for sticker in @stickers() when sticker.entity_id() is oldActiveSticker
							sticker.text data.text
						console.log @stickers()
			else
				$.ajax
					url: "/docs/stickers/#{@activeSticker()}"
					type: "delete"
					success: =>
						@stickers.remove (item) => item.entity_id() is oldActiveSticker
			@activeSticker null
			return
		# @activeStickerElement = null
		console.log oldActiveSticker
		if oldActiveSticker isnt entity_id and event
			@activeSticker entity_id
			@activeStickerElement = event.target


	dragAllowed: => $(".sticker:hover").length is 0

	editable: (entity_id) => ko.computed =>
		return @activeSticker() is entity_id

	stickerStyle: (sticker) => ko.computed => "left: #{sticker.x()}px; top: #{sticker.y()}px;"


stickerWatcher = ->
	data = {}
	if stickerWatcher.nonce
		data.nonce = stickerWatcher.nonce
	$.ajax
		type: "get"
		url: "/docs/stickers/#{stickerWatcher.entity_id}"
		data: data
		dataType: "json"
		success: (res) =>
			console.log res
			mapped = {}
			ok = {}
			stickerWatcher.nonce = res.nonce
			for sticker in res.stickers
				mapped[sticker.entity_id] = sticker
			for sticker in docView.stickers()
				update = mapped[sticker.entity_id()]
				if update and sticker.entity_id() isnt docView.activeSticker()
					ok[sticker.entity_id()] = true
					docView.stickers.remove sticker
					docView.stickers.push new StickerViewModel update
			for sticker in res.stickers
				unless sticker.deleted
					unless ok[sticker.entity_id]
						docView.stickers.push new StickerViewModel sticker


stickerWatcher.entity_id = $("#document_id").text()
setInterval stickerWatcher, 10000


