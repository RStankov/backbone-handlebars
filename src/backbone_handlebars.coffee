Handlebars.registerHelper 'view', (name, options) ->
  viewClass = findViewClass(name)
  view = new viewClass

  parentView = options.data.view
  parentView._toRender ?= []
  parentView._toRender.push view

  new Handlebars.SafeString '<div id="_' + view.cid + '"></div>'

findViewClass = (name) ->
  viewClass = window[name]
  throw "Invalid view name - #{name}" unless viewClass?
  viewClass

Backbone.View::renderTemplate = (context = {}) ->
  @$el.html @template context, data: {view: this}
  _.each @_toRender, (view) =>
    view.render()
    @$("#_#{view.cid}").replaceWith view.el
