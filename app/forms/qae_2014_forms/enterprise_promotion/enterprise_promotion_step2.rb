class QAE2014Forms
  class << self
    def promotion_step2
      @promotion_step2 ||= Proc.new {
        header :position_details_header, 'Please provide full details of positions held by the nominee which support and are relevant to your nomination.' do
          ref 'B 1'
          context %Q{
            <p>If none of these are voluntary, then you should reconsider your nomination. The Queen's Award for Enterprise Promotion is for those going above and beyond their paid duties.</p>
          }
        end

        position_details :position_details, '' do
          details_words_max 100
        end
      }
    end
  end
end
