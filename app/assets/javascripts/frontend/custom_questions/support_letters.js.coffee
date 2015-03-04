window.SupportLetters =
  init: ->
    $('.js-support-letter-attachment').each (idx, el) ->
      SupportLetters.fileupload_init(el)
      SupportLetters.save_collection_init()

  new_item_init: (el) ->
    SupportLetters.clean_up_system_tags(el)
    SupportLetters.enable_item_fields_and_controls(el)
    SupportLetters.fileupload_init(el.find(".js-support-letter-attachment"))

  fileupload_init: (el) ->
    $el = $(el)
    parent = $el.closest("label")

    upload_done = (e, data, link) ->
      SupportLetters.clean_up_system_tags(parent)

      filename = data.result['original_filename']
      file_title = $("<span class='support_letter_attachment_filename'>" + filename + "</span>")
      hidden_input = $("<input class='js-support-letter-attachment-id'>").prop('type', 'hidden').
                                                                          prop('name', $el.attr("name")).
                                                                          prop('value', data.result['id'])

      parent.find(".errors-container").html("")
      parent.append(file_title)
      parent.append(hidden_input)
      SupportLetters.autosave()

    failed = (e, data) ->
      SupportLetters.clean_up_system_tags(parent)
      error_message = data.jqXHR.responseText
      parent.find(".errors-container").html("<li>" + error_message + "</li>")

    $el.fileupload(
      url: $el.closest(".list-add").data 'attachments-url'
      formData: () -> {}
      done: upload_done
      fail: failed
    )

  clean_up_system_tags: (parent) ->
    parent.find("input[type='hidden']").remove()
    parent.find(".support_letter_attachment_filename").remove()

  enable_item_fields_and_controls: (parent) ->
    parent.find(".js-save-collection").removeClass("visuallyhidden")
    parent.find(".visible-read-only").hide()
    parent.find(".remove-link").removeClass("visuallyhidden")
    fields = parent.find("input")
    fields.removeClass("read-only")
    parent.find(".errors-container").html("")

  disable_item_fields_and_controls: (parent) ->
    parent.find(".js-save-collection").addClass("visuallyhidden")
    parent.find(".visible-read-only").show()
    parent.find(".remove-link").addClass("visuallyhidden")
    fields = parent.find("input")
    fields.addClass("read-only")

  save_collection_init: () ->
    $(document).on 'click', '.js-save-collection', ->
      button = $(this)
      parent = $(this).closest("li")

      if !button.hasClass("visuallyhidden")
        save_url = button.data 'save-collection-url'

        first_name = parent.find(".js-support-letter-first-name").val()
        last_name = parent.find(".js-support-letter-last-name").val()
        email = parent.find(".js-support-letter-email").val()
        relationship_to_nominee = parent.find(".js-support-letter-relationship-to-nominee").val()
        attachment_id = parent.find(".js-support-letter-attachment-id").val()

        data = {
          "support_letter": {
            "first_name": first_name,
            "last_name": last_name,
            "relationship_to_nominee": relationship_to_nominee
          }
        }

        if attachment_id
          data["support_letter"]["attachment"] = attachment_id

        if email
          data["support_letter"]["email"] = email

        if save_url
          $.ajax
            url: save_url
            type: 'post'
            data: data
            dataType: 'json'
            success: (response) ->
              parent.find(".errors-container").html("")
              SupportLetters.disable_item_fields_and_controls(parent)
              SupportLetters.autosave()

              return
            error: (response) ->
              parent.find(".errors-container").html("")
              error_message = response.responseText
              $.each $.parseJSON(response.responseText), (question_key, error_message) ->
                key_selector = ".js-support-letter-" + question_key.replace(/_/g, "-")
                field_error_container = parent.find(key_selector).
                                              closest("label").
                                              find(".errors-container")
                field_error_container.html("<li>" + error_message + "</li>")
              button.removeClass("visuallyhidden")

              return

  autosave: () ->
    url = $('form.qae-form').data('autosave-url')
    if url
      form_data = $('form.qae-form').serialize()
      $.ajax({
        url: url
        data: form_data
        type: 'POST'
        dataType: 'json'
      })
