# UMD Boilerplate \o/ && D:
((root, factory) ->
  if define?.amd
    define factory
  else
    _fifo = root.fifo
    fifo = root.fifo = factory()
    fifo.noConflict = ->
      root.fifo = _fifo
      fifo
)(this, ->

  (namespace) ->

    data = JSON.parse localStorage.getItem(namespace) or '{"keys":[],"items":{}}'

    trySave = (key, value) ->

      try
        if not key
          localStorage.setItem namespace, JSON.stringify data
        else
          localStorage.setItem key, value
        return true
      catch error
        # 22 for Chrome and Safari, 1014 for Firefox
        if error.code is 22 || error.code is 1014
          return false
        throw new Error error

    removeFirstIn = ->
      firstIn = data.keys.pop()
      removedItem = key: firstIn, value: data.items[firstIn]
      delete data.items[firstIn]
      removedItem

    save = (key, value) ->
      removed = []
      until trySave(key, value)
        if data.keys.length
          removed.push removeFirstIn()
          localStorage.setItem(namespace, JSON.stringify(data)) if key
        else
          throw new Error "All items removed from #{namespace}, still can't save"
          break
      removed

    set: (key, value, onRemoved) ->
      data.items[key] = value
      data.keys.unshift key
      removed = save()
      onRemoved.call this, removed if onRemoved and removed.length
      this

    # no args returns all items
    get: (key) ->
      if key
        localStorage.getItem(key) or data.items[key]
      else
        items = data.items
        Object.keys(localStorage).forEach (key) ->
          items[key] = localStorage.getItem(key) if key != namespace 
        items

    setFixed: (key, value, onRemoved) ->
      removed = save key, value
      onRemoved.call this, removed if onRemoved and removed.length
      this
        
    keys: ->
        keys = data.keys
        Object.keys(localStorage).forEach (value) ->
          keys.push(value) if value != namespace 
        return keys
    
    has: (key) ->
        return true if -1 != data.keys.indexOf key
        return true if localStorage.getItem(key) != null
        false
        
    remove: (victim) ->
      if localStorage.getItem victim
        localStorage.removeItem victim
        return this
      for suspect, index in data.keys when suspect is victim
        data.keys.splice index, 1
        break
      delete data.items[victim]
      save()
      this

    empty: ->
      data = keys: [], items: {}
      save()
      this
)
