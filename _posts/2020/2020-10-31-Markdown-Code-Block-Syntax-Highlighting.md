---
layout: post
title:  "Markdown Code Block Syntax Highlighting. Who knew?"
date:   2020-10-31 09:55:00 +0100
categories: markdown
---

Okay, a simple one. You either know this or you don't, and I just discovered it. If you usually add a code block in markdown like this with just 3 backticks;

````
```
var myObj, x;
myObj = {
  "name":"John",
  "age":30,
  "cars":[ "Ford", "BMW", "Fiat" ]
};
x = myObj.cars[0];
document.getElementById("demo").innerHTML = x;
```
````

You get something plain and boring like this;

```
var myObj, x;
myObj = {
  "name":"John",
  "age":30,
  "cars":[ "Ford", "BMW", "Fiat" ]
};
x = myObj.cars[0];
document.getElementById("demo").innerHTML = x;
```

It has no context on what the code is. But, if you specify what it is you are putting in your block, like javascript in this case;

````
```javascript
var myObj, x;
myObj = {
  "name":"John",
  "age":30,
  "cars":[ "Ford", "BMW", "Fiat" ]
};
x = myObj.cars[0];
document.getElementById("demo").innerHTML = x;
```
```` 

You get this!

```javascript
var myObj, x;
myObj = {
  "name":"John",
  "age":30,
  "cars":[ "Ford", "BMW", "Fiat" ]
};
x = myObj.cars[0];
document.getElementById("demo").innerHTML = x;
```

Way better!

This seems to be the official languages supported so far: [https://github.com/github/linguist/blob/master/lib/linguist/languages.yml](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml). 

Just search for yours to see if it exists, but coverage seems excellent. Even powershell is there!