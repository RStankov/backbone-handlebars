class window.SubView extends Backbone.View
  className: 'sub-view'
  events:
    click: -> @$el.html 'clicked'

class window.SubViewWithModel extends Backbone.View
  render: -> @$el.html @model

window.app =
  views:
    SubView: Backbone.View.extend
      render: -> @$el.html 'sub-view'

describe "Backbone.Handlebars", ->
  describe "view helper", ->
    renderView = (template) ->
      customViewClass = Backbone.View.extend
        template: Handlebars.compile(template, data: true)
        initialize: -> @renderTemplate()

      new customViewClass

    it "adds the sub-view element", ->
      view = renderView '{{view "SubView"}}'
      view.$('.sub-view').should.not.be.null

    it "keeps the events of the sub-view", ->
      view = renderView '{{view "SubView"}}'
      view.$('.sub-view').click()
      view.$('.sub-view').html().should.eql 'clicked'

    it "can render several sub-views", ->
      view = renderView '{{view "SubView"}}{{view "SubView"}}'
      view.render()
      view.$('.sub-view').length.should.eql 2

    it "throws an error if sub-view doesn't exists", ->
      (-> renderView '{{view "InvalidView"}}').should.throw 'Invalid view name - InvalidView'

    it "searches through nested sub-view names", ->
      view = renderView '{{view "app.views.SubView"}}'
      view.$el.html().should.eql '<div>sub-view</div>'

    it "can pass options to the sub-view", ->
      view = renderView '{{view "SubViewWithModel" model=1 tagName="span" className="sview"}}'
      console.log view.el
      subView = view.$('.sview')
      subView.html().should.eql '1'
      subView.prop('tagName').toLowerCase().should.eql 'span'

    it "can pass a new template for the view"

