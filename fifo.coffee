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
        data.items[key]
      else
        data.items

    setFixed: (key, value, onRemoved) ->
      removed = save key, value
      onRemoved.call this, removed if onRemoved and removed.length
      this
            
    getFixed: (key) ->
      localStorage.getItem key
            
    removeFixed: (victim) ->
      localStorage.removeItem victim
      this
        
    remove: (victim) ->
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
