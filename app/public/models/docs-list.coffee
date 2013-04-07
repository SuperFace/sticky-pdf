class window.DocsListViewModel
	constructor: ->
		@modal = 
			shown: ko.observable false
			header: ko.observable "Upload document"
			body: ko.observable "<b>Fine body</b>"
			okTitle: ko.observable "Upload"
			cancel: ko.observable => $(".modal .close").click()
			ok: ko.observable =>
				console.log "uploading document"
				$(".modal form").submit()

	uploadDocument: (data, event) =>
		@modal.body $("#upload_form").html()
		@modal.shown true
		$('.modal').modal "show"

	viewDocument: (entity_id) => =>
		window.location = "/docs/#{entity_id}"

