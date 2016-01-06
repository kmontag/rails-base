#= require bluebird
#
#= require jquery
#= require jquery-ujs
#
#= require regulator
#
#= require underscore
#= require underscore.string
#
#= require_tree .

new Regulator (name, el) =>
  # When we see foo/bar, we convert to window.Foo['bar']
  directories = name.split('/')
  file = directories.pop()
  path = _.map directories, (d) -> s(d).classify().value()

  root = this
  root = root?[name] for name in path

  $$ = (selector) -> $(el).find selector
  root?[file]?.call el, $$, $(el)
.observe()
