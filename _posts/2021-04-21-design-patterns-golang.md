---
title: Golang Design Patterns Code
author: Javad Rajabzade
date: 2021-04-21 15:33:00 +0800
categories: [Golang, Codes]
tags: [golang, go, patterns, codes]
image:
  src: https://raw.githubusercontent.com/Ja7ad/blog/master/images/patterns/design-patterns.png
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
    return e.exp1.Interpret(i) &amp;&amp; e.exp2.Interpret(i)
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

# Creational Patterns
---

# Structural Patterns
---