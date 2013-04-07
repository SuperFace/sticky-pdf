ko.bindingHandlers.draggable = 
	init: (element, valueAccessor) ->
		$element = $ element

		$element.addClass "draggable"

		callback = valueAccessor().callback
		condition = valueAccessor().condition

		util =
			startX: 0
			startY: 0
			offsetX: 0
			offsetY: 0
			dragElement: null
			oldZIndex: 0

		exnum = (n) =>
			n = parseInt n
			if n isnt null
				return n
			if isNaN n
				return 0
			return n

		mousemove = (e) =>
			# console.log "move"

			console.log (util.offsetX + e.clientX - util.startX), (util.offsetY + e.clientY - util.startY)

			zoom = parseFloat $element.css "zoom"

			element.style.left = (util.offsetX + (e.clientX - util.startX) / zoom) + 'px'
			element.style.top = (util.offsetY + (e.clientY - util.startY) / zoom) + 'px'

			callback (util.offsetX + e.clientX - util.startX), (util.offsetY + e.clientY - util.startY)

		mouseup = (e) =>
			console.log "up"

			document.onmousemove = null
			document.onmouseup = null

		$element.mousedown (e) =>
			if e.button isnt 0
				return

			unless condition()
				return

			console.log "down"

			$(":focus").blur()

			util.startX = e.clientX
			util.startY = e.clientY

			util.offsetX = parseInt(String(element.style.left).replace /[^0-9-\.]/g, "") or 0
			util.offsetY = parseInt(String(element.style.top).replace /[^0-9-\.]/g, "") or 0

			console.log util.offsetX, util.offsetY

			document.onmousemove = mousemove
			document.onmouseup = mouseup

			document.body.focus()

			mousemove e

			return false

		$element.mouseup mouseup

