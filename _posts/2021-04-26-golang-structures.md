---
title: Golang Structures Code
author: Javad Rajabzade
date: 2021-04-26 15:53:00 +0800
categories: [Golang, Codes]
tags: [golang, go, struct, codes]
---

# Structures

## Check for refrence equality

```go
import (
    "fmt"
    "reflect"
)

//There are no classes in golang
type car struct{}

var car1 = car{}
var car2 = car{}
var car3 = car1

var equal1 = car1 == car2
//equal1 is True

var equal2 = car1 == car3
//equal2 is True

var equal3 = reflect.DeepEqual(car1, car2)
//equal3 is True

var equal4 = &amp;car1 == &amp;car2
//equal4 is False
```

## Constants

```go
//There are no classes in golang

//Calendar is simple struct
type Calendar struct{}

func (c Calendar) months() int {
    return 12
}

var calendar = Calendar{}
var months = calendar.months()

fmt.Println(months)
```

## Create a copy of the object

```go
//There are no classes in golang
type shape struct {
    LineCount int
    Name      string
}

var square = shape{4, "Square"}
squareCopy := square
```

## Definition and Initialzation

```go
//There are no classes in golang
type someClass struct{}

var some = someClass{}
```

## Events

```go
import (
    "fmt"
)

//There are no classes in golang
type game struct {
    Name      string
    Callbacks []func(game game)
}

func (g game) Start() {
    for _, callback1 := range g.Callbacks {
        callback1(g)
    }
}

func (g *game) AddListener(s *statistic) {
    g.Callbacks = append(g.Callbacks, s.GameStarted)
}

type statistic struct {
    StartCount int
    LastGame   string
}

func (s *statistic) GameStarted(game game) {
    s.LastGame = game.Name
    s.StartCount++
}

var statistic = statistic{}
var heroes = game{Name: "Heroes"}
var doom = game{Name: "Doom"}

//subscribe to events
heroes.AddListener(&amp;statistic)
doom.AddListener(&amp;statistic)

doom.Start()
heroes.Start()
//statistic.LastGame is "Heroes"
//statistic.StartsCount is 2

fmt.Println(statistic.LastGame)
fmt.Println(statistic.StartCount)
```

## Fields

```go
//There are no classes in golang
type game struct {
    // public field
    Name string
    Year int
}
```

## Nested struct

```go
//There are no classes in golang
type someStruct struct {
    intValue     int

    nestedStruct struct {
        strValue string
    }
}

type someStruct2 struct {
    intValue int
    nestedStruct2
}

type nestedStruct2 struct {
    strValue string
}

var someStruct = someStruct{
    intValue: 5,
}
var nestedStruct = someStruct.nestedStruct
nestedStruct.strValue = "test"

var someStruct2 = someStruct2{
    intValue:      5,
    nestedStruct2: nestedStruct2{"test"},
}
```

# Constructors

## Call of the own constructor

```go
type man struct {
    Name    string
    Country string
}

func newMan(name string) man {
    return man{
        Name: name,
    }
}

func newManWithCountry(name, country string) man {
    man := newMan(name)
    man.Country = country
    return man
}

man := newManWithCountry("Vladimir", "Russia")
```

## Call of the parent constructor

```go
//There are no classes in golang
type man struct {
    Name string
}

type employee struct {
    Position string
    man
}

empl := employee{"booker", man{"Max"}}
```

## Default constructor

```go
//There are no classes in golang
type man struct {
    Name string
}

man := man{}
```

## Optional parameters

```go
type citizen struct {
    Name    string
    Country string
}

func newCitizen(param ...string) citizen {
    switch len(param) {
        case 0:
            return citizen{"unknown", "unknown"}
        case 1:
            return citizen{param[0], "unknown"}
        default:
            return citizen{param[0], param[1]}
    }
}

var man1 = newCitizen()
//man1.Name is "unknown"
//man1.Country is "unknown"

var man2 = newCitizen("Vladimir")
//man2.Name is "Vladimir"
//man2.Country is "unknown"

var man3 = newCitizen("Vladimir", "Brazil")
//man3.Name is "Vladimir"
//man3.Country is "Brazil"
```

## With parameters

```go
//There are no classes in golang
type man struct {
    Name string
}

func makeMan(name string) man {
    return man{name}
}

man := makeMan("Alex")
//man.Name is "Alex"
```

## Without any parameters

```go
//There are no classes in golang
type man struct {
    Name string
}

func newMan() man {
    return man{"unknown"}
}

man := newMan()
//man.Name is "unknown"
```

# Inheritance

## Base class

```go
import (
    "fmt"
)

type shape struct {
    lineCount int
}

type square struct {
    sideLength int
    shape
}

square2 := square{2, shape{4}}
//square.lineCount is 4

fmt.Println(square2.lineCount)
```

## Interface inheritance

```go
import (
    "fmt"
)

type shape interface {
    GetArea() int
}

type square struct {
    SideLength int
}

func (s square) GetArea() int {
    return s.SideLength * s.SideLength
}

square5 := square{5}
area := square5.GetArea()
//area is 25

fmt.Println(area)
```

# Methods

## Array of parameters

```go
type calc struct {}

func (c *calc) getAvg(values ...float64) float64 {
    if len(values) == 0 {
        return 0
    }

    var sum = 0.0
    for _, value := range values {
        sum += value
    }
    return sum / float64(len(values))
}

c := calc{}
var avg = c.getAvg(1, 2, 3, 4)
//avg is 2.5

fmt.Println(avg)
```

## In/Out parameters

```go
type swap struct {}

func (s *swap) strings(s1, s2 *string) {
    *s1, *s2 = *s2, *s1
}

var s1 = "A"
var s2 = "B"
swap := swap{}
swap.strings(&amp;s1, &amp;s2)
//s1 is "B", s2 is "A"

fmt.Println("s1 =", s1)
fmt.Println("s2 =", s2)
```

## Multiple return values

```go
type slicesAssistant struct {
    data []int
}

func (a *slicesAssistant) getFirstLast() (int, int) {
    var first = -1
    var last = -1
    var count = len(a.data)
    if count > 0 {
        first = a.data[0]
        last = a.data[count-1]
    }
    return first, last
}

var ar = []int{2, 3, 5}
assistant := slicesAssistant{ar}
first, last := assistant.getFirstLast()
//first is 2
//last is 5

fmt.Println("first =", first)
fmt.Println("last =", last)
```

## Optional parameter values

```go
type greeting struct {}

func (g *greeting) sayGoodby(message ...string) {
    if len(message) == 0 {
        fmt.Println("Goodby!")
    } else {
        fmt.Println(message[0])
    }
}

func (g *greeting) sayHello(message ...string) {
    if len(message) == 0 {
        fmt.Println("Hello!")
    } else {
        fmt.Println(message[0])
    }
}

greeting := greeting{}
greeting.sayGoodby()
//printed "Goodby!"

greeting.sayHello("Hi")
//printed "Hi"
```

## Out parameters

```go
type calc struct {}

func (*calc) getSum(sum *int, n1, n2 int) {
    *sum = n1 + n2
}

var sum = 0
c := calc{}
c.getSum(&amp;sum, 5, 3)
//sum is 8

fmt.Println("sum =", sum)
```

## Variable parameters

```go
type log struct {
    lastData string
}

func (l *log) print5(data string) {
    l.lastData = data
    if len(data) > 5 {
        data = data[0:5]
    }
    fmt.Println(data)
}

log := log{""}
log.print5("1234567")
//prints "12345"

fmt.Println("lastData = ", log.lastData)
```

## With return value

```go
type calc struct {}

func (*calc) getSum(n1, n2 int) int {
    return n1 + n2
}

c := calc{}
var sum = c.getSum(5, 3)
//sum is 8

fmt.Println("sum =", sum)
```

## Without any parameters

```go
type greeting struct {}

func (*greeting) sayGoodby() {
    fmt.Println("Goodby!")
}

g := greeting{}
g.sayGoodby()
```

## Without any return value

```go
import (
    "fmt"
)

type counter struct {
    Count int
}

func (c *counter) incBy(value int) {
    c.Count += value
}

func (c *counter) incByAmount(value, amount int) {
    c.Count += value * amount
}

c := counter{0}
c.incBy(1)
//counter.Count is 1

c.incByAmount(2, 5)
//counter.Count is 11

fmt.Println(c.Count)
```

# Properties

## Computed properties

```go
import (
    "fmt"
    "math"
)

//In Golang there are no properties
type square struct {
    side float64
}

func (s square) GetArea() float64 {
    return s.side * s.side
}

func (s *square) SetArea(area float64) {
    s.side = math.Sqrt(area)
}

var square2 = square{2.0}
var area = square2.GetArea()
//square.area is 4.0

square2.SetArea(9)
//square2.side is 3.0

fmt.Println(area)
```

## Lazy properties

```go
type filmsList struct{}

func newFilmsList() filmsList {
    //some long operation
    return filmsList{}
}

type mediaPlayer struct {
    //In Golang there are no properties
    films filmsList
}

func (mp *mediaPlayer) GetFilmsList() filmsList {
    mp.films = newFilmsList()
    return mp.films
}

var player = mediaPlayer{}
//filmsList field not yet been initialized
//It will be created after call GetFilmsList() function
var filmList = player.GetFilmsList()
```

## Read-Only properties

### Computed properties

```go
import (
    "fmt"
    "math"
)

//In Golang there are no properties
type circle struct {
    Radius float64
}

func (c circle) GetArea() float64 {
    return math.Pi * math.Pow(c.Radius, 2)
}

var circle2 = circle{2.0}
var area = circle2.GetArea()
//area is 12.56

fmt.Println(area)
```

### Stored properties

```go
import (
    "fmt"
)

//In Golang there are no properties
//It is possible to make a struct to be
//read-only outside of package by making it's
//members non-exported and providing readers
type filmList struct {
    count int
}

func (fl filmList) GetCount() int {
    return fl.count
}

var films = filmList{10}
var count = films.GetCount()
//count is 10

fmt.Println(count)
```

## Stored properties

```go
type point struct {
    //In Golang there are no properties
    x, y int
}

var p = point{}
//x and y is 0 (before assigning)
p.x = 3
p.y = 7
```