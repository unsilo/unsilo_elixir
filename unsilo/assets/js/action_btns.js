

function attachToAjaxForm(formId, dataset) {
  var success_url = dataset['successRedirectUrl'];
  var success_dst = dataset['successDomDest'];


  $(formId).ajaxForm({
    type: 'POST',
    crossDomain: true,
    beforeSend: function(xhr) {
      xhr.setRequestHeader('x-csrf-token', my_csrf_token)
    },
    success: function(data, textStatus, jqXHR) {
      if (data["status"] == "err") {
        $("#js_modal_content").html(data["html"]);
        attachToAjaxForm(formId, dataset);
      } else if (success_url) {
        window.location.href = success_url;
        $('#js_modal_holder').modal('hide');
      } else if (success_dst) {
        $(success_dst).html(data["html"]);
        $('#js_modal_holder').modal('hide');
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      alert('ajax submit failed: ' + textStatus);
      $('#js_modal_holder').modal('hide');
    },
    complete:function(jqXHR, textStatus) {
    }
  });
}

function run_ajax_post(targ) { 
  var dataset = targ.dataset;
  var post_command = dataset['postCmd'];
  var parentItem = $(targ).closest('.act-btn-item-top');
  var success_dst = dataset['successDomDest'];
  var success_act = dataset['successAction'];
  var success_act_target = $(targ).parents(".story_parent").first();

  $.ajax({
    method: "PUT",
    url: targ.dataset['postUrl'],
    data: {cmd: post_command},
    crossDomain: true,
    beforeSend: function(jqXHR, settings){
      jqXHR.setRequestHeader('x-csrf-token', my_csrf_token)
      parentItem.fadeOut(200);
      return true;
    },
    success: function(data, textStatus, jqXHR) {
      parentItem.remove();
      if (success_dst)
        $(success_dst).html(data["html"]);

      if (success_act) {
        countStories(success_act_target);
      }

      return true;
    },
    error: function(jqXHR, textStatus, errorThrown){
      parentItem.addClass('border-danger');
      parentItem.fadeIn();
      return true;
    },
    complete:function(jqXHR, textStatus) {      
      return true;
    }
  });
  return true;
}

function run_ajax_modal(targ) { 
  var dataset = targ.dataset;
  var success_url = dataset['successRedirectUrl'];
  var success_dst = dataset['successDomDest'];

  $.ajax({
    url: targ.dataset['modalSrcUrl'],
    crossDomain: true,
    beforeSend: function(jqXHR, settings){
      return true;
    },
    success: function(data, textStatus, jqXHR) {
      if (data["html"]) {
        $("#js_modal_content").html(data["html"]);
        $('#js_modal_holder').modal('show');
        attachToAjaxForm('#js_modal_content form', dataset);
      } else if (success_url) {
        window.location.href = success_url;
        $('#js_modal_holder').modal('hide');
      } else if (success_dst) {
        $(success_dst).html(data["html"]);
        $('#js_modal_holder').modal('hide');
      }
    },
    error: function(jqXHR, textStatus, errorThrown){
      alert('page load failed: ' + dataset['url']);
      return true;
    },
    complete:function(jqXHR, textStatus) {      
      return true;
    }
  });
  return true;
}

function run_ajax_delete(targ) { 
  var dataset = targ.dataset;
  var success_url = dataset['successRedirectUrl'];
  var success_dst = dataset['successDomDest'];

  $.ajax({
    method: "delete",
    beforeSend: function(xhr) {
      xhr.setRequestHeader('x-csrf-token', my_csrf_token)
    },
    url: targ.dataset['modalDeleteUrl'],
    success: function(data, textStatus, jqXHR) {
      if ((data["status"] == "err") && success_dst) {
        $(success_dst).html(data["html"]);
      } else if (success_url) {
        window.location.href = success_url;
      } else if (success_dst) {
        $(success_dst).html(data["html"]);
      }
    },
    error: function(jqXHR, textStatus, errorThrown){
      alert('remote delete failed: ' + targ.dataset['url']);
      return true;
    },
    complete:function(jqXHR, textStatus) {      
      return true;
    }
  });
  return true;
}

function countStories(actionTarget) {
  var chlds = $(actionTarget).children(".story_child").length;
  var cnts = $(actionTarget).find(".story_count");
  cnts.first().html(chlds);
}

$(function() {
  $(window).click(function(event) {
    var actionTarget = event.target.closest(".action_btn");
    if (actionTarget) {
      if ( actionTarget.dataset['modalSrcUrl']) {
        run_ajax_modal(actionTarget);
      }
      else if (actionTarget.dataset['postUrl']) {
        run_ajax_post(actionTarget);
      }
      else if (actionTarget.dataset['modalDeleteUrl']) {
        if (confirm("Are you sure you want to delete this? This can not be undone!"))
          run_ajax_delete(actionTarget);
      }
    }
  });
});