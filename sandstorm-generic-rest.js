var Future = Npm.require("fibers/future");

MongoData = new Mongo.Collection("data");
if (Meteor.isServer) {
  MongoData._ensureIndex({path: 1});
}

if (Meteor.isClient) {
}

function validatePost (req) {
  var permissions = req.headers["x-sandstorm-permissions"];
  return permissions && permissions.indexOf("post") !== -1;
}

function validateGet (req) {
  var permissions = req.headers["x-sandstorm-permissions"];
  return permissions && permissions.indexOf("get") !== -1;
}

if (Meteor.isServer) {
  var Future = Npm.require("fibers/future");
  var Url = Npm.require("url");
  Meteor.startup(function () {
    WebApp.rawConnectHandlers.use(Meteor.bindEnvironment(function (req, res, next) {
      if (req.url.lastIndexOf("/api", 0) === 0) {
        try {
          if (req.method === "POST") {
            if (!validatePost(req)) {
              res.writeHead(403, { "Content-Type": "text/plain" });
              res.end("You do not have permission to POST.");
              return;
            }
            var fut = new Future();
            var bufs = [];
            req.on("data", function (d) { bufs.push(d); });
            req.on("error", function (err) { fut.throw(err); });
            req.on("end", function () {
              var buf = Buffer.concat(bufs);
              fut.return(buf);
            });
            var data = fut.wait();
            // Assume data to be text/plain or json
            MongoData.insert({path: req.url, timestamp: new Date(), data: JSON.parse(data.toString())});
            res.writeHead(200, { "Content-Type": "text/plain" });
            res.end();
          } else if (req.method === "GET") {
            if (!validateGet(req)) {
              res.writeHead(403, { "Content-Type": "text/plain" });
              res.end("You do not have permission to GET.");
              return;
            }
            var url = Url.parse(req.url, true);
            // TODO(soon); look at url.query.timestamp
            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(MongoData.find({path: req.url}).map(function (row) {
              return row.data;
            })));
          } else {
            res.writeHead(404, { "Content-Type": "text/plain" });
            res.end(`404 not found: ${req.url}\n`);
          }
          return;
        } catch (err) {
          console.error(err);
          res.writeHead(500, { "Content-Type": "text/plain" });
          res.end("Internal Server Error");
          return;
        }
      }
      next();
    }));
  });
}
