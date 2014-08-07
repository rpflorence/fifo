testCount = 0
passed = 0
failed = 0

logEl = document.getElementById 'log'

log = (args...) ->
  console.log.apply console, arguments
  txtNode = document.createTextNode "\n#{args.join(' ')}"
  logEl.appendChild txtNode

equal = (a, b, description) ->
  testCount++
  if a is b
    log 'ok', description
    passed++
  else
    log 'not ok', description, 'expected', b, 'got', a
    failed++

# clear it all out first
localStorage.clear()

# helpers to create a bunch of data
repeat = (str, n) ->
  a = []
  while n--
    a.push str
  a.join ''

n10b  = '0123456789'
n100b = repeat n10b, 10
n1k   = repeat n100b, 10
n10k  = repeat n1k, 10
n100k = repeat n10k, 10
n1m   = repeat n100k, 10

# measure how long it all takes
start = +new Date()

# create our collection
collection = fifo 'fifo:test'

# test: set and get
collection.set 'foo', {foo: 'bar'}
retrieved = collection.get 'foo'
equal retrieved.foo, 'bar', 'set and get'

# test: remove
collection.remove 'foo'
retrieved = collection.get 'foo'
equal retrieved, undefined, 'item removed'

# test: ensure it removes old items to add others, sending them to onLimit
limitReached = false
removedItem = null
i = 0
onLimit = (items) ->
  limitReached = true
  removedItem = items[0]
until limitReached or i is 10000 # don't wan't to freeze the browser
  i++
  key = "test:#{i}"
  collection.set key, n100k, onLimit
equal removedItem.key, "test:1", 'removed first item when quota met'

# test: empty
collection.set 'empty1', true
collection.set 'empty2', true
equal collection.get('empty1'), true, 'empty1 exists'
equal collection.get('empty2'), true, 'empty2 exists'
collection.empty()
equal collection.get('empty1'), undefined, 'empty1 emptied'
equal collection.get('empty2'), undefined, 'empty2 emptied'

# test: add fixed value
fixedValue = 'value'
fixedKey = 'fixed'
collection.setFixed fixedKey, fixedValue
fixed = collection.get fixedKey
equal fixed, fixedValue, 'Fixed key added'
collection.remove fixedKey
fixed = collection.get fixedKey
equal fixed, undefined, 'Fixed key has been removed'

# test: Fixed keys can be added once FIFO queue full
#       then add additional items to FIFO queue and 
#       check we keep fixed item
i                      = 0
limitReached           = false
removedItem            = null
removedItemForFixedKey = null
removedItemForFifo     = null

moreFifoOnLimit = (items) ->
  removedItemForFifo = items[0]
    
fixedKeyOnLimit = (items) ->
  removedItemForFixedKey = items[0]
  collection.set key, n1m, moreFifoOnLimit

fifoQueueOnLimit = (items) ->
  limitReached = true
  removedItem = items[0]
  collection.setFixed 'fixed-key', n1m, fixedKeyOnLimit
    
until limitReached or i is 15000 # don't wan't to freeze the browser
  i++
  key = "test:#{i}"
  collection.set key, n100k, fifoQueueOnLimit
    
equal collection.get('fixed-key').length, n1m.length, 'Fixed value retrieved successfully'
equal removedItem.key, 'test:1', 'Expected value removed'
equal removedItemForFixedKey.key, 'test:2', 'Expected value removed to fit fixed key'
equal removedItemForFifo.key, 'test:12', 'Expected value removed from FIFO queue'

# test get all values
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.set 'fifo-key', 'fifo-value'
equal Object.keys(collection.get()).length, 2, 'Values fetched successfully'
equal collection.get()['fifo-key'], 'fifo-value', 'Fetched fifo key correctly'
equal collection.get()['fixed-key'], 'fixed-value', 'Fetched fixed key correctly'

# test get keys
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.set 'fifo-key', 'fifo-value'
equal collection.keys().length, 2, 'Keys fetched successfully'
equal collection.keys()[0], 'fifo-key', 'Fetched fifo key correctly'
equal collection.keys()[1], 'fixed-key', 'Fetched fixed key correctly'

# test has key
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.set 'fifo-key', 'fifo-value'
equal collection.has('fixed-key'), true, 'Has fixed key'
equal collection.has('fifo-key'), true, 'Has fifo key'
equal collection.has('lose-key'), false, 'Hasn\'t lost key'

# test 'keys' isn't replicated due to pass by reference
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.set 'fifo-key', 'fifo-value'
collection.keys()
equal collection.keys().length, 2, 'Data has been replicated'

console.log ''
console.log ''
console.log ''
# test old key is cleaned up when saved
localStorage.clear()
collection = fifo 'fifo:test'
collection.set 'A', '1'
collection.set 'B', '2'
collection.set 'C', '3'
equal collection.keys().length, 3, 'Correct amount of keys set'
collection.set 'A', '4'
equal collection.keys().length, 3, 'Correct amount of keys set'

# Can remove items using a regex
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.setFixed 'fixed-regex-key', 'fixed-regex-value'
collection.set 'fifo-regex-key', 'fifo-value'
collection.set 'fifo-key', 'fifo-regex-value'
collection.remove /regex/
equal collection.has('fixed-key'), true, 'Has fixed key'
equal collection.has('fixed-regex-key'), false, 'Missing fixed-regex key'
equal collection.has('fifo-key'), true, 'Has fifo key'
equal collection.has('fifo-regex-key'), false, 'Missing fifo-regex key'

# Can remove items using a function
localStorage.clear()
collection = fifo 'fifo:test'
collection.setFixed 'fixed-key', 'fixed-value'
collection.setFixed 'fixed-regex-key', 'fixed-regex-value'
collection.set 'fifo-regex-key', 'fifo-value'
collection.set 'fifo-key', 'fifo-regex-value'
collection.remove (suspect) ->
    return -1 != suspect.indexOf 'regex'
equal collection.has('fixed-key'), true, 'Has fixed key'
equal collection.has('fixed-regex-key'), false, 'Missing fixed-regex key'
equal collection.has('fifo-key'), true, 'Has fifo key'
equal collection.has('fifo-regex-key'), false, 'Missing fifo-regex key'

# Can limit the fifo queue size
localStorage.clear()
collection = fifo 'fifo:test'
collection.setQueueLimit 3
collection.set 'key1', 'value1'
collection.set 'key2', 'value2'
collection.set 'key3', 'value3'
collection.set 'key4', 'value4'
collection.set 'key5', 'value5'
collection.set 'key6', 'value6'
equal collection.keys().length, 3, 'Correct amount of keys set'
equal collection.has('key6'), true, 'Expected key6 to be in place'
equal collection.has('key5'), true, 'Expected key5 to be in place'
equal collection.has('key4'), true, 'Expected key4 to be in place'
equal collection.has('key3'), false, 'Expected key3 to *not* be in place'
    
# report
end = +new Date()
log 'finished in:', end - start, 'ms'
status = if failed is 0 then 'ok' else 'not ok'
log "\nRESULT #{status}", "#{passed}/#{testCount}"