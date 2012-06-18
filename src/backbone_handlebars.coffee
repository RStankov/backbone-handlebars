Handlebars.registerHelper 'view', (name, options) ->
  viewClass = window[name]
  view = new viewClass

  parentView = options.data.view
  parentView._toRender ?= []
  parentView._toRender.push view

  new Handlebars.SafeString '<div id="_' + view.cid + '"></div>'


Backbone.View::renderTemplate = (context = {}) ->
  @$el.html @template context, data: {view: this}
  _.each @_toRender, (view) =>
    view.render()
    @$("#_#{view.cid}").replaceWith view.el
