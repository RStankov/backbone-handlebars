Handlebars.registerHelper 'view', (name, options) ->
  viewClass = findViewClass(name)
  view = new viewClass options.hash

  view.template = options.fn if options.fn?

  parentView = options.data.view
  parentView._toRender ?= []
  parentView._toRender.push view

  new Handlebars.SafeString '<div id="_' + view.cid + '"></div>'

findViewClass = (name) ->
  viewClass = _.inject (name || '').split('.'), ((memo, fragment) -> memo[fragment] || false), window
  throw "Invalid view name - #{name}" unless viewClass
  viewClass

Backbone.View::renderTemplate = (context = {}) ->
  _.invoke @renderedChildren, 'remove' if @renderedChildren

  @$el.html @template context, data: {view: this}

  @renderedChildren = _.map @_toRender, (view) =>

    view.render()
    @$("#_#{view.cid}").replaceWith view.el
    view

  delete @_toRender

_remove = Backbone.View::remove
Backbone.View::remove = ->
  _.invoke @renderedChildren, 'remove' if @renderedChildren
  _remove.apply this, arguments

_compile = Handlebars.compile
Handlebars.compile = (template, options = {})->
  options.data = true
  _compile.call(this, template, options)

