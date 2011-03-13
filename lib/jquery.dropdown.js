(function( $ ){

  var settings = {
    'source': ['test', 'test'],
    'delay': 0,
    'minLength': 0,
    'change': function(e, ui){},
    'select': function(e, ui){},
    'title': ''
  };
  
  var methods = {
    init: function(options) {
      settings = $.extend(settings, options);
      return this.each(function(){
        var $this = $(this).addClass('ui-corner-right')//.attr('readonly', 'readonly')
          , $wrap = $('<div />',{
              'id': 'ui-dropdown-' + $this.id,
              'class': 'ui-dropdown'
            })
          , $button = $("<button />",{
              title: settings.title
            }).attr({
              'tabindex': '-1'
            }).button({
              text: settings.title,
              icons: {
                primary: 'ui-icon-triangle-1-s'
              }
            }).removeClass('ui-corner-all').addClass('ui-corner-right');
        
        $this.wrap($wrap).after($button);
        
        var $input = $this.autocomplete({
          source: settings.source,
          delay: settings.delay,
          minLength: settings.minLength,
          change: function(e, ui){
            settings.change(ui.item.value);
          },
          select: function(e, ui){
            settings.select(ui.item.value);
          }
        });
        $button.click(function(){
          $input.autocomplete('search', '');
        })
      });
    }
  };
  
  $.fn.dropdown = function( method ) {
    
    if ( methods[method] ) {
      return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      return $.error( 'Method ' +  method + ' does not exist on jQuery.dropdown' );
    }    
  
  };
})( jQuery );