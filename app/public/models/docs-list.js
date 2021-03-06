// Generated by CoffeeScript 1.6.2
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.DocsListViewModel = (function() {
    function DocsListViewModel() {
      this.viewDocument = __bind(this.viewDocument, this);
      this.uploadDocument = __bind(this.uploadDocument, this);
      var _this = this;

      this.modal = {
        shown: ko.observable(false),
        header: ko.observable("Upload document"),
        body: ko.observable("<b>Fine body</b>"),
        okTitle: ko.observable("Upload"),
        cancel: ko.observable(function() {
          return $(".modal .close").click();
        }),
        ok: ko.observable(function() {
          console.log("uploading document");
          return $(".modal form").submit();
        })
      };
    }

    DocsListViewModel.prototype.uploadDocument = function(data, event) {
      this.modal.body($("#upload_form").html());
      this.modal.shown(true);
      return $('.modal').modal("show");
    };

    DocsListViewModel.prototype.viewDocument = function(entity_id) {
      var _this = this;

      return function() {
        return window.location = "/docs/" + entity_id;
      };
    };

    return DocsListViewModel;

  })();

}).call(this);
