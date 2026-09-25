if (typeof(CDNY) === 'undefined' )
  CDNY = {};

CDNY.getMembers = function() {
    var members_path = '/api/v1/members';
    var req_options  = {
        url: members_path + '.json',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        async: true,
        method: 'GET',
        success: this.updateMembers,
        error: function(request, status, error){
            console.log(request.url +" (" + status + "): " + error );
        }
    };

    $.ajax(req_options)
};

CDNY.updateMembers = function(data, status, request) {
    if (typeof(data) === "string")
        data = JSON.parse(data);
    else if (typeof(data) !== "object")
        alert("Don't know how to handle these data!");
    CDNY._members = data;

    for ( var i = 0; i < CDNY._updateCallbacks.length; i++ ) {
        CDNY._updateCallbacks[i].call( this, data );
    }
};

CDNY.members = function() {
  if ( typeof(CDNY._members) !== 'undefined' ) {
      return CDNY._members;
  } else {
      this.getMembers();
      return null;
  }
};

CDNY.onUpdate = function(callback) {
    if (typeof(CDNY._updateCallbacks) == 'undefined' ) {
        CDNY._updateCallbacks = new Array;
    }
    CDNY._updateCallbacks.push(callback);
};

CDNY.clearUpdateCallbacks = function() {
    CDNY._updateCallbacks = new Array;
};

CDNY.generateCheckboxesForData = function(data, labelFunction, valueFunction) {
    var markup = '<div class="container-fluid"><div class="row">';
    var myData = data.sort(function(a, b){
        if (a.last_name + a.first_name < b.last_name + b.first_name)
            return -1;
        if (a.last_name + a.first_name > b.last_name + b.first_name)
            return 1;
        return 0;
    }).filter(function(member){
        if ( member.expiration_date == 'N/A' )
            return false;

        var expDate = new Date(member.expiration_date);
        return Date.now() <= expDate;
    });

    for(var i = 0; i < myData.length; i++ ) {
        var member = myData[i];
        var label = member.last_name + ', ' + member.first_name;

        markup = markup.concat(
            '<label class="col-md-4"><input type=checkbox name="members[]" value="', member.member_id, '">', label, '</label>'
        )
    }

    markup.concat(
      '</div></div>'
    );

    return markup;
};

$(document).ready(function() {
    var enableMemberSelector = function() {
      var memeberSelectorModal = $('#member-selector');

      memeberSelectorModal.on('show.bs.modal', function(e) {
        if( CDNY.members() == null ) {
          var markup = "<div class='uil-ripple-css' style='transform:scale(0.48);'><div></div><div></div></div>";
          var modalBody = $('#member-selector .modal-body');
          modalBody.html(markup);

          CDNY.onUpdate(function(data){
            var formMarkup = '<form id="member-selector-form" action="/reports/membership_cards" method="post">';
            formMarkup = formMarkup.concat( CDNY.generateCheckboxesForData( data ) );
            formMarkup = formMarkup.concat(
                '<input type="hidden" name="authenticity_token" value="',
                $('meta[name="csrf-token"]').attr('content'), '">'
            );
            formMarkup = formMarkup.concat( '</form>' );
            modalBody.html(formMarkup);
          });
        }
      });

      memeberSelectorModal.find('button[type="submit"]').on('click', function(e){
        var form = $( $(this).data('form') );
        form.submit();
      })
    };

    var enableEffectiveDateSelector = function() {
      var effectiveDateSelectorModal = $('#effective-date-selector');

      effectiveDateSelectorModal.on('show.bs.modal', function(e) {
        var formMarkup = '<form id="effective-date-selector-form" action="/reports/membership_cards" method="post">';
        formMarkup = formMarkup.concat(
             '<input type="hidden" name="authenticity_token" value="',
            $('meta[name="csrf-token"]').attr('content'),
            '">',

            '<input type="date" name="effective_date" value="', (new Date()).toJSON().slice(0, 10).trim() ,'">',

            '</form>'
        );

        var modalBody = $('#effective-date-selector .modal-body');
        modalBody.html(formMarkup);
      });

      effectiveDateSelectorModal.find('button[type="submit"]').on('click', function(e){
        var form = $( $(this).data('form') );
        form.submit();
      })
    };

    enableMemberSelector();
    enableEffectiveDateSelector();
});