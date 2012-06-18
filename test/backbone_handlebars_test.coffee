class window.SubView extends Backbone.View
  className: '.sub-view'

describe "Backbone.Handlebars", ->
  describe "view helper", ->
    it "adds the sub-view element", ->
      class TestView extends Backbone.View
        template: Handlebars.compile '{{view "SubView"}}'

        render: ->
          @$el.html @template()

      view = new TestView
      view.render()
      view.$('.sub-view').should.not.be.null
