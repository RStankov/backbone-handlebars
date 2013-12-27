Backbone.Handlebars
===================

Extension for better integration between [Backbone.js](http://documentcloud.github.com/backbone/) and [Handlebars.js](http://handlebarsjs.com/).

### Features

#### Backbone.View#renderTemplate

```javascript
var PostView = Backbone.View.extend({
  template: Handlebars.compile('<h1>{{title}}</h1><p>{{text}}</p>'),
  render: function() {
    return this.renderTemplate(model);
  }
});

view = new PostView({model: {title: 'Title', text: 'Text'}});
$('body').append(view.render().el);
```

This will just render:

```html
<div>
  <h1>Title</h1>
  <p>Text</p>
</div>
```

Or you can just use the new ```render``` method:

```javascript
var PostView = Backbone.View.extend({
  template: Handlebars.compile('<h1>{{title}}</h1><p>{{text}}</p>'),
  templateData: function() {
    return model;
  }
});

view = new PostView({model: {title: 'Title', text: 'Text'}});
$('body').append(view.render().el);
```

The method ```templateData``` provides data that will be passed to the template for rendering.

You can also pass templateData directly as an object:

```javascript
var PostView = Backbone.View.extend({
  template: Handlebars.compile('<h1>{{title}}</h1><p>{{text}}</p>'),
  templateData: {
    title: 'Title',
    text: 'Text'
  }
});

$('body').append(new PostView.render().el);
```

#### {{view}} helper

The real deal about using ```renderTemplate``` is that you can declare and render sub-views in your templates:

```javascript
var PurchaseButton = Backbone.View.extend({
  tagName: 'button',
  events: {
    'click': 'purchaseProduct'
  },
  purchaseProduct: function() {
    // some code here
  },
  render: function() {
    this.$el.html('Purchase');
  }
});

var ProductView = Backbone.View.extend({
  template: Handlebars.compile('<h1>{{title}}</h1><p>Price: {{price}}</p>{{view "PurchaseButton"}}'),
  render: function() {
    this.renderTemplate(this.model);
  }
});

var view = new ProductView({model: {title: "Product", price: "$0.99"}});
$('body').append(view.render().el);
```

This will just render:

```html
<div>
  <h1>Product</h1>
  <p>Price $0.99</p>
  <button>Purchase</button>
</div>
```

The cool thing is that, ```PurchaseButton```'s ```purchaseProduct``` method will be call when the ```button``` is clicked.
Because ```{{view}}``` keeps the event-bindings of the view it rendered.

#### {{view}} features:

Nested view names.
```javascript
// this will render the app.views.PostView
{{view "app.views.PostView"}}
```

Passing parameters to the view:
```javascript
{{view "PostView" model=post tagName="article"}}
// same as
view = new PostView({model: post, tagName: 'article'});
view.render()
```

Overwriting existing view template:
```javascript
// with given view
var ProductView = Backbone.View.extends({
  tempalte: Handlebars.template('...not...important...now...'),
  render: function() {
    this.renderTemplate();
  }
});
```
```
{{#view "ProductView"}}
  This will be rendered by the renderTemplate of ProductView
{{/view}}
```
This is equivalent of you writing:

```javascript
var view = new ProductView();
view.template = Handlebars.compile('This will be rendered by the renderTemplate of ProductView');
view.render();
```
_Notes_: you will have to use ```renderTemplate``` in your view for this to work.


#### {{views}} helper

In a lot of cases you need to render more than one view. In those cases you can use the ```{{views}}``` helper:

```javascript
var NumberView = Backbone.extend({
  render: function() {
    this.$el.html(this.model);
  }
});

var NumberListsView = Backbone.extend({
  template: Handlebars.compile("<ul>{{views NumberView models tagName}}</ul>"),
  render: function() {
    this.renderTemplate({models: [1,2,3,4,5]});
  }
});

var view = new NumberListsView();
view.render();
```

result in:

```html
<ul>
  <li>1</li>
  <li>2</li>
  <li>3</li>
  <li>4</li>
  <li>5</li>
</ul>
```
The ```{{views}}``` helper have the same features as the ```{{view}}``` helper.

#### Backbone.View#renderedSubViews

If you need to access the rendered sub-views you can do it by calling ```renderedSubViews``` methods.

```javascript
var view = new Backbone.View.extend({
  template: Handlebars.compile('{{view SubView}}{{view SubView}}'),
  render: function() {
    this.renderTemplate();
  }
});

view.render();
view.renderedSubViews(); // returns two instances of SubView
```

#### Bonus feature: killing ghost views

If you have a view which had rendered several sub-views via ```{{view}}``` helpers. When you remove the parent view ```Backbone.Handlebars``` will also remove and clear all references to the sub-views.


```javascript
var view = new Backbone.View.extend({
  template: Handlebars.compile('{{view SubView}}'),
  render: function() {
    this.renderTemplate();
  }
});

view.render();
view.remove(); // this will also call the SubView#remove method
```


### Installing

### Installing

You can get `Backbone.Handlebars` in several ways:

* copy `lib/backbone_handlebars.js` into your project
* copy `src/backbone_handlebars.coffee` into your project if you are using [CoffeeScript](http://http://coffeescript.org/)
* via [Bower](http://bower.io/) - `bower install Backbone.Handlebars` from your console
* adding `Backbone.Handlebars` as your [bower](http://bower.io/) dependency

### Requirements

```
Backbone.js - 0.9.2+
Handlebars - 1.0+
```

### Running the tests

Install bower developer dependencies - ```bower install```.

Just open - ```test/runner.html```.

### Contributing

Every fresh idea and contribution will be highly appreciated.

If you are making changes please do so in the ```coffee``` files. And then compile them with:

```
cake build
```

### License

MIT License.

