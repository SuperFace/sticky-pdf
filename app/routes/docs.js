// Generated by CoffeeScript 1.6.2
(function() {
  var Docs, MongoClient, ObjectID, Rest, exec, fs, gm, path, util,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Rest = require("./rest");

  fs = require("fs");

  exec = require("child_process").exec;

  gm = require("gm");

  path = require("path");

  util = require("util");

  MongoClient = require("mongodb").MongoClient;

  ObjectID = require("mongodb").ObjectID;

  Docs = (function(_super) {
    var Pages, Stickers, Thumbs, _ref, _ref1, _ref2;

    __extends(Docs, _super);

    Stickers = (function(_super1) {
      __extends(Stickers, _super1);

      function Stickers() {
        _ref = Stickers.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Stickers.prototype.readid = function(req, res) {
        var entity_id, nonce,
          _this = this;

        console.log(req.body);
        nonce = req.query.nonce || Date.now();
        console.log(nonce);
        entity_id = req.params.id;
        return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(entity_id);
            return docs.findOne({
              entity_id: ObjectID(entity_id)
            }, function(err, item) {
              var stickers;

              if (err) {
                return _this.fail(res, err, "sorry, unable to find document");
              }
              stickers = item.stickers.filter(function(x) {
                return x.updated > nonce;
              });
              return res.send(JSON.stringify({
                stickers: stickers,
                nonce: Date.now()
              }));
            });
          });
        });
      };

      Stickers.prototype.createid = function(req, res) {
        var data, sticker,
          _this = this;

        data = JSON.parse(req.body.json);
        sticker = {
          text: data.text,
          x: data.x,
          y: data.y,
          entity_id: ObjectID(),
          page: data.page,
          updated: Date.now()
        };
        MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(req.params.id);
            return docs.findOne({
              entity_id: ObjectID(req.params.id)
            }, function(err, item) {
              if (err) {
                return _this.fail(res, err, "sorry, unable to find document");
              }
              item.stickers.push(sticker);
              return docs.save(item, function() {});
            });
          });
        });
        return res.send(JSON.stringify(sticker));
      };

      Stickers.prototype.updateid = function(req, res) {
        var data,
          _this = this;

        data = JSON.parse(req.body.json);
        console.log(data);
        return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(req.params.id);
            return docs.findOne({
              "stickers.entity_id": ObjectID(req.params.id)
            }, function(err, item) {
              var found, sticker, _i, _len, _ref1;

              console.log("found doc!");
              _ref1 = item.stickers;
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                sticker = _ref1[_i];
                if (!(("" + sticker.entity_id) === ("" + req.params.id))) {
                  continue;
                }
                console.log("found sticker!");
                sticker.text = data.text;
                sticker.updated = Date.now();
                found = sticker;
                break;
              }
              docs.save(item, function() {});
              return res.send(JSON.stringify(found));
            });
          });
        });
      };

      Stickers.prototype.deleteid = function(req, res) {
        var _this = this;

        return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(req.params.id);
            return docs.findOne({
              "stickers.entity_id": ObjectID(req.params.id)
            }, function(err, item) {
              var found, sticker, _i, _len, _ref1;

              console.log("found doc!");
              _ref1 = item.stickers;
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                sticker = _ref1[_i];
                if (!(("" + sticker.entity_id) === ("" + req.params.id))) {
                  continue;
                }
                console.log("found sticker!");
                sticker.deleted = true;
                sticker.updated = Date.now();
                found = sticker;
                break;
              }
              docs.save(item, function() {});
              return res.send(JSON.stringify({
                result: "ok"
              }));
            });
          });
        });
      };

      return Stickers;

    })(Rest);

    Thumbs = (function(_super1) {
      __extends(Thumbs, _super1);

      function Thumbs() {
        _ref1 = Thumbs.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Thumbs.prototype.readid = function(req, res) {
        var _this = this;

        return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(req.params.id);
            return docs.findOne({
              entity_id: ObjectID(req.params.id)
            }, function(err, item) {
              var thumbPath;

              if (err) {
                return _this.fail(res, err, "sorry, unable to find document");
              }
              console.log(item);
              thumbPath = "" + process.env.PWD + "/files/" + item.file_id + ".thumb.jpg";
              return fs.stat(thumbPath, function(err, stats) {
                var readStream;

                if (err) {
                  return _this.fail(res, err, "sorry, unable to load thumbnail");
                }
                res.writeHead(200, {
                  "Content-Type": "image/jpg",
                  "Content-Length": stats.size
                });
                readStream = fs.createReadStream(thumbPath);
                return util.pump(readStream, res);
              });
            });
          });
        });
      };

      return Thumbs;

    })(Rest);

    Pages = (function(_super1) {
      __extends(Pages, _super1);

      function Pages() {
        _ref2 = Pages.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Pages.prototype.readid = function(req, res) {
        var _this = this;

        return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while db connecting");
          }
          return db.collection("docs", function(err, docs) {
            var entity_id, page;

            if (err) {
              return _this.fail(res, err, "sorry, error occurred while collection creating");
            }
            console.log(req.params.id);
            entity_id = req.params.id.replace(/-[^$]*$/, "");
            console.log("'" + entity_id + "'");
            page = req.params.id.replace(/^[^-]*-/, "");
            return docs.findOne({
              entity_id: ObjectID(entity_id)
            }, function(err, item) {
              var thumbPath;

              if (err) {
                return _this.fail(res, err, "sorry, unable to find document");
              }
              console.log(item);
              thumbPath = "" + process.env.PWD + "/files/" + item.file_id + "-" + page + ".jpg";
              return fs.stat(thumbPath, function(err, stats) {
                var readStream;

                if (err) {
                  return _this.fail(res, err, "sorry, unable to load thumbnail");
                }
                res.writeHead(200, {
                  "Content-Type": "image/jpg",
                  "Content-Length": stats.size
                });
                readStream = fs.createReadStream(thumbPath);
                return util.pump(readStream, res);
              });
            });
          });
        });
      };

      return Pages;

    })(Rest);

    function Docs(app, prefix) {
      this.app = app;
      this.prefix = prefix;
      this.stickers = new Stickers(this.app, "" + this.prefix + "/stickers");
      this.thumbs = new Thumbs(this.app, "" + this.prefix + "/thumbs");
      this.pages = new Pages(this.app, "" + this.prefix + "/pages");
      Docs.__super__.constructor.call(this, this.app, this.prefix);
    }

    Docs.prototype.read = function(req, res) {
      var _this = this;

      console.log("get list of documents");
      return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
        if (err) {
          return _this.fail(res, err, "sorry, error occurred while db connecting");
        }
        return db.collection("docs", function(err, docs) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while collection creating");
          }
          return docs.find().sort({
            _id: -1
          }).toArray(function(err, items) {
            var docslist;

            if (err) {
              _this.fail(res, err, "sorry, unable to load documents");
            }
            docslist = items;
            return res.render("docs", {
              docs: docslist
            });
          });
        });
      });
    };

    Docs.prototype.create = function(req, res) {
      var cb, conditions, entityId, fileId, jpgPath, jpgPathFirst, newPath, thumbPath, title,
        _this = this;

      entityId = ObjectID();
      conditions = {};
      cb = function() {
        var key, value;

        console.log("cb is here");
        console.log(conditions);
        for (key in conditions) {
          value = conditions[key];
          if (value() === false) {
            return;
          }
        }
        return res.redirect("/docs/" + entityId);
      };
      conditions.rename = this.condition(false, cb);
      conditions.render = this.condition(false, cb);
      conditions.thumb = this.condition(false, cb);
      conditions.save = this.condition(false, cb);
      console.log("move file to our directory");
      fileId = ObjectID();
      newPath = "" + process.env.PWD + "/files/" + fileId + ".pdf";
      jpgPath = "" + process.env.PWD + "/files/" + fileId + "-%d.jpg";
      jpgPathFirst = "" + process.env.PWD + "/files/" + fileId + "-1.jpg";
      thumbPath = "" + process.env.PWD + "/files/" + fileId + ".thumb.jpg";
      title = req.files.document.name.replace(/\.pdf$/, "");
      return fs.readFile(req.files.document.path, function(err, data) {
        if (err) {
          return _this.fail(res, err, "sorry, error occurred while uploading your pdf");
        }
        return fs.writeFile(newPath, data, function(err) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while uploading your pdf");
          }
          conditions.rename(true);
          console.log("render file to jpg");
          return exec("gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r144 -sOutputFile=" + jpgPath + " " + newPath, function(err, stdout) {
            var pageCount;

            if (err) {
              return _this.fail(res, err, "sorry, error occurred while rendering your pdf");
            }
            stdout = stdout.split("\n");
            stdout = stdout.filter(function(x) {
              return x.match("Page");
            });
            pageCount = parseInt(stdout[stdout.length - 1].replace("Page ", ""));
            console.log(pageCount);
            conditions.render(true);
            console.log("create thumbnail");
            return gm("" + jpgPathFirst).thumb(100, 100, "" + thumbPath, 90, function(err) {
              var doc;

              if (err) {
                return _this.fail(res, err, "sorry, error occurred while rendering thumbnail of your pdf");
              }
              conditions.thumb(true);
              console.log("create doc object");
              doc = {
                entity_id: entityId,
                file_id: fileId,
                stickers: [],
                page_cnt: pageCount,
                title: title
              };
              console.log("save it to mongo");
              return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
                if (err) {
                  return _this.fail(res, err, "sorry, error occurred while db connecting");
                }
                return db.collection("docs", function(err, docs) {
                  if (err) {
                    return _this.fail(res, err, "sorry, error occurred while collection creating");
                  }
                  return docs.insert(doc, {
                    w: 1,
                    j: 1
                  }, function(err, result) {
                    if (err) {
                      return _this.fail(res, err, "sorry, error occurred while saving document");
                    }
                    console.log(result);
                    return conditions.save(true);
                  });
                });
              });
            });
          });
        });
      });
    };

    Docs.prototype.update = function(req, res) {
      return res.send("docs::update");
    };

    Docs.prototype["delete"] = function(req, res) {
      return res.send("docs::delete");
    };

    Docs.prototype.readid = function(req, res) {
      var _this = this;

      return MongoClient.connect("mongodb://localhost:27017/stickypdf", function(err, db) {
        if (err) {
          return _this.fail(res, err, "sorry, error occurred while db connecting");
        }
        return db.collection("docs", function(err, docs) {
          if (err) {
            return _this.fail(res, err, "sorry, error occurred while collection creating");
          }
          return docs.findOne({
            entity_id: ObjectID(req.params.id)
          }, function(err, item) {
            var doc, _i, _ref3, _results;

            if (err) {
              return _this.fail(res, err, "sorry, error occurred while retreiving item");
            }
            doc = item;
            doc.stickers = doc.stickers.filter(function(x) {
              return x.page;
            });
            return res.render("docs_specific", {
              doc: doc,
              pages: (function() {
                _results = [];
                for (var _i = 1, _ref3 = doc.page_cnt; 1 <= _ref3 ? _i <= _ref3 : _i >= _ref3; 1 <= _ref3 ? _i++ : _i--){ _results.push(_i); }
                return _results;
              }).apply(this)
            });
          });
        });
      });
    };

    Docs.prototype.createid = function(req, res) {
      console.log("i am here :)");
      return res.send("docs::createid" + req.params.id + "\n");
    };

    return Docs;

  })(Rest);

  exports.Docs = Docs;

}).call(this);
