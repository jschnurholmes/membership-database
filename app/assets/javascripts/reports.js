$(document).ready(function() {
    var MEMBER_FIELD = 'q[with_members][]';

    var reportFilterModal = $('#report-filter-modal');
    var reportFilterRequest = null;
    var memberOptionsRequest = null;
    var selectedMembers = new Set();

    var memberCheckboxes = function() {
        return reportFilterModal.find('input[type="checkbox"][name="' + MEMBER_FIELD + '"]');
    };

    var shownMemberIds = function() {
        return new Set(memberCheckboxes().map(function() { return this.value; }).get());
    };

    var hiddenSelectedMembers = function() {
        var shown = shownMemberIds();
        return Array.from(selectedMembers).filter(function(id) { return !shown.has(id); });
    };

    var updateHiddenMemberNotice = function() {
        var hiddenCount = hiddenSelectedMembers().length;
        var notice = reportFilterModal.find('#member-filter-hidden-notice');
        notice.text(hiddenCount === 1
            ? '1 selected member is hidden by the other filters and will still be included.'
            : hiddenCount + ' selected members are hidden by the other filters and will still be included.');
        notice.prop('hidden', hiddenCount === 0);
    };

    var refreshMemberOptions = function(form) {
        var options = form.find('#member-filter-options');
        if (options.length === 0) {
            return;
        }

        if (memberOptionsRequest) {
            memberOptionsRequest.abort();
        }

        var otherFilters = form.find(':input')
            .not('[name="' + MEMBER_FIELD + '"]')
            .not('[name="authenticity_token"]')
            .serialize();

        memberOptionsRequest = $.get(options.data('url'), otherFilters)
            .done(function(html) {
                options.html(html);
                memberCheckboxes().each(function() {
                    this.checked = selectedMembers.has(this.value);
                });
                updateHiddenMemberNotice();
            });
    };

    reportFilterModal.on('show.bs.modal', function(e) {
        var content = reportFilterModal.find('.modal-content');
        content.html(
            '<div class="modal-body">' +
            '<div class="uil-ripple-css" style="transform:scale(0.48);"><div></div><div></div></div>' +
            '</div>'
        );

        if (reportFilterRequest) {
            reportFilterRequest.abort();
        }
        if (memberOptionsRequest) {
            memberOptionsRequest.abort();
        }

        reportFilterRequest = $.get($(e.relatedTarget).data('filters-url'))
            .done(function(html) {
                content.html(html);
                selectedMembers = new Set(memberCheckboxes().filter(':checked').map(function() { return this.value; }).get());
                updateHiddenMemberNotice();
            })
            .fail(function(request, status) {
                if (status === 'abort') {
                    return;
                }
                content.html(
                    '<div class="modal-body">The filters for this report could not be loaded. Reload the page and try again.</div>' +
                    '<div class="modal-footer">' +
                    '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>' +
                    '</div>'
                );
            });
    });

    reportFilterModal.on('change', '#report-filter-form :input', function() {
        if (this.name === MEMBER_FIELD) {
            if (this.checked) {
                selectedMembers.add(this.value);
            } else {
                selectedMembers.delete(this.value);
            }
            updateHiddenMemberNotice();
        } else {
            refreshMemberOptions($(this.form));
        }
    });

    reportFilterModal.on('submit', '#report-filter-form', function() {
        var form = $(this);
        form.find('input.hidden-member-selection').remove();
        hiddenSelectedMembers().forEach(function(id) {
            $('<input>', { type: 'hidden', name: MEMBER_FIELD, value: id, 'class': 'hidden-member-selection' }).appendTo(form);
        });
        reportFilterModal.modal('hide');
    });
});
