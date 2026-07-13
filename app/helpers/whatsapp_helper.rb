module WhatsappHelper
  # Builds a wa.me click-to-chat link with a pre-filled message.
  def whatsapp_link(phone, message)
    number = whatsapp_number(phone)
    return nil if number.blank?

    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(message)}"
  end

  # Normalizes a free-text phone number into the digits-only, country-code-prefixed
  # format wa.me requires. Assumes India (+91) when no country code is present,
  # since phone numbers in this app are entered as plain 10-digit local numbers.
  def whatsapp_number(phone)
    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    digits = digits.delete_prefix("0") if digits.size == 11 && digits.start_with?("0")
    digits = "91#{digits}" if digits.size == 10
    digits
  end
end
