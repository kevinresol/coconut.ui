
class Example2 extends coconut.ui.View<Foo> {
  static public var redraws = 0;
  static public var created(default, null):Array<Example2> = [];
  
  var count:Int = Example2.created.push(this);
  
  @:state public var baz:Int = 0;
  function render() '
    <div>
      {redraws++}
      <span class="foo">{foo}</span>
      <span class="bar">{bar}</span>
      <span class="baz">{baz}</span>
    </div>
  ';
}