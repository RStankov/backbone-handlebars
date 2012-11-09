window.test =
  views:
    SubView: Backbone.View.extend
      className: 'sub-view'

    SubViewWithEvents: Backbone.View.extend
      className: 'sub-view'
      events:
        click: -> @$el.html 'clicked'

    SubViewExpectingTemplate: Backbone.View.extend
      className: 'sub-view'
      template: Handlebars.compile 'text'
      render: ->
        @$el.html @template(@model)

    SubViewWithModel: Backbone.View.extend
      className: 'sub-view'
      render: ->
        @$el.html @model

    SubViewWithModelNames: Backbone.View.extend
      render: ->
        @$el.html @model.get('name')

describe "Backbone.Handlebars", ->
  _view = null

  afterEach ->
    _view.remove() if _view
    _view = null

  renderView = (template = '', context = {}) ->
    customViewClass = Backbone.View.extend
      template: if typeof template is 'function' then template else Handlebars.compile(template)
      initialize: -> @renderTemplate(context)

    _view = new customViewClass

  describe "View#render", ->
    it "doesn't render anything if there isn't a template", ->
      view = new Backbone.View
      view.render()
      view.$el.html().should.eql ''

    it "renders view template by default", ->
      viewClass = Backbone.View.extend
        template: Handlebars.compile 'template text'

      view = new viewClass
      view.render()
      view.$el.html().should.eql 'template text'

    it "takes the context from templateData method", ->
      viewClass = Backbone.View.extend
        template: Handlebars.compile 'Hi {{name}}'
        templateData: -> name: 'there'

      view = new viewClass
      view.render()
      view.$el.html().should.eql 'Hi there'

    it "can use templateData directly if is not a method", ->
      viewClass = Backbone.View.extend
        template: Handlebars.compile 'Hi {{name}}'
        templateData: {name: 'there'}

      view = new viewClass
      view.render()
      view.$el.html().should.eql 'Hi there'

    it "returns reference to the view", ->
      view = new Backbone.View
      view.render().should.eql view

  describe "View#renderTemplate", ->
    it "renders the template of the view", ->
      view = renderView 'template text'
      view.$el.html().should.eql 'template text'

    it "accepts template context as argument", ->
      view = renderView '{{a}} + {{b}} = {{c}}', a: 1, b: 2, c: 3
      view.$el.html().should.eql '1 + 2 = 3'

    it "returns the view", ->
      view = renderView()
      view.renderTemplate().should.eql view

  describe "View#renderTemplate with {{view}} helper", ->
    it "renders sub-view element", ->
      view = renderView '{{view "test.views.SubView"}}'
      view.$('.sub-view').should.not.be.null

    it "works with precompiled templates", ->
      view = renderView Handlebars.compile '{{view  "test.views.SubView"}}'
      view.$('.sub-view').should.not.be.null

    it "keeps the events of the sub-view", ->
      view = renderView '{{view "test.views.SubViewWithEvents"}}'

      subViewEl = view.$('.sub-view')
      subViewEl.click()
      subViewEl.html().should.eql 'clicked'

    it "can render several sub-views", ->
      view = renderView '{{view "test.views.SubView"}}{{view "test.views.SubView"}}'
      view.$('.sub-view').length.should.eql 2

    it "throws an error if sub-view doesn't exists", ->
      (-> renderView '{{view "InvalidView"}}').should.throw 'Invalid view name - InvalidView'

    it "can pass options to the sub-view", ->
      view = renderView '{{view "test.views.SubViewWithModel" model=1 tagName="span" className="sview"}}'

      subViewEl = view.$('.sview')
      subViewEl.html().should.eql '1'
      subViewEl.prop('tagName').toLowerCase().should.eql 'span'

    it "can pass a new template for the view", ->
      view = renderView '{{#view "test.views.SubViewExpectingTemplate"}}custom template{{/view}} '
      view.$('.sub-view').html().should.eql 'custom template'

    it "removes sub-views via view.remove() on re-render", ->
      view = renderView '{{view "test.views.SubView"}}{{view "test.views.SubView"}}'

      removeCounter = 0
      for subView in view.renderedSubViews()
        subView.remove = ->
          removeCounter += 1

      view.renderTemplate()

      removeCounter.should.eql 2

    it "removes sub-views via view.remove() on view removal", ->
      view = renderView '{{view "test.views.SubView"}}{{view "test.views.SubView"}}'

      removeCounter = 0
      for subView in view.renderedSubViews()
        subView.remove = ->
          removeCounter += 1

      view.remove()

      removeCounter.should.eql 2

  describe "View#renderTemplate with {{views}} helper", ->
    it "renders an array of views by given collection of models", ->
      view = renderView '{{views "test.views.SubView" collection}}', collection: [1..4]
      view.$('.sub-view').length.should.eql 4

    it "works with precompiled templates", ->
      view = renderView Handlebars.compile('{{views "test.views.SubView" collection}}'), collection: [1..4]
      view.$('.sub-view').length.should.eql 4

    it "can pass a new template for the view", ->
      view = renderView '[{{#views "test.views.SubViewExpectingTemplate" collection}}{{this}}{{/views}}]', collection: [1..4]
      view.$el.text().should.eql '[1234]'

    it "can pass options to the sub-view", ->
      view = renderView '{{views "test.views.SubViewWithModel" collection className="inner-view"}}', collection: [1..4]
      view.$('.inner-view').length.should.eql 4

    it "can render Backbone.Collection instances", ->
      collection = new Backbone.Collection
      collection.add name: '1'
      collection.add name: '2'

      view = renderView '[{{views "test.views.SubViewWithModelNames" collection}}]', {collection}
      view.$el.text().should.eql '[12]'

    it "can render any object which implements map", ->
      object =
        values: [1,2]
        map: (callback) -> _.map @values, callback

      view = renderView '[{{views "test.views.SubViewWithModel" collection}}]', collection: object
      view.$el.text().should.eql '[12]'
