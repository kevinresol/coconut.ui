package ;

import tink.state.*;
import js.Browser.*;
import vdom.VDom.*;
import coconut.data.*;
import coconut.Ui.hxx;
using tink.CoreApi;
import coconut.ui.tools.Compare;

// import Test;

class Tests extends haxe.unit.TestCase {

  override function setup() {
    document.body.innerHTML = '';
  }

  static inline function q(s:String)
    return document.querySelector(s);

  static inline function mount(o) {
    document.body.appendChild(o.toElement());
  }

  function testCustom() {
    var s = new State(4);

    mount(hxx('<Example foo={s} bar={s} />'));
    
    assertEquals('4', q('.foo').innerHTML);
    assertEquals('4', q('.bar').innerHTML);

    s.set(5);
    Observable.updateAll();

    assertEquals('5', q('.foo').innerHTML);
    assertEquals('5', q('.bar').innerHTML);
  }
  

  function testModel() {
    var model = new Foo({ foo: 4 });

    var e = hxx('<Example2 {...model} />');
    mount(e);
    
    assertEquals('4', q('.foo').innerHTML);
    assertEquals('4', q('.bar').innerHTML);
    assertEquals('0', q('.baz').innerHTML);

    model.foo = 5;
    Observable.updateAll();
    assertEquals('5', q('.foo').innerHTML);
    assertEquals('5', q('.bar').innerHTML);

    e.baz = 42;
    Observable.updateAll();
    assertEquals('42', q('.baz').innerHTML);
  }  

  function testModelInCustom() {
    
    var variants = [
      function (model:Foo) return hxx('<Example {...model} />'), 
      function (model:Foo) return hxx('<Example {...model} bar={model.bar} />')
    ];
    for (render in variants) {
      var model = new Foo({ foo: 4 });
      mount(render(model));
      
      assertEquals('4', q('.foo').innerHTML);
      assertEquals('4', q('.bar').innerHTML);

      model.foo = 5;
      Observable.updateAll();
      assertEquals('5', q('.foo').innerHTML);
      assertEquals('5', q('.bar').innerHTML);
      
      setup();
    }
  }  

  function testTodo() {
    new TodoListView(null);
    new TodoItemView({ description: 'foo', completed: true, onedit: function (_) {}, ontoggle: function (_) {}});

    var desc = new State('test'),
        done = new State(false);

    mount(hxx('<TodoItemView completed={done} description={desc} onedit={desc.set} ontoggle={done.set} />'));
    var toggle:js.html.InputElement = cast q('input[type="checkbox"]');
    var edit:js.html.InputElement = cast q('input[type="text"]');
    assertFalse(toggle.checked);
    toggle.click();
    assertTrue(done);
    assertEquals('test', edit.value);
    desc.set('foo');
    assertEquals('test', edit.value);
    Observable.updateAll();
    assertEquals('foo', edit.value);
    edit.value = "bar";
    edit.dispatchEvent(new js.html.Event("change"));//gotta love this
    assertEquals('bar', desc);
  }

  function testPropViewReuse() {
    var states = [for (i in 0...10) new State(i)];
    var models = [for (s in states) { foo: s.observe() , bar: s.value }];
    var list = new ListModel({ items: models });
    
    var redraws = Example.redraws;

    var before = Example.created.length;
    mount(hxx('<ExampleListView {...list} />'));
    assertEquals(before + 10, Example.created.length);

    var before = Example.created.length;
    list.items = models;
    Observable.updateAll();
    assertEquals(before, Example.created.length);

    list.items = models.concat(models);
    Observable.updateAll();
    assertEquals(before + 10, Example.created.length);
    assertEquals(redraws + 20, Example.redraws);    

    states[0].set(100);
    Observable.updateAll();
    
    assertEquals(redraws + 22, Example.redraws);    

    list.items = models;
    Observable.updateAll();    

    assertEquals(redraws + 22, Example.redraws);    
 }

  function testModelViewReuse() {

    var models = [for (i in 0...10) new Foo({ foo: i })];
    var list = new ListModel({ items: models });
    
    var redraws = Example2.redraws;

    var before = Example2.created.length;
    mount(hxx('<FooListView {...list} />'));
    assertEquals(before + 10, Example2.created.length);

    var before = Example2.created.length;
    list.items = models;
    Observable.updateAll();
    assertEquals(before, Example2.created.length);

    list.items = models.concat(models);
    Observable.updateAll();
    assertEquals(before + 10, Example2.created.length);
    assertEquals(redraws + 20, Example2.redraws);
    
  }

  static function main() {
    var runner = new haxe.unit.TestRunner();
    runner.add(new Tests());
    travix.Logger.exit(
      if (runner.run()) 0
      else 500
    ); 
  }

}

class FooListView extends coconut.ui.View<ListModel<Foo>> {
  function render() '
    <div class="foo-list">
      <for {i in items}>
        <Example2 {...i} />
      </for>
    </div>
  ';
}