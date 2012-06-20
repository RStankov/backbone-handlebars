BH =
  postponed: {}
  rendered: {}

  postponeRender: (parentView, subView) ->
    cid = parentView.cid

    @postponed[cid] ?= []
    @postponed[cid].push subView

  renderPostponed: (parentView) ->
    cid = parentView.cid

    @rendered[cid] = _.map @postponed[parentView.cid], (view) ->
      view.render()
      parentView.$("#_#{view.cid}").replaceWith view.el
      view

    delete @postponed[cid]

  clearRendered: (parentView) ->
    cid = parentView.cid

    if @rendered[cid]
      _.invoke @rendered[cid], 'remove'
      delete @rendered[cid]

Handlebars.registerHelper 'view', (name, options) ->
  viewClass = _.inject (name || '').split('.'), ((memo, fragment) -> memo[fragment] || false), window
  throw "Invalid view name - #{name}" unless viewClass

  view = new viewClass options.hash
  view.template = options.fn if options.fn?

  BH.postponeRender options.data.view, view

  new Handlebars.SafeString '<div id="_' + view.cid + '"></div>'

_compile = Handlebars.compile
Handlebars.compile = (template, options = {}) ->
  options.data = true
  _compile.call this, template, options

Backbone.View::renderTemplate = (context = {}) ->
  BH.clearRendered this

  @$el.html @template context, data: {view: this}

  BH.renderPostponed this

Backbone.View::renderedSubViews = ->
  BH.rendered[@cid]

_remove = Backbone.View::remove
Backbone.View::remove = ->
  BH.clearRendered this
  _remove.apply this, arguments

Backbone.Handlebars = BH

