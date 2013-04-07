ko.bindingHandlers.dblclick = 
	init: (element, valueAccessor) ->
		$element = $ element

		$element.dblclick (e) =>
			data = target: $element
			return valueAccessor()(data, e)

