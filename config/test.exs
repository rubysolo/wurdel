import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wurdel, WurdelWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "V1DrCF6f84LhmDBR9i8Ek3tyJxovRQYgR8LA0+PzBmDwDwMDAl+thqjeQboJ/B4d",
  server: false

# In test we don't send emails.
config :wurdel, Wurdel.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
