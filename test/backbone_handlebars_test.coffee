class window.SubView extends Backbone.View
  className: 'sub-view'

describe "Backbone.Handlebars", ->
  describe "view helper", ->
    class TestView extends Backbone.View
      template: Handlebars.compile('{{view "SubView"}}', data: true)

      render: -> @renderTemplate()

    it "adds the sub-view element", ->
      view = new TestView
      view.render()
      view.$('.sub-view').should.not.be.null

    it "keeps the events of the sub-view", ->
      window.SubView::events = {click: -> @$el.html('clicked')}

      view = new TestView
      view.render()
      view.$('.sub-view').click()
      view.$('.sub-view').html().should.eql 'clicked'

    it "can render several sub-views", ->
      class DoubleTestView extends TestView
        template: Handlebars.compile('{{view "SubView"}}{{view "SubView"}}', data: true)

      view = new DoubleTestView
      view.render()
      view.$('.sub-view').length.should.eql 2

    it "searches through nested sub-view names"
    it "can pass options to the sub-view"
    it "can pass a new template for the view"

