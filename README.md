fifo
====

**First In First Out accounting for JavaScript `localStorage`.**

About
-----

`localStorage` doesn't have an unlimited amount of space, and just
throws an error when you try to save to it when its full. `fifo`
gracefully handles saving data to localStorage: when you run out of room
it simply removes the earliest item(s) saved and sends them to a
callback giving you the option to do something with them.

Additionally, `fifo` also stores all of your `key:value` pairs on one key
in `localStorage` for [better performance][perf].

Build status: [![Build Status](https://travis-ci.org/rpflorence/fifo.svg?branch=master)](https://travis-ci.org/reflorence/fifo)

API
---

```javascript
// create a collection stored on `tasks` key in localStorage
var collection = fifo('tasks');

// set an item
collection.set('task:2', 'close two tickets', function(removedItems){
  // only if `localStorage` is out of room, this function will be called
  // removedItems is an array of items that look something like this
  //
  // [{key: 'task:1', value: 'some task value stored a long time ago'}]
  //
  // Each item is an object with properties `key` and `value`
});

// retrieve an item - preference for fixed items, then FIFO queue
var storedTask = collection.get('task:1'); //> 'close two tickets'

// retrieve all items by sending no arguments to get
var tasks = collection.get();

// remove an item - preference for fixed items, then FIFO queue
collection.remove('task:1');

// empty an entire FIFO queue
collection.empty()

// set any JavaScript object, don't have to JSON.parse or JSON.stringify
// yourself when setting and getting.
collection.set('task:2', { due: 'sunday', task: 'go to church' });
collection.set('whatevz', [1,2,3]);

// set a fixed value in localStorage
collection.setFixed('fixed', 'Do not delete me')

// get a list of all keys, both those in fifo and fixed localstorage
collection.keys  /* Returns an array of key names */

// Check to see if a key exists in the FIFO queue or fixed localstorage
collection.has 'key' /* true or false */
```

Warning
--------

It is possible to cause a collision of keys in the fixed storage and FIFO queue. In all cases of 'get' and 'remove' the fixed storage is used in preference.

Browser Support
---------------

`fifo` assumes the browser has `localStorage` and `JSON`. _This is not a
`localStorage` shim_.

Development
-----------

The `fifo` source is written in coffeescript (like wearing stretchy
pants when you become a man, it's for fun), you can install it by
running `npm install .` from the root of this repository. Also, run
`./watch` to have the coffeescript automatically compile as you save.

Test by opening `test.html` in a browser.

Alternatively install phantomjs using:

```
npm i -g phantomjs
```

Install dependencies as normal:

```
npm i .
```

...and enjoy automated testing goodness by running:

```
npm test
```

License
-------

MIT-Style license

[perf]:http://jsperf.com/localstorage-string-size-retrieval

