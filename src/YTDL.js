var ytdl = require("ytdl-core");

exports._downloadAudio = function(url, cb) {
  var stream = ytdl(url, {
    filter: "audioonly"
  });
  stream.on("info", function(info, format) {
    var buffers = [];
    stream.on("data", function(data) {
      buffers.push(data);
    });
    stream.on("end", function() {
      cb({
        title: info.title + "." + format.container,
        buffer: Buffer.concat(buffers)
      })();
    });
  });
};
