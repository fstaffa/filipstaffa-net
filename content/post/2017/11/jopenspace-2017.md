---
title: "jOpenSpace 2017"
date: 2017-11-11T19:26:48+02:00
---

During the weekend of 13<sup>th</sup> to 15<sup>th</sup> October I have attended [jOpenSpace](http://www.jopenspace.cz/) unconference. Compared to standard conferences it has very loose format. On jOpenSpace every attendee prepares a 10 minutes long presentation on any topic. The benefit is that you can hear more new ideas and they are more condensed. If some topics are not relevant for you, you lose only 10 minutes instead of 1 hour on a standard conference. Because the ideas are more condensed, you can concentrate on the important parts when you try to apply them in your life. From my experience it is not problem to return from a conference with list of 40 things to change, get lost in them and not do anything. If I get list of 5 things, doing 2 or 3 is realistic.

# What I want to implement

## Blog

Ladislav Prskavec had a presentation about [JAMstack](https://jamstack.org/). JAMstack consists of:

* JavaScript - used to handle any dynamic (e.g. not viewing generated static content) content and behavior
* Api - any server side logic should be encapsulated in reusable api
* Markup - static pages developed using templated markup and static site generator

One of the biggest benefits of JAMstack is scaling. Static pages are can be served by CDN in a very fast and reliable way.

For api it is possible to use either existing api or use any form of hosted functions (AWS Lambda, Azure functions). Problem with hosted functions is that it takes them several seconds to start if they were not running already (cold starts). Because part of content is static, it can be served immediately to users. They will start interacting with the page, giving hosted function more time to start before it blocks users' interaction with the page.

Both CDN and hosted functions scale linearly in cost, meaning that JAMstack page can cost almost zero if not used and scale (without any changes) almost endlessly if demand increases.

I wanted to start writing a blog for a long time and hearing again about static web pages gave me another nudge to finally do it.

## Service virtualization

Martin Strejc spoke about Service Virtualization. This is similar to mocking but instead of mocking classes in your code, you mock whole services in your environment. The mock logic can be defined either manually or automatically by recording communication with mocked service. There are both commercial and open source solutions (most promising seem [Mountebank](http://www.mbtest.org/) or [Hoverfly](https://hoverfly.io/)).

# What I want to investigate

## Elm
Tomáš Látal had a workshop about [Elm](http://elm-lang.org/). Elm is functional language which compiles to JavaScript. It is intended mainly for front end and has it's own virtual DOM implementation. It has several characteristics of Haskell (pure, strong typing) and promises code without runtime errors.

Compared to other languages which compile to JavaScript (TypeScript, ClojureScript) it does not allow direct communication with JavaScript code. Instead there is Elm program which communicates with the rest of JavaScript by sending messages through ports. This should clearly separate which parts of code can throw runtime exceptions and which are safe.

Most people also claim that it is easier to learn than Haskell and is a good way to learn more about functional programming,

## Theory of constraints
Lukáš Křečan gave a short introduction to [Theory of Constraints](https://en.wikipedia.org/wiki/Theory_of_constraints). This theory was originally a developed in manufacturing but is applicable to software development as well. It says that company (or team) can't be stronger than it's weakest link.

An example is team with developers and QA. If developers manage to deliver new features faster but QA don't manage to test them that fast, result is not better product. Rather the result might be a product with a lot of untested (or in Waiting for Testing) features. Solution for this is not developers coding faster, but adding more QA or have developers help with testing. This is what several companies are doing - instead of having QA and developers as separate roles, there is a team which delivers features and everyone is expected to do both development and testing.

# Other interesting topics

* Generating articles - Last year Petr Hamerník about using Natural Language Processing to create a summary from articles. This year he spoke about the opposite - having summary data (e.g. football match results), computers generate articles from them.

* Kotlin - Kotlin is a JVM language developed by Jetbrains. It has similar syntax to Java but with many improvements which make it more powerful. The big news for me was that Kotlin was announced as official Android development language on this year's Google IO, making it more than just "another JVM language".

* Mobile applications monetization - Tomáš Hubálek gave several tips about how to make more money on mobile applications. Freemium model (application is for free but)there is option to buy new functionality) earns more money than paid applications because it is easier for users to try and allows to "sell the application several times" by adding new paid features. He also spoke about importance of price discrimination. This concept comes from microeconomy and says, that you should not sell your application to everyone for the same price, but rather for the price he is willing to pay. For mobile application this means student discounts, time limited sales, cross application sales and anything else that attracts people who would not pay the "standard price".

# Conclusion

This was my 3<sup>rd</sup> year and I liked it even more than the previous two. Organizers have done a great job by keeping the great atmosphere even though the number of attendees had increased. I am really looking forward to the next year.
