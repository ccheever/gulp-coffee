through        = require "through2"
iced           = require "iced-coffee-script"
gutil          = require "gulp-util"
applySourceMap = require "vinyl-sourcemaps-apply"
path           = require "path"
merge          = require "merge"
{PluginError}  = gutil


gulpIcedCoffee = (options) ->
  replaceExtension = (path) ->
    path = path.replace /\.coffee\.md$/, ".litcoffee"
    path = path.replace /\.iced\.md$/, ".liticed"
    gutil.replaceExtension path, ".js"

  transform = (file, enc, cb) ->
    return cb null, file                                                    if file.isNull()
    return cb new PluginError "gulp-iced-coffee", "Streaming not supported" if file.isStream()

    data     = undefined
    str      = file.contents.toString "utf8"
    dest     = replaceExtension file.path
    defaults =
      bare: false
      header: false
      sourceMap: !!file.sourceMap
      sourceRoot: false
      literate: /\.(litcoffee|coffee\.md|liticed|iced\.md)$/.test file.path
      filename: file.path
      sourceFiles: [file.relative]
      generatedFile: replaceExtension file.relative
    options  = merge defaults, options

    try
      console.log str
      data = iced.compile str, options
    catch err
      return cb new PluginError "gulp-iced-coffee", err
    console.log data

    if data and data.v3SourceMap and file.sourceMap
      applySourceMap file, data.v3SourceMap
      file.contents = new Buffer data.js
    else
      file.contents = new Buffer data

    file.path = dest
    cb null, file

  through.obj transform


module.exports = gulpIcedCoffee
