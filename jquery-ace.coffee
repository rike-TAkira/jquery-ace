(($) ->
  class JQueryAce
    initialize: (element, options) ->
      klass = switch true
        when $(element).is('textarea')
          JQueryAce.TextareaEditor
        else
          JQueryAce.BaseEditor
  
      new klass element, options
  
    defaults:
      theme:  null
      lang:   null
      mode:   null
      width:  null
      height: null
  
    version: '1.0.3'
  
    require: ->
      switch true
        when typeof ace.require is 'function'
          ace.require.apply null, arguments
        when typeof window.require is 'function'
          window.require.apply null, arguments
        else
          throw "Can't find 'require' function"
  
  class JQueryAce.BaseEditor
    constructor: (element, options = {}) ->
      @element = $(element)
      @options = $.extend {}, JQueryAce.defaults, options
  
    create: ->
      @editor = new JQueryAce.AceDecorator(ace.edit @element)
      @update()
  
    update: (options) ->
      @options = $.extend {}, @options, options if options?
      @editor.theme @options.theme if @options.theme?
  
      lang = @options.lang || @options.mode
      @editor.lang lang if lang?
  
    destroy: ->
      @element.data 'ace', null
      @editor.destroy()
      @element.empty()
  
  class JQueryAce.TextareaEditor extends JQueryAce.BaseEditor
    show: ->
      @container?.show()
      @element.hide()
  
    hide: ->
      @container?.hide()
      @element.show()
  
    create: ->
      @container = @createAceContainer()
      @editor    = new JQueryAce.AceDecorator(ace.edit @container.get 0)
  
      @update()
      @editor.value @element.val()
  
      @editor.ace.on 'change', (e) =>
        @element.val @editor.value()
  
      @show()
  
    destroy: ->
      super()
      @hide()
      @container.remove()
  
    createAceContainer: ->
      @buildAceContainer().insertAfter @element
  
    buildAceContainer: ->
      $('<div></div>').css
        display:  'none'
        position: 'relative'
        width:    @options.width  || @element.width()
        height:   @options.height || @element.height()
  
  class JQueryAce.AceDecorator
    constructor: (@ace) ->
  
    theme: (themeName) ->
      @ace.setTheme "ace/theme/#{themeName}"
  
    lang: (modeName) ->
      klass = JQueryAce.require("ace/mode/#{modeName}").Mode
      @session().setMode new klass
  
    mode: (modeName) ->
      @lang modeName
  
    session: ->
      @ace.getSession()
  
    destroy: ->
      @ace.destroy()
  
    value: (text) ->
      if text?
        @ace.insert text
      else
        @ace.getValue()
  
  $.ace = (element, options) ->
    $(element).ace options

  $.fn.ace = (options) ->
    jqs = new JQueryAce()
    @each ->
      editor = $(@).data 'ace'

      if editor?
        editor.update options
      else
        editor = jqs.initialize @, options
        editor.create()

        $(@).data 'ace', editor
)(jQuery)
