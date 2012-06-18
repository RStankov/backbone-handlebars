class window.SubView extends Backbone.View
  className: 'sub-view'

window.app =
  views:
    SubView: Backbone.View.extend
      className: 'sub-view'

      render: ->
        @$el.html 'sub-view text'


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

    it "throws an error if sub-view doesn't exists", ->
      class NotExistingView extends TestView
        template: Handlebars.compile('{{view "InvalidView"}}', data: true)

      (->
        view = new NotExistingView
        view.render()
      ).should.throw 'Invalid view name - InvalidView'

    it "searches through nested sub-view names", ->
      class NestedTestView extends TestView
        template: Handlebars.compile('{{view "app.views.SubView"}}', data: true)

      view = new NestedTestView
      view.render()
      view.$('.sub-view').html().should.eql 'sub-view text'

    it "can pass options to the sub-view"
    it "can pass a new template for the view"

