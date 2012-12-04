$('#micropost_content').live('keyup keydown', function(e) {
  var maxLen = 140;
  var left = maxLen - $(this).val().length;
  $('#char-count').html(left);
});