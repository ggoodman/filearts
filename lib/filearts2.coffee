    
    class Toolbar extends Backbone.View
      el: $('#toolbar')
      
      events:
        'click #tb-new': 'handleNew'
        'click #tb-save': 'handleSave'
        
      render: =>
        iconify = (options) ->
          for sel, icon of options
            $(sel).button
              icons: {primary: icon}
        
        iconify
          '#tb-new': 'ui-icon-document'
          '#tb-save': 'ui-icon-disk'
          '#tb-open': 'ui-icon-folder-open'
          '#tb-preview': 'ui-icon-newwin'
        
        $('#tb-mode')
          .dropdown
            source: @modes
            change: => @trigger 'modeChange', @getCurrentFormat()
      
      getCurrentFormat: -> @$('#tb-mode').val()
      
      setMode: (mode) ->
        @$('#tb-mode').val(mode)
      
      handleNew: (e) =>
        @trigger 'fileCreate'
      
      handleSave: (e) =>
        @trigger 'fileSave'
    
    class Tabs extends Backbone.View
      el: $('#tab-bar')
      
      initialize: ->
        @models = {}
        
      render: =>        
        @el.tabs()
      
      openDocument: (model) ->
        title = model.get('title')
        hash = '#' + title
        div = $('<div />', {id: title, css: 'display: none !important;'})
        @models[title] = model
        
        $('#tab-bar')
          .tabs('add', hash, title)
          .tabs('select', hash)

    class Editor extends Backbone.View
      el: $('#editor')
      
      initialize: ->
        @modes =
          'css': 'ace/mode/css'
          'coffee-script': 'ace/mode/coffee'
          'html': 'ace/mode/html'
          'javascript': 'ace/mode/javascript'
          'text': 'ace/mode/text'
        
        for name, path of @modes
          Mode = require(path).Mode
          @modes[name] = new Mode()
          
      openDocument: (model) ->
        @model = model
        console.log "Editor.openDocument", arguments...
        @editor = ace.edit 'editor' if not @editor
        if not @model.get('session')
          session = new EditSession(@model.get('content'))
          @model.set {session: session}
          @trigger 'modeChange', model.get('format')
          @setMode model.get('format')
        
        @editor.setSession @model.get('session')
        @editor.focus()
      
      setMode: (mode) ->
        console.log "Editor.setMode", arguments...
        @editor.getSession().setMode @modes[mode] if @modes[mode]?
        @model.set {format: mode} if @modes[mode]?
    
    class Filearts extends Backbone.View
      initialize: ->
        @editor = new Editor
        @tabs = new Tabs
        @toolbar = new Toolbar
        
        @collection.bind 'change:format', =>
          console.log "Mode changed"
        
        @toolbar.modes = _(@editor.modes).keys()
        
        @tabs.el.tabs
          show: (e, ui) => @editor.openDocument @tabs.models[ui.panel.id]
        
        @editor.bind 'modeChange', (mode) =>
          @toolbar.setMode mode
        
        @toolbar.bind 'modeChange', (mode) =>
          @editor.setMode mode
        
        @toolbar.bind 'fileCreate', =>
          num = @tabs.el.tabs('length')
          num += 1 while $('#Untitled-' + num).length
          title = "Untitled-#{num}"
          
          @tabs.openDocument @collection.create
            title: title
            format: @toolbar.getCurrentFormat()
            content: ""
            open: true
        
        @toolbar.bind 'fileSave', =>
          @editor.model.save()
        
        @collection.bind 'refresh', (col) =>
          @tabs.openDocument(doc) for doc in col.select((doc) -> doc.get('open') isnt on)
        
        @render()
        @collection.fetch()

      render: =>        
        @toolbar.render()
        @tabs.render()
        @editor.render()
