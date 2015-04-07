module FormHelper
  def possible_read_only_ops(submission=nil)
    ops = {}

    if admin_in_read_only_mode? || (submission && !current_user.account_admin?)
      ops[:disabled] = "disabled"
      ops[:class] = "read-only"
    end

    ops
  end

  def next_step(form, step)
    return unless step

    steps = form.steps
    steps.map! { |s| s.title.parameterize }

    index = steps.index(step)

    steps[index + 1]
  end
end
