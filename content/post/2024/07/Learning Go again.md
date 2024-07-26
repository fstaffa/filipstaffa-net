+++
title = "Learning Go again"
date = 2024-07-26T13:11:00+02:00
tags = ["go"]
draft = false
+++

Go is a language with simple syntax, which requires a fair amount of learning how to do things differently if you come up from a high level language like TypeScript or C#. This article describes my experience trying to learn Go over the last 12 years. This is the third time I am trying to learn Go, and hopefully it will be the last. The pros and cons of Go I mention are based on what I considered important at that time, and are not based on much practical experience with Go.


## First time (Go announcement in 2009 - Go version 1.2) {#first-time--go-announcement-in-2009-go-version-1-dot-2}

This was more learning about Go than learning Go. I first started looking into Go before its version 1 release in 2012. The main reason was that Go was a new shiny toy developed by Google so I wanted to learn more about it. At that time, I was starting my career as a software developer in C# and had around 2 years of development experience. I was flirting with functional languages like Clojure and F#, so Go seemed very boring.

The most interesting feature, channels and goroutines, didn't seem nearly as interesting as async/await which just appeared in [C# 4.5](https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-version-history#c-version-50). On top of that, Go didn't really have a clear idea about reproducible builds. When a friend told me that Go handled dependencies by 'referencing a git repository and getting the latest version', it blew my mind. It meant that code you committed might be different from what gets shipped purely because your CI machine gets a different version of a dependency than you.

What I loved about Go was [`go fmt`](https://go.dev/blog/gofmt). This was the first time I had seen language with an opinionated formatter and it seemed like such an obvious decision that I was surprised similar solution was not in more languages. I tried to replicate it in C# using Resharper formatting and when I later started working in JavaScript/TypeScript, I immediately introduced Prettier.


## Second time (Go version 1.13 - 1.16) {#second-time--go-version-1-dot-13-1-dot-16}

The second time I started looking into Go was in 2019/2020, slightly before Go 1.14 when Go modules were released. The main motivation was that Go seemed like a col technology to learn at that time.

At that time I started working in a new company and switched from developing in C# to JavaScript/TypeScript and Node.js. I used Go for a side project to write a small utility which generated PagerDuty reports. The work went pretty well, but the language still seemed like it was missing a lot.

-   No generics - Beside go modules, generics felt like one of the biggest missing points in Go since its inception. It prevented developers from writing custom data structures or common utility functions like slice filtering or aggregation. The common solution was to 'write more code or copy it', or use runtime checks, effectively removing compile time safety.
-   Initializing structs - In Go (and incidentally C# as well) structs are initialized empty and have no constructor. That means you don't have control over how struct is created, and when you add a new field to it, you get no help from the compiler to make sure the field is always set.

Altogether, it felt like while Go was strongly typed, it had quite a few cases where the compiler was not able to help you.

What I found great about Go at that time is readability. I had problems with one of the libraries used and I was able understand its source code perfectly, even with my limited knowledge of Go. I struggled more with reading JavaScript or C# libraries at that time, even when I had much more experience with these languages.


## Third time (Go version 1.22 - now) {#third-time--go-version-1-dot-22-now}

I was thinking about trying Go for the last year. In contrast to the previous two times, I had actual use cases for writing applications Go. It wasn't just to learn a new programming language.


### Use cases {#use-cases}


#### Writing command line tools {#writing-command-line-tools}

There were several cases where I wanted to write and distribute a CLI application to automate some tasks. What I loved about Go is its ability to (cross) compile into a single binary. I normally work with .Net and Node.js and neither offers a practical way to do the same.

I was considering learning Rust for this purpose because the language features and compile time safety looked much nicer. However, I have never prioritized time to learn it, mostly because I was afraid of its complexity. Learning Go and being pretty productive was much simpler.


#### Contributing to Synology CSI driver {#contributing-to-synology-csi-driver}

At the end of 2023, I finally moved my home server from docker compose containers running on a Synology NAS to a small Kubernetes cluster. I wanted to use the NAS for storage, but it was much harder than anticipated. While there is a [Synology CSI driver](https://github.com/SynologyOpenSource/synology-csi) to use a Synology NAS from Kubernetes, it is not in a well-maintained and getting it working in my environment required applying patches from multiple forks.

So my aspirational goal is to learn Go well enough to be able to do exactly that.


### Experience {#experience}

Compared to previous times, I spent much more time learning how to write Go code the Go way instead of trying to transfer my experience from C#/TypeScript. While I had read [Go proverbs](https://go-proverbs.github.io/) when I tried to learn Go before, they made much more sense now.


#### Batteries included {#batteries-included}

After working for 6 years with Node.js and Npm, I was starting to get tired of working with dependencies. Every project has huge and deep dependency graph and is pretty much guaranteed to have a long list of security vulnerabilities which are hard/impossible to get rid of.

Go has one of the most comprehensive standard libraries. It has a HTTP client, HTTP server (which as of [Go 1.22](https://tip.golang.org/doc/go1.22#enhanced_routing_patterns) supports quite comprehensive routing), structured logging, context propagation, testing and pretty much everything needed to write a web server without any external dependency.

This, combined with the Go culture described by the Go proverb 'A little copying is better than a little dependency.' means that your application will have a very low number of dependencies to worry about. Combined with Go's strong push for backward compatibility, it is usually much easier to keep your dependencies up to date.


#### Value semantics {#value-semantics}

I like immutable values because they remove entire classes of bugs. It took me quite a long time to realize that Go structs are effectively immutable.

Compared to objects in most other languages (like C# or JavaScript), Go structs passed as function arguments are passed by value[^fn:1]. This means that when you pass a Go struct to a function, you know it won't be able to cause any changes to the struct in the calling function.

Here is an example in JavaScript

```js
function sideEffect(input) {
    input.a = 2
}
const x = {a: 1}
sideEffect(x)
console.log(x.a) // prints 2
```

And similar code in Go

```go
type X struct { a int }
func noSideEffect(input X) {
	input.a = 2
}

func main() {
	x := X{a: 1}
	noSideEffect(x)
	fmt.Println(x.a) // prints 1
}
```

Inside a function, Go structs are mutable. That is usually a benefit because it is faster (no need to create new copies like with immutable objects) and easier to do, especially for more nested fields. Compare Go

```go
person.Address.City = "London'
```

with similar code in C# using [record](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/record) with [with expression](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/with-expression)

```csharp
person = person with { Address = person.Address with {City = "London"} }
```


#### Nominal typing {#nominal-typing}

It probably looks weird that in Go, which is known for its structural typing, I emphasize almost the opposite. Go allows you to create new named types based on existing types. Specifically:

```go
type PersonId string

func GetPerson(id PersonId) {}

func main() {
	stringId := "abc"
	personId := PersonId("abc")

	GetPerson(stringId) // compiler error
	GetPerson(personId) // works
}
```

While it might be a niche use case, I found it quite helpful while I was reverse engineering a badly designed API where I was constantly confused by which id to use. By typing each id as shown in example above, I got compile time error when I didn't pass the correct id.

This is a feature I was used to from more strongly typed languages like F#, and is not available in more mainstream languages like C# or TypeScript.


## Conclusion {#conclusion}

The more I learn about Go, the more I appreciate many of its design decisions. Its strong focus on simplicity and readability feels rather unique in the current language landscape. I suspect that the reason why Go didn't click with me the first two times was that I was being smart and that was not the way Go should (and given Go language simplicity even could) be written. With more experience in programming I have learned to appreciate clear and simple code, and that are the design principles of Go. So even if you don't intend to use Go, learning idiomatic Go might make you a better programmer.

[^fn:1]: To be correct, C# (without ref keyword) and JavaScript also pass arguments by value. The difference is that they don't pass content of the object, but reference to an object which is (almost always) on the heap.
