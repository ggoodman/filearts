EditSession = require('ace/edit_session').EditSession

modes =
  'css': 'ace/mode/css'
  'coffee-script': 'ace/mode/coffee'
  'html': 'ace/mode/html'
  'javascript': 'ace/mode/javascript'
  'text': 'ace/mode/text'

for name, path of modes
  console.log name, path
  Mode = require(path).Mode
  modes[name] = new Mode()

currentMode = 'text'
DefaultMode = modes[currentMode]
  
$ ->
  editor = ace.edit 'editor'

  $('#tb-new')
    .click (e) ->
      num = $('#tab-bar').tabs('length')
      num += 1 while $('#Untitled-' + num).length
      title = "Untitled-#{num}"
      div = $('<div />', {id: title, css: 'display: none !important;'})
      
      $('#tab-bar')
        .tabs('add', '#' + title, title)
        .tabs('select', num)
    .button
      icons:
        primary: 'ui-icon-document'
  
  $('#tb-save')
    .button
      disabled: true
      icons:
        primary: 'ui-icon-disk'
  
  $('#tb-open')
    .button
      disabled: true
      icons:
        primary: 'ui-icon-folder-open'
  
  $('#tb-preview')
    .button
      disabled: true
      icons:
        primary: 'ui-icon-newwin'
        
  $('#mode-name')
    .autocomplete
      delay: 0
      minLength: 0
      source: _(modes).keys()
      change: (e, ui) ->
        if currentMode != ui.item.value
          currentMode = ui.item.value
          editor.getSession().setMode modes[currentMode]
    .click ->
      $('#mode-name').autocomplete('search', '')
  
  $('#mode-selector button')
    .click (e) ->
      $('#mode-name').autocomplete('search', '')
    .button
      text: false
      icons:
        secondary: 'ui-icon-triangle-1-s'
    .removeClass('ui-corner-all')
    .addClass('ui-corner-right')
  
  $('#tab-bar').tabs
    add: (e, ui) ->
      $('#tab-bar li.ui-corner-top')
        .removeClass('ui-corner-top')
        .addClass('ui-corner-bottom')
      opts =
        title: "Close"
        css:
          'width': '20px'
          'height': '20px'
          'margin': '3px 3px 0 0'
          '-webkit-border-radius': '10px'
      $("<button />", opts)
        .button
          icons:
            primary: "ui-icon-close"
        .appendTo($(ui.tab).parent())
        .find('span')
          .css
            'left': '50%'
            'margin-left': '-9px'
        .click ->
          $('#tab-bar').tabs('remove', $(ui.tab).attr('href')) if $('#tab-bar').tabs('length') > 1
    remove: (e, ui) ->
      $(ui.panel).remove()
    show: (e, ui) ->
      if not $(ui.panel).data('ace-session')
        session = new EditSession($(ui.panel).text())
        session.setMode DefaultMode
        $(ui.panel).data('ace-session', session)
      
      editor.setSession($(ui.panel).data('ace-session'))
  
  $('.ui-state-default')
    .mouseenter(-> $(this).addClass 'ui-state-hover')
    .mouseleave(-> $(this).removeClass 'ui-state-hover')
    .mousedown(-> $(this).addClass 'ui-state-active')
    .mouseup(-> $(this).removeClass 'ui-state-active')

  $('#tb-new').click()
