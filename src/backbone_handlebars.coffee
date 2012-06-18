Handlebars.registerHelper 'view', (name, options) ->
  viewClass = window[name]
  view = new viewClass

  new Handlebars.SafeString '<' + view.tagName + ' class="' + view.className + '"></' + view.tagName + '>'

