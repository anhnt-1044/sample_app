$(document).on('turbolinks:load', function() {
  $('#micropost_picture').bind('change', function() {
    const BYTE_UNIT = 1024;
    const MAX_SIZE_IMAGE = 5;
    var size_in_megabytes = this.files[0].size / BYTE_UNIT / BYTE_UNIT;
    if (size_in_megabytes > MAX_SIZE_IMAGE) {
      alert(I18n.t('microposts.maximum_img_size'));
    }
  });
})
