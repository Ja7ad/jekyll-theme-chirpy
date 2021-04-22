---
title: Golang Design Patterns Code
author: Javad Rajabzade
date: 2021-04-21 15:33:00 +0800
categories: [Golang, Codes]
tags: [golang, go, patterns, codes]
---

# Behavioral Patterns
---

## Design Pattern Command

![Design Pattern Command](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19302.png)
_Design Pattern Command_

```go
import (
    "fmt"
)

//Command type
type Command interface {
    Execute()
}

//BankClient is Invoker
type BankClient struct {
    putCommand Command
    getCommand Command
}

//PutMoney runs the putCommand
func (bc BankClient) PutMoney() {
    bc.putCommand.Execute()
}

//GetMoney runs the getCommand
func (bc BankClient) GetMoney() {
    bc.getCommand.Execute()
}

//Bank is Receiver
type Bank struct{}

func (b Bank) giveMoney() {
    fmt.Println("money to the client")
}

func (b Bank) receiveMoney() {
    fmt.Println("money from the client")
}

//PutCommand is ConcreteCommand
type PutCommand struct {
    bank Bank
}

//Execute command
func (pc PutCommand) Execute() {
    pc.bank.receiveMoney()
}

//GetCommand is ConcreteCommand
type GetCommand struct {
    bank Bank
}

//Execute command
func (gc GetCommand) Execute() {
    gc.bank.giveMoney()
}

//Client
bank := Bank{}
cPut := PutCommand{bank}
cGet := GetCommand{bank}
client := BankClient{cPut, cGet}
client.GetMoney()
//printed: money to the client
client.PutMoney()
//printed: money from the client
```

## Design Pattern Interpreter

![Design Pattern Interpreter](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19303.png)
_Design Pattern Interpreter_

```go
import (
    "fmt"
)

//Expression is AbstractExpression
type Expression interface {
    Interpret(i int) bool
}

//DivExpression is TerminalExpression
type DivExpression struct {
    divider int
}

//Interpret func calculates expression
func (e DivExpression) Interpret(i int) bool {
    return i%e.divider == 0
}

//OrExpression is NonterminalExpression
type OrExpression struct {
    exp1 Expression
    exp2 Expression
}

//Interpret func calculates expression
func (e OrExpression) Interpret(i int) bool {
    return e.exp1.Interpret(i) || e.exp2.Interpret(i)
}

//AndExpression is NonterminalExpression
type AndExpression struct {
    exp1 Expression
    exp2 Expression
}

//Interpret func calculates expression
func (e AndExpression) Interpret(i int) bool {
    return e.exp1.Interpret(i) && e.exp2.Interpret(i)
}

//Client
divExp5 := DivExpression{5}
divExp7 := DivExpression{7}
orExp := OrExpression{
    divExp5, divExp7}
andExp := AndExpression{
    divExp5, divExp7}

//21 is divided by 7 or 5?
result1 := orExp.Interpret(21)
//result1 is true

//21 is divided by 7 and 5?
result2 := andExp.Interpret(21)
//result2 is false

//35 is divided by 7 and 5?
result3 := andExp.Interpret(35)
//result3 is true

fmt.Println(result1)
fmt.Println(result2)
fmt.Println(result3)
```
## Design Pattern Iterator

![Design Pattern Iterator](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19304.png)
_Design Pattern Iterator_

```go
import (
    "fmt"
)

//IntIterator is Iterator
type IntIterator interface {
    First()
    Next()
    IsDone() bool
    CurrentItem() int
}

//Numbers is ConcreteAggregate
type Numbers struct {
    Data []int
}

//GetIterator return Iterator
func (n Numbers) GetIterator() IntIterator {
    return &Iterator{n, 0}
}

//Iterator is ConcreteIterator
type Iterator struct {
    _numbers Numbers
    _index   int
}

//First positions the iterator to the first element
func (i *Iterator) First() {
    i._index = 0
}

//Next advances the current element
func (i *Iterator) Next() {
    i._index++
}

//IsDone checks whether the index refers to an element withinthe List
func (i *Iterator) IsDone() bool {
    return i._index >= len(i._numbers.Data)
}

//CurrentItem returns the item at the current index
func (i *Iterator) CurrentItem() int {
    return i._numbers.Data[i._index]
}

//Client
numbers := Numbers{[]int{2, 3, 5, 7, 11}}
iterator := numbers.GetIterator()
sum := 0
for iterator.First(); !iterator.IsDone(); iterator.Next() {
    sum += iterator.CurrentItem()
}
//sum is 28
```

## Design Pattern Mediator

![Design Pattern Mediator](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19305.png)
_Design Pattern Mediator_

```go
//Mediator defines an interface for communicating with Colleague objects
type Mediator interface {
    Sync(switcher *Switcher)
    Add(switcher *Switcher)
}

//Switcher is Colleague
type Switcher struct {
    State     bool
    _mediator Mediator
}

//NewSwitcher creates a new Switcher
func NewSwitcher(mediator Mediator) *Switcher {
    switcher := &Switcher{false, mediator}
    mediator.Add(switcher)
    return switcher
}

//Sync starts the mediator Sync function
func (s Switcher) Sync() {
    s._mediator.Sync(&s)
}

//SyncMediator is ConcreteMediator
type SyncMediator struct {
    Switchers []*Switcher
}

//Sync synchronizes the state of all Colleague objects
func (sm *SyncMediator) Sync(switcher *Switcher) {
    for _, curSwitcher := range sm.Switchers {
        curSwitcher.State = switcher.State
    }
}

//Add append Colleague to the Mediator list
func (sm *SyncMediator) Add(switcher *Switcher) {
    sm.Switchers = append(sm.Switchers, switcher)
}

//Client
mediator := &SyncMediator{[]*Switcher{}}
switcher1 := NewSwitcher(mediator)
switcher2 := NewSwitcher(mediator)
switcher3 := NewSwitcher(mediator)

switcher1.State = true
state2 := switcher2.State
//state2 is false
state3 := switcher3.State
//state3 is false

switcher1.Sync()
state2 = switcher2.State
//state2 is true
state3 = switcher3.State
//state3 is true
```

## Design Pattern Memento

![Design Pattern Memento](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19306.png)
_Design Pattern Memento_

```go
//Point is State
type Point struct {
    X, Y int
}

//Memento contains a State field
type Memento struct {
    _state Point
}

func (m Memento) getState() Point {
    return m._state
}

//Shape is Originator
type Shape struct {
    Position Point
}

//Move Shape
func (s *Shape) Move(left, top int) {
    s.Position.X += left
    s.Position.Y += top
}

func (s *Shape) getMemento() Memento {
    state := Point{
    s.Position.X, s.Position.Y}
    return Memento{state}
}

func (s *Shape) setMemento(memento Memento) {
    s.Position = memento.getState()
}

//ShapeHelper is Caretaker
type ShapeHelper struct {
    _shape *Shape
    _stack []Memento
}

//NewShapeHelper creates a new ShapeHelper
func NewShapeHelper(shape *Shape) ShapeHelper {
    return ShapeHelper{shape, []Memento{}}
}

//Move Shape and save prior state
func (sh *ShapeHelper) Move(left, top int) {
    sh._stack = append(
        sh._stack, sh._shape.getMemento())
    sh._shape.Move(left, top)
}

//Undo move shape to previous position
func (sh *ShapeHelper) Undo() {
    l := len(sh._stack)
    if l > 0 {
        memento := sh._stack[l-1]
        sh._stack = sh._stack[:l-1]
        sh._shape.setMemento(memento)
    }
}

//Client
shape := &Shape{}
helper := NewShapeHelper(shape)

helper.Move(2, 3)
//shape.Position is (2, 3)
helper.Move(-5, 4)
//shape.Position is (-3, 7)

helper.Undo()
//shape.Position is (2, 3)
helper.Undo()
//shape.Position is (0, 0)
```

## Design Pattern Observer

![Design Pattern Observer](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19307.png)
_Design Pattern Observer_

```go
import (
    "fmt"
)

type observer interface {
    update(state string)
}

//TextObserver is ConcreteObserver
type TextObserver struct {
    _name string
}

func (t TextObserver) update(state string) {
    fmt.Println(t._name + ": " + state)
}

//TestSubject is Subject
type TestSubject struct {
    _observers []observer
}

//Attach adds an observer
func (ts *TestSubject) Attach(observer observer) {
    ts._observers = append(ts._observers, observer)
}

//Detach removes an observer
func (ts *TestSubject) Detach(observer observer) {
    index := 0
    for i := range ts._observers {
        if ts._observers[i] == observer {
            index = i
            break
        }
    }
    ts._observers = append(ts._observers[0:index], ts._observers[index+1:]...)
}

func (ts TestSubject) notify(state string) {
    for _, observer := range ts._observers {
        observer.update(state)
    }
}

//TextEdit is ConcreteSubject
type TextEdit struct {
    TestSubject
    Text string
}

//SetText changes the text and informs observers
func (te TextEdit) SetText(text string) {
    te.Text = text
    te.TestSubject.notify(text)
}

//Client
observer1 := TextObserver{"IObserver #1"}
observer2 := TextObserver{"IObserver #2"}

textEdit := TextEdit{}
textEdit.Attach(observer1)
textEdit.Attach(observer2)

textEdit.SetText("test text")
//printed:
//IObserver #1: test text
//IObserver #2: test text
```

## Design Pattern State

![Design Pattern State](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19308.png)
_Design Pattern State_

```go
import (
    "fmt"
)

type state interface {
    open(c *Connection)
    close(c *Connection)
}

//CloseState is ConcreteState
type CloseState struct{}

func (cs CloseState) open(c *Connection) {
    fmt.Println("open the connection")
    c.setState(OpenState{})
}

func (cs CloseState) close(c *Connection) {
    fmt.Println("connection is already closed")
}

//OpenState is ConcreteState
type OpenState struct{}

func (os OpenState) open(c *Connection) {
    fmt.Println("connection is already open")
}

func (os OpenState) close(c *Connection) {
    fmt.Println("close the connection")
    c.setState(CloseState{})
}

//Connection is Context
type Connection struct {
    _state state
}

//Open connection
func (c *Connection) Open() {
    c._state.open(c)
}

//Close connection
func (c *Connection) Close() {
    c._state.close(c)
}

func (c *Connection) setState(state state) {
    c._state = state
}

//Client
con := Connection{CloseState{}}
con.Open()
//printed: open the connection
con.Open()
//printed: connection is already open
con.Close()
//printed: close the connection
con.Close()
//printed: connection is already closed
```

## Design Pattern Strategy

![Design Pattern Strategy](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19309.png)
_Design Pattern Strategy_

```go
import (
    "fmt"
)

//Strategy with integer operation
type Strategy interface {
    DoOperation(a int, b int) int
}

//AddStrategy is ConcreteStrategy
type AddStrategy struct{}

//DoOperation is integer addition function
func (s AddStrategy) DoOperation(a int, b int) int {
    return a + b
}

//SubstractStrategy is ConcreteStrategy
type SubstractStrategy struct{}

//DoOperation is integer subtraction function
func (s SubstractStrategy) DoOperation(a int, b int) int {
    return a - b
}

//Calc is Context
type Calc struct {
    _strategy Strategy
}

//Execute current strategy
func (c Calc) Execute(a int, b int) int {
    if c._strategy == nil {
        return 0
    }

    return c._strategy.DoOperation(a, b)
}

//SetStrategy changes the current strategy
func (c *Calc) SetStrategy(strategy Strategy) {
    c._strategy = strategy
}

//Client
calc := Calc{}
result1 := calc.Execute(5, 3)
//result1 is 0

calc.SetStrategy(AddStrategy{})
result2 := calc.Execute(5, 3)
//result2 is 8

calc.SetStrategy(SubstractStrategy{})
result3 := calc.Execute(5, 3)
//result3 is 2

fmt.Println(result1)
fmt.Println(result2)
fmt.Println(result3)
```

## Design Pattern Visitor

![Design Pattern Visitor](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19311.png)
_Design Pattern Visitor_

```go
import (
    "fmt"
    "strconv"
)

//Element interface
type Element interface {
    Accept(v CarVisitor)
}

//Engine is ConcreteElement
type Engine struct{}

//Accept operation that takes a visitor as an argument
func (e Engine) Accept(v CarVisitor) {
    v.visitEngine(e)
}

//Wheel is ConcreteElement
type Wheel struct {
    Number int
}

//Accept operation
func (w Wheel) Accept(v CarVisitor) {
    v.visitWheel(w)
}

//Car is ConcreteElement
type Car struct {
    _items []Element
}

//Accept operation
func (c Car) Accept(v CarVisitor) {
    for _, e := range c._items {
        e.Accept(v)
    }
    v.visitCar(c)
}

//CarVisitor is Visitor
type CarVisitor interface {
    visitEngine(engine Engine)
    visitWheel(wheel Wheel)
    visitCar(car Car)
}

//TestCarVisitor is ConcreteVisitor
type TestCarVisitor struct{}

func (v TestCarVisitor) visitEngine(engine Engine) {
    fmt.Println("test engine")
}

func (v TestCarVisitor) visitWheel(wheel Wheel) {
    fmt.Println("test wheel #" +
        strconv.Itoa(wheel.Number))
}

func (v TestCarVisitor) visitCar(car Car) {
    fmt.Println("test car")
}

//RepairCarVisitor is ConcreteVisitor
type RepairCarVisitor struct{}

func (v RepairCarVisitor) visitEngine(engine Engine) {
    fmt.Println("repair engine")
}

func (v RepairCarVisitor) visitWheel(wheel Wheel) {
    fmt.Println("repair wheel #" +
        strconv.Itoa(wheel.Number))
}

func (v RepairCarVisitor) visitCar(car Car) {
    fmt.Println("repair car")
}

//Client
car := Car{[]Element{
        Engine{},
        Wheel{1},
        Wheel{2},
        Wheel{3},
        Wheel{4},
}}
v1 := TestCarVisitor{}
v2 := RepairCarVisitor{}

car.Accept(v1)
car.Accept(v2)
```

# Creational Patterns
---

## Design Pattern Abstract Factory

![Design Pattern Abstract Factory](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19101.png)
_Design Pattern Abstract Factory_

```go
import (
    "fmt"
)

//ProductA is abstract product A
type ProductA interface {
    TestA()
}

//ProductB is abstract product B
type ProductB interface {
    TestB()
}

//Factory is abstract factory
type Factory interface {
    CreateA() ProductA
    CreateB() ProductB
}

//ProductA1 is concrete product A1
type ProductA1 struct{}

//TestA is implementation of the ProductA interface method
func (p ProductA1) TestA() {
    fmt.Println("test A1")
}

//ProductB1 is concrete product B1
type ProductB1 struct{}

//TestB is implementation of the ProductB interface method
func (p ProductB1) TestB() {
    fmt.Println("test B1")
}

//ProductA2 is concrete product A2
type ProductA2 struct{}

//TestA is implementation of the ProductA interface method
func (p ProductA2) TestA() {
    fmt.Println("test A2")
}

//ProductB2 is concrete product B2
type ProductB2 struct{}

//TestB is implementation of the ProductB interface method
func (p ProductB2) TestB() {
    fmt.Println("test B2")
}

//Factory1 is concrete factory 1
type Factory1 struct{}

//CreateA is implementation of the Factory interface method
func (f Factory1) CreateA() ProductA {
    return ProductA1{}
}

//CreateB is implementation of the Factory interface method
func (f Factory1) CreateB() ProductB {
    return ProductB1{}
}

//Factory2 is concrete factory 2
type Factory2 struct{}

//CreateA is implementation of the Factory interface method
func (f Factory2) CreateA() ProductA {
    return ProductA2{}
}

//CreateB is implementation of the Factory interface method
func (f Factory2) CreateB() ProductB {
    return ProductB2{}
}

//client code:

//TestFactory creates and tests factories
func TestFactory(factory Factory) {
    productA := factory.CreateA()
    productB := factory.CreateB()
    productA.TestA()
    productB.TestB()
}

TestFactory(Factory1{})
//printed: test A1
//         test B1
TestFactory(Factory2{})
//printed: test A2
//         test B2
```

## Design Pattern Builder

![Design Pattern Builder](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19102.png)
_Design Pattern Builder_

```go
import (
    "fmt"
)

//TextWorker is AbstractBuilder
type TextWorker interface {
    AddText(text string)
    AddNewLine(text string)
}

//TextBuilder is ConcreteBuilder 1
type TextBuilder struct {
    Text string
}

//AddText adds text to the current line 
func (tb *TextBuilder) AddText(text string) {
    tb.Text += text
}

//AddNewLine adds new line 
func (tb *TextBuilder) AddNewLine(text string) {
    tb.Text += ("\n" + text)
}

//HTMLBuilder is ConcreteBuilder 2
type HTMLBuilder struct {
    HTML string
}

//AddText adds span to the current line 
func (tb *HTMLBuilder) AddText(text string) {
    tb.HTML += ("<span>" + text + "</span>")
}

//AddNewLine adds new line 
func (tb *HTMLBuilder) AddNewLine(text string) {
    tb.HTML += "<br/>\n"
    tb.AddText(text)
}

//TextMaker is Director
type TextMaker struct{}

//MakeText fills the text
func (tm TextMaker) MakeText(textBuilder TextWorker) {
    textBuilder.AddText("line 1")
    textBuilder.AddNewLine("line 2")
}

//Client
textMaker := TextMaker{}

textBuilder := TextBuilder{}
textMaker.MakeText(&textBuilder)
text := textBuilder.Text
//text: line 1
//      line 2

htmlBuilder := HTMLBuilder{}
textMaker.MakeText(&htmlBuilder)
html := htmlBuilder.HTML
//html: <span>line 1</span><br/>
//      <span>line 2</span>

fmt.Println(text)
fmt.Println(html)
```

## Design Pattern Factory Method

![Design Pattern Factory Method](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19103.png)
_Design Pattern Factory Method_

```go
import (
    "fmt"
)

//Employee is Product
type Employee interface {
    Test()
}

//Booker is ConcreteProduct
type Booker struct{}

//Test is Employee method
func (e Booker) Test() {
    fmt.Println("Booker")
}

//Manager is ConcreteProduct
type Manager struct{}

//Test is Manager method
func (e Manager) Test() {
    fmt.Println("Manager")
}

//BookerCreator is ConcreteCreator
type BookerCreator struct{}

//CreateEmployee creates an Booker
func (c BookerCreator) CreateEmployee() Employee {
    return Booker{}
}

//ManagerCreator is ConcreteCreator
type ManagerCreator struct {}

//CreateEmployee creates an Manager
func (c ManagerCreator) CreateEmployee() Employee {
    return Manager{}
}

//Client
booker := BookerCreator{}.CreateEmployee()
booker.Test()
//printed: Booker

manager := ManagerCreator{}.CreateEmployee()
manager.Test()
//printed: Manager
```

## Design Pattern Prototype

![Design Pattern Prototype](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19104.png)
_Design Pattern Prototype_

```go
import (
    "fmt"
)

//Shape is Prototype
type Shape interface {
    Clone() Shape
}

//Square is ConcretePrototype
type Square struct {
    LineCount int
}

//Clone creates a copy of the square
func (s Square) Clone() Shape {
    return Square{s.LineCount}
}

//Client

//ShapeMaker contains a Shape
type ShapeMaker struct {
    Shape Shape
}

//MakeShape creates a copy of the Shape
func (sm ShapeMaker) MakeShape() Shape {
    return sm.Shape.Clone()
}

square := Square{4}
maker := ShapeMaker{square}

square1 := maker.MakeShape()
square2 := maker.MakeShape()

fmt.Println(square1)
fmt.Println(square2)
```

## Design Pattern Singleton

![Design Pattern Singleton](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19105.png)
_Design Pattern Singleton_

```go
package settings

//Settings is simple struct
type Settings struct {
    Port int
    Host string
}

var instance *Settings

//GetInstance returns a single instance of the settings
func GetInstance() *Settings {
    if instance == nil {
        instance = &Settings{} // <--- NOT THREAD SAFE
    }
    return instance
}

//Client
import (
    "fmt"
    Settings "../CreationalPatterns/Singleton"
)

settings := Settings.GetInstance()

settings.Host = "192.168.100.1"
settings.Port = 33

settings1 := Settings.GetInstance()
//settings1.Port is 33
```

# Structural Patterns
---

## Design Pattern Adapter (composition)

![Design Pattern Adapter](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19201.png)
_Design Pattern Adapter_

```go
import (
    "fmt"
    "strings"
)

//StringList is Adaptee
type StringList struct {
    rows []string
}

func (sl StringList) getString() string {
    return strings.Join(sl.rows, "\n")
}

func (sl *StringList) add(value string) {
    sl.rows = append(sl.rows, value)
}

//TextAdapter is Adapter
type TextAdapter struct {
    RowList StringList
}

func (ta TextAdapter) getText() string {
    return ta.RowList.getString()
}

func getTextAdapter() TextAdapter {
    rowList := StringList{}
    rowList.add("line 1")
    rowList.add("line 2")
    adapter := TextAdapter{rowList}
    return adapter
}

//Client
adapter := getTextAdapter()
text := adapter.getText()
//text: line 1
//      line 2

fmt.Println(text)
```

## Design Pattern Adapter (inheritance)

![Design Pattern Adapter](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19202.png)
_Design Pattern Adapter_

```go
import (
    "fmt"
    "strings"
)

//StringList is Adaptee
type StringList struct {
    rows []string
}

func (sl StringList) getString() string {
    return strings.Join(sl.rows, "\n")
}

func (sl *StringList) add(value string) {
    sl.rows = append(sl.rows, value)
}

//TextAdapter is Adapter
type TextAdapter struct {
    StringList
}

func (ta TextAdapter) getText() string {
    return ta.getString()
}

func getTextAdapter() TextAdapter {
    adapter := TextAdapter{}
    adapter.add("line 1")
    adapter.add("line 2")
    return adapter
}

//Client
adapter := getTextAdapter()
text := adapter.getText()
//text: line 1
//      line 2

fmt.Println(text)
```

## Design Pattern Bridge

![Design Pattern Bridge](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19203.png)
_Design Pattern Bridge_

```go
import (
    "fmt"
    "strings"
)

//AText is Abstraction
type AText interface {
    getText() string
    addLine(value string)
}

//ITextImp is abstract Implementator
type ITextImp interface {
    getString() string
    appendLine(value string)
}

//TextImp is Implementator
type TextImp struct {
    rows []string
}

func (ti TextImp) getString() string {
    return strings.Join(ti.rows, "\n")
}

//TextMaker RefinedAbstraction
type TextMaker struct {
    textImp ITextImp
}

func (tm TextMaker) getText() string {
    return tm.textImp.getString()
}

func (tm TextMaker) addLine(value string) {
    tm.textImp.appendLine(value)
}

//TextBuilder is ConcreteImplementator1
type TextBuilder struct {
    TextImp
}

func (tb *TextBuilder) appendLine(value string) {
    tb.rows = append(tb.rows, value)
}

//HTMLBuilder is ConcreteImplementator2
type HTMLBuilder struct {
    TextImp
}

func (hb *HTMLBuilder) appendLine(value string) {
    hb.rows = append(hb.rows,
        "<span>"+value+"</span><br/>")
}

func fillTextBuilder(textImp ITextImp) AText {
    textMaker := TextMaker{textImp}
    textMaker.addLine("line 1")
    textMaker.addLine("line 2")
    return textMaker
}

//Client
textMaker := fillTextBuilder(&TextBuilder{})
text := textMaker.getText()
//test: line 1
//      line 2

htmlMaker := fillTextBuilder(&HTMLBuilder{})
html := htmlMaker.getText()
//html: <span>line 1</span><br/>
//      <span>line 2</span><br/>

fmt.Println(text)
fmt.Println(html)
```

## Design Pattern Composite

![Design Pattern Composite](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19204.png)
_Design Pattern Composite_

```go
import (
    "fmt"
)

//Graphic is Component
type Graphic interface {
    Draw()
}

//Сircle is Leaf
type Сircle struct{}

//Draw is Operation
func (c Сircle) Draw() {
    fmt.Println("Draw circle")
}

//Square is Leaf
type Square struct{}

//Draw is Operation
func (s Square) Draw() {
    fmt.Println("Draw square")
}

//Image is Composite
type Image struct {
    graphics []Graphic
}

//Add Adds a Leaf to the Composite.
func (i *Image) Add(graphic Graphic) {
    i.graphics = append(i.graphics, graphic)
}

//Draw is Operation
func (i Image) Draw() {
    fmt.Println("Draw image")
    for _, g := range i.graphics {
        g.Draw()
    }
}

//Client
image := Image{}
image.Add(Сircle{})
image.Add(Square{})
picture := Image{}
picture.Add(image)
picture.Add(Image{})
picture.Draw()
```

## Design Pattern Decorator

![Design Pattern Decorator](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19205.png)
_Design Pattern Decorator_

```go
import (
    "fmt"
)

//Shape is Component
type Shape interface {
    ShowInfo()
}

//Square is ConcreteComponent
type Square struct{}

//ShowInfo is Operation()
func (s Square) ShowInfo() {
    fmt.Print("square")
}

//ShapeDecorator is Decorator
type ShapeDecorator struct {
    Shape Shape
}

//ShowInfo is Operation()
func (sd ShapeDecorator) ShowInfo() {
    sd.Shape.ShowInfo()
}

//ColorShape is ConcreteDecorator
type ColorShape struct {
    ShapeDecorator
    color string
}

//ShowInfo is Operation()
func (cs ColorShape) ShowInfo() {
    fmt.Print(cs.color + " ")
    cs.Shape.ShowInfo()
}

//ShadowShape is ConcreteDecorator
type ShadowShape struct {
    ShapeDecorator
}

//ShowInfo is Operation()
func (ss ShadowShape) ShowInfo() {
    ss.Shape.ShowInfo()
    fmt.Print(" with shadow")
}

//Client
square := Square{}
square.ShowInfo()
//printed: square
fmt.Println()

colorShape := ColorShape{
    ShapeDecorator{square}, "red"}
colorShape.ShowInfo()
//printed: red square
fmt.Println()

shadowShape := ShadowShape{
ShapeDecorator{colorShape}}
shadowShape.ShowInfo()
//printed: red square with shadow
```

## Design Pattern Facade

![Design Pattern Facade](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19206.png)
_Design Pattern Facade_

```go
import (
    "fmt"
)

//Complex parts
type kettle struct{}

func (k kettle) TurnOff() {
    fmt.Println("Kettle turn off")
}

type toaster struct{}

func (t toaster) TurnOff() {
    fmt.Println("Toaster turn off")
}

type refrigerator struct{}

func (r refrigerator) TurnOff() {
    fmt.Println("Refrigerator turn off")
}

//Facade
type kitchen struct {
    kettle       kettle
    toaster      toaster
    refrigerator refrigerator
}

func (k kitchen) Off() {
    k.kettle.TurnOff()
    k.toaster.TurnOff()
    k.refrigerator.TurnOff()
}

//Client
kitchen := kitchen{
    kettle{},
    toaster{},
    refrigerator{},
}

kitchen.Off()
```

## Design Pattern Flyweight

![Design Pattern Flyweight](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19207.png)
_Design Pattern Flyweight_

```go
import (
    "fmt"
)

//Span is Flyweight
type Span interface {
    PrintSpan(style string)
}

//Char is ConcreteFlyweight
type Char struct {
    C rune
}

//PrintSpan is Operation(extrinsicState)
func (c Char) PrintSpan(style string) {
    fmt.Println("<span style=\"" +
        style + "\">" + string(c.C) + "</span>")
}

//CharFactory is FlyweightFactory
type CharFactory struct {
    chars map[rune]Char
}

//GetChar is GetFlyweight(key)
func (cf *CharFactory) GetChar(c rune) Span {
    if value, exists := cf.chars[c]; exists {
        return value
    }
    char := Char{c}
    cf.chars[c] = char
    return char
}

//Client
factory := CharFactory{map[rune]Char{}}
charA := factory.GetChar('A')
charA.PrintSpan("font-size: 12")

charB := factory.GetChar('B')
charB.PrintSpan("font-size: 12")

charA1 := factory.GetChar('A')
charA1.PrintSpan("font-size: 12")

equal := charA == charA1
//equal is true

fmt.Println(equal)
```

## Design Pattern Proxy

![Design Pattern Proxy](https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/19208.png)
_Design Pattern Proxy_

```go
import (
    "fmt"
)

//Graphic is Subject
type Graphic interface {
    Draw()
}

//Image is RealSubjec
type Image struct {
    FileName string
}

//Draw is Request()
func (im Image) Draw() {
    fmt.Println("draw " + im.FileName)
}

//ImageProxy is Proxy
type ImageProxy struct {
    FileName string
    _image   *Image
}

//GetImage creates an Subject
func (ip ImageProxy) GetImage() *Image {
    if ip._image == nil {
        ip._image = &Image{ip.FileName}
    }
    return ip._image
}

//Draw is Request()
func (ip ImageProxy) Draw() {
    ip.GetImage().Draw()
}

//Client
proxy := ImageProxy{FileName: "1.png"}
//operation without creating a RealSubject
fileName := proxy.FileName
//forwarded to the RealSubject
proxy.Draw()

fmt.Println(fileName)
```