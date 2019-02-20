use Mix.Config

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :unsilo,
  ecto_repos: [Unsilo.Repo],
  app_domain: "sfuchs.fyi"

config :phoenix, :template_engines, haml: PhoenixHaml.Engine

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :canary,
  repo: Unsilo.Repo

config :unsilo, Unsilo.UserController, allow_signups: true

config :arc,
  storage: Arc.Storage.Local

config :phoenix, :json_library, Jason

config :unsilo, UnsiloWeb.Auth.Guardian,
  issuer: "unsilo",
  secret_key: "uDTx1Z2rkpSdKLgKpMtJqnmGOA2l6TJNUxMA72UgL6NS2Nn1Hb7R0XFeLCrTcwtp"

config :unsilo, UnsiloWeb.Endpoint,
  http: [port: 80],
  url: [host: "sfuchs.local", scheme: "http", port: 80],
  server: true,
  secret_key_base: "oSxFxllzYHVBGyJy3s9QQ4cryjLNmYQA2LzHmUf1cMNZM1MIX1jEb6OyVtlZku4g",
  render_errors: [view: UnsiloWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Unsilo.PubSub, adapter: Phoenix.PubSub.PG2]
  cache_static_manifest: "priv/static/cache_manifest.json"


config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

config :logger, backends: [RingLogger]


config :nerves_firmware_ssh,
  authorized_keys: [
         File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
     ]

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "sfuchs.local",
  node_name: nil,
  node_host: :mdns_domain

config :nerves_network,
  regulatory_domain: "US"

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom(key_mgmt)
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]
# import_config "#{Mix.Project.config[:target]}.exs"
