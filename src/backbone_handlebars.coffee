Handlebars.registerHelper 'view', (name, options) ->
  viewClass = window[name]
  view = new viewClass

  parentView = options.data.view
  parentView._toRender = view

  new Handlebars.SafeString '<div id="view-' + view.cid + '"></div>'


Backbone.View::renderTemplate = (context = {}) ->
  @$el.html @template context, data: {view: this}
  view = @_toRender
  view.render()
  @$("#view-#{view.cid}").replaceWith view.el
