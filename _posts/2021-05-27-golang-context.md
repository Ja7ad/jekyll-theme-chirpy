---
title: Golang Context
author: Javad Rajabzade
date: 2021-05-27 08:16:00 +0800
categories: [Golang, Tutorial]
tags: [golang, go, context]
---

Applications in golang use Contexts for controlling and managing very important aspects of reliable applications, such as cancellation and data sharing in concurrent programming. This may sound trivial but in reality, it’s not that so. The entry point for the contexts in golang is the context package. It is extremely useful and probably one of the most versatile packages of the entire language. If you haven’t come across anything dealing with contexts yet, you probably will very soon (or maybe you just didn’t pay much attention to it). The usage of context is so widespread that multiple other packages rely on it and assume you will do the same. It is definitely a key component on golang’s ecosystem.

Here’s the official documentation for the context package [https://golang.org/pkg/context/](https://golang.org/pkg/context/). It’s really great and filled with practical examples. In an attempt to extend those, let’s have a look into things I have came across in real applications.

# Context with value

One of the most common uses for contexts is to share data, or use request scoped values. When you have multiple functions and you want to share data between them, you can do so using contexts. The easiest way to do that is to use the function `context.WithValue`. This function creates a new context based on a parent context and adds a value to a given key. You can think about the internal implementation as if the context contained a map inside of it, so you can add and retrieve values by key. This is very powerful as it allows you to store any type of data inside the context. Here’s an example of adding and retrieving data with a context.

```go
package main

import (
	"context"
	"fmt"
)

func main() {
	ctx := context.Background()
	ctx = addValue(ctx)
	readValue(ctx)
}

func addValue(ctx context.Context) context.Context {
	return context.WithValue(ctx, "key", "test-value")
}

func readValue(ctx context.Context) {
	val := ctx.Value("key")
	fmt.Println(val)
}
```

One important aspect of the design behind context package is that everything returns a new `context.Context` struct. This means that you have to remember to work with the returned value from operations and possibly override old contexts with new ones. This is a key design in immutability. 

Using this technique you can pass along the `context.Context` to concurrent functions and as long as you properly manage the context you are passing on, it’s good way to share scoped values between those concurrent functions (meaning that each context will keep their own values on its scope). That’s exactly what `net/http` package does when handling HTTP requests. To elaborate on that let’s have a look into the next example.

## Middlewares

A great example and use case for request scoped values is working with middlewares in web request handlers. The type `http.Request` contains a context which can carry scoped values throughout the HTTP pipeline. It is very common to see code where middlewares are added to the HTTP pipeline and the results of the middlewares are added to the `http.Request` context. This is a very useful technique as you can rely on something you know happened to in your pipeline already on later stages. This also enables you to use generic code to handle HTTP request, while respecting the scope where you want to share the data (instead of sharing data on global variables for example). Here’s an example of a middleware that leverages the request context.

```go
package main

import (
	"context"
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

func main() {
	router := mux.NewRouter()
	router.Use(guidMiddleware)
	router.HandleFunc("/ishealthy", handleIsHealthy).Methods(http.MethodGet)
	http.ListenAndServe(":8080", router)
}

func handleIsHealthy(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	uuid := r.Context().Value("uuid")
	log.Printf("[%v] Returning 200 - Healthy", uuid)
	w.Write([]byte("Healthy"))
}

func guidMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		uuid := uuid.New()
		r = r.WithContext(context.WithValue(r.Context(), "uuid", uuid))
		next.ServeHTTP(w, r)
	})
}
```

# Context Cancellation

Another very useful feature of context in golang is cancelling things that are related. This is very important when you want to propagate your cancellation. It’s a good practice to propagate the cancellation signal when you receive one. Let’s say you have a function where you start tens of goroutines. That main function waits for all goroutines to finish or a cancellation signal before proceeding. If you receive the cancellation signal you may want to propagate it to all your goroutines, so you don’t waste compute resources. If you share the same context among all goroutines you can easily do that.
To create a context with cancellation you only have to call the function `context.WithCancel(ctx)` passing your context as parameter. This will return a new context and a cancel function. To cancel that context you only need to call the cancel function.

```go
package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"net/http"
	neturl "net/url"
	"time"
)

func queryWithHedgedRequestsWithContext(urls []string) string {
	ch := make(chan string, len(urls))
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	for _, url := range urls {
		go func(u string, c chan string) {
			c <- executeQueryWithContext(u, ctx)
		}(url, ch)

		select {
		case r := <-ch:
			cancel()
			return r
		case <-time.After(21 * time.Millisecond):
		}
	}

	return <-ch
}

func executeQueryWithContext(url string, ctx context.Context) string {
	start := time.Now()
	parsedURL, _ := neturl.Parse(url)
	req := &http.Request{URL: parsedURL}
	req = req.WithContext(ctx)

	response, err := http.DefaultClient.Do(req)

	if err != nil {
		fmt.Println(err.Error())
		return err.Error()
	}

	defer response.Body.Close()
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Printf("Request time: %d ms from url%s\n", time.Since(start).Nanoseconds()/time.Millisecond.Nanoseconds(), url)
	return fmt.Sprintf("%s from %s", body, url)
}
```

Each request is fired in a separate goroutine. The context is passed to all requests that are fired. The only thing that is being done with the context is that it gets propagated to the HTTP client. This allows a graceful cancellation of the request and underlying connection when the cancel function is called. This is a very common patter for functions that accept a `context.Context` as argument, they either actively act on the context (like checking if it was cancelled) or they pass it to an underlying function that deals with it (in this case the Do function that receives the context through the `http.Request`).

# Context Timeout

Timeouts are a really common pattern for making external requests, like querying a database or fetching data from another service either through HTTP or gRPC (both support contexts). Handling those scenarios is quite easy using the context package. All you have to do is call the function `context.WithTimeout(ctx, time)` passing your context and the actual timeout. Like this:

```go
ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
```

You still receive the cancel function in case you want to manually trigger that. It works the same way as a normal context cancellation.
The behaviour for this case is very straightforward. In case the timeout is reached, the context is cancelled. Is case of a HTTP call, it works essentially the same as the example above.

# gRPC

Context is a fundamental piece of gRPC implementation in golang. It is used both to share data (what is called metadata) and to control flow, like cancelling a stream or request.

```go
// Server implementation receiving metadata
func (*server) Sum(ctx context.Context, req *calculatorpb.SumRequest) (*calculatorpb.SumResponse, error) {
	log.Printf("Sum rpc invoked with req: %v\n", req)
	md, _ := metadata.FromIncomingContext(ctx)
	log.Printf("Metadata received: %v", md)
	return &calculatorpb.SumResponse{
		Result: req.NumA + req.NumB,
	}, nil
}

// Client implementation sending metadata
func sum(c calculatorpb.CalculatorServiceClient) {
	req := &calculatorpb.SumRequest{
		NumA: 3,
		NumB: 10,
	}
	ctx := metadata.AppendToOutgoingContext(context.Background(), "user", "test")
	res, err := c.Sum(ctx, req)
	if err != nil {
		log.Fatalf("Error calling Sum RPC: %v", err)
	}
	log.Printf("Response: %d\n", res.Result)
}

// Server implementation handling context cancellation
func (*server) Greet(ctx context.Context, req *greetpb.GreetRequest) (*greetpb.GreetResponse, error) {
	log.Println("Greet rpc invoked!")

	time.Sleep(500 * time.Millisecond)

	if ctx.Err() == context.Canceled {
		return nil, status.Error(codes.Canceled, "Client cancelled the request")
	}

	first := req.Greeting.FirstName
	return &greetpb.GreetResponse{
		Result: fmt.Sprintf("Hello %s", first),
	}, nil
}

// Client implementation using timeout context cancellation
func greetWithTimeout(c greetpb.GreetServiceClient) {
	req := &greetpb.GreetRequest{
		Greeting: &greetpb.Greeting{
			FirstName: "Ricardo",
			LastName:  "Linck",
		},
	}
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()
	res, err := c.Greet(ctx, req)
	if err != nil {
		grpcErr, ok := status.FromError(err)

		if ok {
			if grpcErr.Code() == codes.DeadlineExceeded {
				log.Fatal("Deadline Exceeded")
			}
		}

		log.Fatalf("Error calling Greet RPC: %v", err)
	}
	log.Printf("Response: %s\n", res.Result)
}
```

# OpenTelemetry

OpenTelemetry also relies heavily on context for what is called Context Propagation. That is a way to tied up requests happening in different systems. The way to implement that is to Inject span information into the context you are going to send as part of the protocol you are using (HTTP or gRPC, for instance). On the other service you need to Extract the span information out of the context. 