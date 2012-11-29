###
 Backbone Handlebars

 Author: Radoslav Stankov
 Project site: https://github.com/RStankov/backbone-handlebars
 Licensed under the MIT License.
###

BH =
  VERSION: '1.0.0'

  postponed: {}
  rendered: {}

  postponeRender: (name, options, parentView) ->
    viewClass = _.inject (name || '').split('.'), ((memo, fragment) -> memo[fragment] || false), window
    throw "Invalid view name - #{name}" unless viewClass

    view = new viewClass options.hash
    view.template = options.fn if options.fn?

    cid = (parentView || options.data.view).cid

    @postponed[cid] ?= []
    @postponed[cid].push view

    '<div id="_' + view.cid + '"></div>'

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
  new Handlebars.SafeString BH.postponeRender(name, options, @_parentView)

Handlebars.registerHelper 'views', (name, models, options) ->
  callback = (model) =>
    options.hash.model = model
    BH.postponeRender name, options, @_parentView

  markers = if 'map' of models
    models.map callback
  else
    _.map callback

  new Handlebars.SafeString markers.join('')

_compile = Handlebars.compile
Handlebars.compile = (template, options = {}) ->
  options.data = true
  _compile.call this, template, options

Backbone.View::renderTemplate = (context = {}) ->
  BH.clearRendered this
  context = _.clone context
  context._parentView = this
  @$el.html @template context, data: {view: this}
  BH.renderPostponed this
  this

Backbone.View::renderedSubViews = ->
  BH.rendered[@cid]

_remove = Backbone.View::remove
Backbone.View::remove = ->
  BH.clearRendered this
  _remove.apply this, arguments

Backbone.View::render = ->
  if @template
    @renderTemplate if typeof @templateData is 'function' then @templateData() else @templateData
  this

Backbone.View::templateData = -> {}

Backbone.Handlebars = BH

