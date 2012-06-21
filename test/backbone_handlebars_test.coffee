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
        @$el.html @template({})

    SubViewWithModel: Backbone.View.extend
      className: 'sub-view'
      render: ->
        @$el.html @model

describe "Backbone.Handlebars", ->
  _view = null

  afterEach ->
    _view.remove() if _view
    _view = null

  renderView = (template = '', context = {}) ->
    customViewClass = Backbone.View.extend
      template: Handlebars.compile template
      initialize: -> @renderTemplate(context)

    _view = new customViewClass

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
