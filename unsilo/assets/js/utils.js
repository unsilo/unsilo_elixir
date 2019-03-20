

function setup_feed_form(formId) {
  $(formId).ajaxForm({
    type: 'POST',
    crossDomain: true,
    beforeSend: function(xhr) {
      xhr.setRequestHeader('x-csrf-token', my_csrf_token);
    },
    success: function(data, textStatus, jqXHR) {
      if (data["status"] == "err") {
      } else {
        $("#feed_list").html(data["html"]);
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      alert('ajax submit failed: ' + textStatus);
    },
    complete:function(jqXHR, textStatus) {
    }
  });
}

