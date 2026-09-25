// Bootstrap tooltips and popovers initialization
$(document).ready(function() {
  $("a[rel~=popover], .has-popover").popover();
  $("a[rel~=tooltip], .has-tooltip").tooltip();
});
