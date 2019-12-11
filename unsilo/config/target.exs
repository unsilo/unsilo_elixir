use Mix.Config

config :grizzly,
  serial_port: "/dev/ttyMATRIX0",
  zipgateway_path: "/usr/local/sbin/zipgateway",
  run_zipgateway_bin: false

config :sonex, Sonex.Discovery,
  net_device_name: "wlan0"

config :arc,
  storage_dir: "/mnt/unsilo/data/uploads/"

config :mdns_lite,
  host: "unsilo.local",
  ttl: 120,
  services: [
    # service type: _http._tcp.local - used in match
    %{
      name: "Web Server",
      protocol: "http",
      transport: "tcp",
      port: 4080,
    },
  ]

