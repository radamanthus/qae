#= require jquery
#= require jquery_ujs
#= require Countable
#= require_tree .

jQuery ->
  # Hidden hints as seen on
  # https://www.gov.uk/service-manual/user-centred-design/resources/patterns/help-text
  # Creates the links and adds the arrows
  $(".hidden-link").wrap("<a href='#'></a>")
  # Adds the arrows
  $(".hidden-link").closest("a").prepend("<span class='hidden-arrow-right'>▶</span><span class='hidden-arrow-down'>▼</span>")
  # Adds click event to links
  $(document).on "click", ".hidden-hint a", (e) ->
    e.preventDefault()
    $(this).closest(".hidden-hint").toggleClass("show-hint")

  # Conditional questions that appear depending on answers
  $(".js-conditional-question, .js-conditional-drop-question").addClass("conditional-question")
  # Simple conditional using a == b
  simpleConditionalQuestion = (input, clicked) ->
    answer = input.closest(".js-conditional-answer").attr("data-answer")
    question = $(".conditional-question[data-question='#{answer}']")
    answerVal = input.val()

    if input.attr('type') == 'checkbox'
      answerVal = input.is(':checked').toString()

    question.each () ->
      if $(this).attr('data-value') == answerVal || ($(this).attr('data-value') == "true" && answerVal != false)
        if clicked || (!clicked && input.attr('type') == 'radio' && input.is(':checked'))
          $(this).addClass("show-question")
      else
        if clicked || (!clicked && input.attr('type') != 'radio')
          $(this).removeClass("show-question")
  $(".js-conditional-answer input, .js-conditional-answer select").each () ->
    simpleConditionalQuestion($(this), false)
  $(".js-conditional-answer input, .js-conditional-answer select").change () ->
    simpleConditionalQuestion($(this), true)
  # Numerical conditional that checks that trend doesn't ever drop
  dropConditionalQuestion = (input) ->
    drop_question = input.closest(".js-conditional-drop-answer").attr('data-drop-question')
    question = $(".js-conditional-answer[data-answer='#{drop_question}']").closest(".js-conditional-drop-question")
    drop = false

    $(".js-conditional-drop-answer[data-drop-question='#{drop_question}']").each () ->
      drop_answers = $(this).closest(".js-conditional-drop-answer")
      last_val = 0

      drop_answers.find("input").each () ->
        if $(this).val()
          value = parseFloat $(this).val()
          if value < last_val
            drop = true
          last_val = value

    if drop
      question.addClass("show-question")
    else
      question.removeClass("show-question")
  $(".js-conditional-drop-answer input").each () ->
    dropConditionalQuestion($(this))
  $(".js-conditional-drop-answer input").change () ->
    dropConditionalQuestion($(this))

  # Get the year value from previous answer
  updateYearEnd = () ->
    $(".js-year-end").each () ->
      year = $(this).attr("data-year")
      value = $("input[data-year='#{year}']").val()

      if value
        $(this).text(value)
      else
        $(this).text("...")
  updateYearEnd()
  $("input[data-year]").change () ->
    updateYearEnd()

  # Show/hide the correct step/page for the award form
  showAwardStep = (step) ->
    $(".js-step-condition.step-current").removeClass("step-current")
    window.location.hash = "##{step.substr(5)}"
    $(".js-step-condition[data-step='#{step}']").addClass("step-current")
    # Show past link status
    $(".steps-progress-bar .js-step-link.step-past").removeClass("step-past")

    current_index = $(".steps-progress-bar .js-step-link").index($(".steps-progress-bar .step-current"))
    $(".steps-progress-bar .js-step-link").each () ->
      this_index = $(".steps-progress-bar .js-step-link").index($(this))
      if this_index < current_index
        $(this).addClass("step-past")

  if window.location.hash
    showAwardStep("step-#{window.location.hash.substr(1)}")
    # Resize textareas that were previously hidden
    resetResizeTextarea()
  $(document).on "click", ".js-step-link", (e) ->
    e.preventDefault()
    if !$(this).hasClass("step-current")
      current = $(this).attr("data-step")
      showAwardStep(current)
      # Scroll to top
      $("html, body").animate(
        scrollTop: 0
      , 0)
      # Resize textareas that were previously hidden
      resetResizeTextarea()

  autosave = () ->
    window.autosave_timer = null
    url = $('form.qae-form').data('autosave-url')
    if url
      form_data = {}
      a = $('form.qae-form').serializeArray()
      $.each a,
        (() ->
          if form_data[@name] != undefined
            if !farm_data[@name].push
              form_data[@name] = [form_data[@name]]
            form_data[@name].push(@value || '')
          else
            form_data[@name] = @value || '')
      $.ajax({
        url: url
        data: JSON.stringify(form_data)
        contentType: 'application/json'
        type: 'POST'
        dataType: 'json'
      })
    #TODO: indicators, error handlers?

  triggerAutosave = (e) ->
    window.autosave_timer ||= setTimeout( autosave, 15000 )

  $(document).on "change", ".js-trigger-autosave", triggerAutosave
  $(document).on "keyup", "input[type='text'].js-trigger-autosave", triggerAutosave
  $(document).on "keyup", "input[type='number'].js-trigger-autosave", triggerAutosave
  $(document).on "keyup", "input[type='url'].js-trigger-autosave", triggerAutosave
  $(document).on "keyup", "input[type='tel'].js-trigger-autosave", triggerAutosave
  $(document).on "keyup", "textarea.js-trigger-autosave", triggerAutosave

  # Fade out alerts after 5sec
  $(".flash").delay(5000).fadeOut()

  # Show current holder info when they are a current holder on basic eligibility current holder question
  if $(".eligibility_current_holder").size() > 0
    $(".eligibility_current_holder input").change () ->
      if $(this).val() == "true"
        $("#current-holder-info").removeClass("visuallyhidden")
      else
        $("#current-holder-info").addClass("visuallyhidden")

  # Show innovation amount info when the amount is greater than 1 on innovation eligibility
  if $(".innovative_amount_input").size() > 0
    $(".innovative_amount_input").bind "propertychange change click keyup input paste", () ->
      if $(this).val() > 1
        $("#innovative-amount-info").removeClass("visuallyhidden")
      else
        $("#innovative-amount-info").addClass("visuallyhidden")

  # Show the eligibility failure contact message
  if $("#basic-eligibility-failure-submit").size() > 0
    $(document).on "click", "#basic-eligibility-failure-submit", (e) ->
      e.preventDefault()
      if $(this).closest("form").find("input:checked").val()
        $("#basic-eligibility-failure-answered").addClass("visuallyhidden")
        $("#basic-eligibility-failure-show").removeClass("visuallyhidden")

  # Change your eligibility answers for award eligibility
  if $(".award-finish-previous-answers").size() > 0
    $(document).on "click", ".award-finish-previous-answers a", (e) ->
      e.preventDefault()
      $("#form_eligibility_show").addClass("visuallyhidden")
      $("#form_eligibility_questions").removeClass("visuallyhidden")
