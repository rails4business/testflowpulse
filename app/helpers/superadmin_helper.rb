# app/helpers/superadmin_helper.rb
module SuperadminHelper
  def pc_badge(text, color: "slate")
    <<~HTML.html_safe
      <span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium bg-#{color}-100 text-#{color}-800">
        #{ERB::Util.html_escape(text)}
      </span>
    HTML
  end

  def euro(amount)
    return "-" if amount.nil?
    number_to_currency(amount, unit: "€", separator: ",", delimiter: ".", format: "%u %n")
  end
end
