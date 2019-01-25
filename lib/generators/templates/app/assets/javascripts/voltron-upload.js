//= require dropzone
//= require voltron

Dropzone.autoDiscover = false;

Voltron.addModule('Upload', function(){
  return {
    initialize: function(){
      $('[data-upload]:not(.uploader):visible').each(this.addUpload);
    },

    getModel: function(input){
      return $(input).attr('name').match(/^[A-Z_0-9]+/i)[0];
    },

    getMethod: function(input){
      return $(input).attr('name').match(/^[A-Z_0-9]+\[([A-Z_0-9]+)\]/i)[1];
    },

    getParamName: function(input, name){
      return this.getModel(input) + '[' + name + '_' + this.getMethod(input) + ']' + (input.multiple ? '[]' : '');
    },

    addUpload: function(){
      var input = $(this);
      var form = $(this).closest('form');

      // Ensure that if `initialize` is called again on this module that the dropzone is not applied twice
      input.addClass('uploader');

      // Wrap the input in the necessary markup if not done so already
      if(!input.closest('.fallback').length) input.wrap($('<div />', { class: 'fallback' }));
      if(!input.closest('.dropzone').length) input.closest('.fallback').wrap($('<div />', { class: 'dropzone' }));

      var dz = new Dropzone(input.closest('.dropzone').get(0), {
        url: input.data('upload'),
        paramName: input.attr('name'),
        parallelUploads: 1, // WARNING: Changing this can yield unexpected results.
        addRemoveLinks: true,
        previewTemplate: input.data('preview') ? $('<div />').append($(input.data('preview')).show()).html() : Dropzone.prototype.defaultOptions.previewTemplate
      });

      // Add the input and form elements to the dropzone instance so we can access it later
      dz.input = input.get(0);
      dz.form = form.get(0);
      input.data('dropzone', dz);

      $.each(input.data('commit'), function(index, id){
        form.prepend($('<input />', { type: 'hidden', name: Voltron('Upload/getParamName', dz.input, 'commit'), value: id }));
      });

      // If set to preserve file uploads, iterate through each uploaded file associated with
      // the model and add to the file upload box upon initialization
      $.each(input.data('files').compact(), function(index, upload){
        Voltron('Upload/getFileObject', upload, upload.id, function(fileObject, id){
          dz.files.push(fileObject);
          dz.options.addedfile.call(dz, fileObject);
          $(fileObject.previewElement).attr('data-id', id);
          dz._enqueueThumbnail(fileObject);
          dz.options.complete.call(dz, fileObject);
          dz._updateMaxFilesReachedClass();
        });
      });

      dz.on('sending', Voltron.getModule('Upload').onBeforeSend);
      dz.on('success', Voltron.getModule('Upload').onSuccess);
      dz.on('removedfile', Voltron.getModule('Upload').onRemove);
      dz.on('addedfile', Voltron.getModule('Upload').onAdd);
      dz.on('error', Voltron.getModule('Upload').onError);
    },

    // Add the authenticity token to the request
    onBeforeSend: function(file, xhr, data){
      data.append('authenticity_token', Voltron.getAuthToken());

      var form = this.form;
      var commitName = Voltron('Upload/getParamName', this.input, 'commit');

      // If single file upload dropzone, remove anything that may have been previously uploaded,
      // change any commit inputs to remove inputs, so the file will be deleted when submitted
      if(!this.input.multiple){
        $(file.previewElement).closest('.dropzone').find('.dz-preview').each(function(){
          var id = $(this).data('id');
          var commitSelect = 'input[name="' + commitName + '"][value="' + id + '"]';

          if(id != $(file.previewElement).data('id')){
            $(form).find(commitSelect).remove();
            $(this).remove();
          }
        });
      }
    },

    // Once a file is uploaded, add a hidden input that flags the file to be committed once the form is submitted
    onSuccess: function(file, data){
      var form = this.form;
      var input = this.input;

      // Integration with voltron-crop gem. If a "cropper" object exists on the file input,
      // ensure we update the image with that which was just uploaded
      if($(this.input).data('cropper') && !$.isEmptyObject(data.uploads)){
        var images = $.map(data.uploads, function(url, id){ return url; });
        $(this.input).data('cropper').cropit('imageSrc', images.pop());
      }

      $.each(data.uploads, function(id, url){
        $(file.previewElement).attr('data-id', id);
        $(form).prepend($('<input />', { type: 'hidden', name: Voltron('Upload/getParamName', input, 'commit'), value: id }));
        $(form).find('input[name="' + Voltron('Upload/getParamName', input, 'remove') + '"]').remove();
      });
    },

    // When a file is removed, eliminate any hidden inputs that may have flagged the file for "committing"
    // and add the hidden input that flags the file in question for removal
    onRemove: function(file){
      var id = $(file.previewElement).data('id');
      var commitName = Voltron('Upload/getParamName', this.input, 'commit');
      var removeName = Voltron('Upload/getParamName', this.input, 'remove');
      $(this.form).find('input[name="' + commitName + '"][value="' + id + '"]').remove();
      $(this.form).prepend($('<input />', { type: 'hidden', name: removeName, value: id }));
    },

    // If input does not allow multiple uploads, remove anything that currently exists in the dropzone
    // Since we've just added a new file that will replace it
    onAdd: function(file){
      if(!this.input.multiple){
        var form = this.form;
        var commitName = Voltron('Upload/getParamName', this.input, 'commit');
      }
    },

    onError: function(file, response){
      $(file.previewElement).find('.dz-error-message').text(response.messages.join('<br />'));
    },

    getFileBlob: function(url, cb){
      var xhr = new XMLHttpRequest();
      xhr.open("GET", url);
      xhr.responseType = "blob";
      xhr.addEventListener('load', function(){
        cb(xhr.response);
      });
      xhr.send();
    },

    blobToFile: function(blob, name){
      blob.lastModifiedDate = new Date();
      blob.name = name;
      blob.status = "added";
      blob.accepted = true;
      return blob;
    },

    getFileObject: function(file, name, cb){
      this.getFileBlob(file.url, function(blob){
        cb(Voltron('Upload/blobToFile', blob, file.name), name);
      });
    }
  };
}, true);
