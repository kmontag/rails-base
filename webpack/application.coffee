Promise = require 'bluebird'
Regulator = require 'regulatorjs'
$ = require 'jquery'

# Rails unobtrusive JS
window.jQuery = $
require 'jquery-ujs'

new Regulator (name, el) =>
  # foo/baz/bar should invoke `require('controllers/foo/baz').bar`
  directories = name.split '/'
  file = directories.pop()

  $$ = (selector) -> $(el).find selector
  require("controllers/#{directories.join('/')}")[file]?.call el, $$, $(el)
.observe()
