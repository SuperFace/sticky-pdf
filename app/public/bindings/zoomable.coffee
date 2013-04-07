ko.bindingHandlers.zoomable = 
	init: (element, valueAccessor) ->
		$element = $ element

		$element.addClass "zoomable"

		$element.bind "mousewheel", (e) =>
			event = e.originalEvent
			inc = event.wheelDelta / 120 * 0.05
			zoom = $element.css "zoom"
			zoom = parseFloat(zoom) + parseFloat(inc)
			$element.css zoom: zoom

