# config/initializers/content_security_policy.rb

Rails.application.configure do
  config.content_security_policy do |policy|
    # Base
    policy.default_src :self
    policy.object_src  :none

    # Font & immagini (incluse data: e blob: per upload/preview)
    policy.font_src :self, :https, :data
    policy.img_src  :self, :https, :data, :blob

    # Stili (Propshaft + Tailwind). Evita :unsafe_inline se possibile.
    # Se hai proprio bisogno di inline styles temporaneamente, aggiungi :unsafe_inline.
    policy.style_src :self, :https

    # Script: Importmap + Turbo + Google APIs
    # Evita :unsafe_inline; usa i nonce gestiti da Rails.
    policy.script_src :self, :https, "https://apis.google.com"

    # XHR/fetch (per eventuali chiamate esterne)
    policy.connect_src :self, :https, "https://apis.google.com"

    # Se incorpori iframe Google (es. picker/login)
    # policy.frame_src :self, "https://accounts.google.com", "https://apis.google.com"

    # (Facoltativo) Se usi WebSocket/ActionCable in prod:
    # policy.connect_src :self, :https, "wss://#{Rails.application.config.host}"
  end

  # Genera nonce per script e style inline autorizzati tramite helper Rails
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Durante il setup, puoi abilitare solo report per testare:
  # config.content_security_policy_report_only = true
end
