use Mix.Config

config :grizzly,
  serial_port: "/dev/ttyMATRIX0",
  zipgateway_path: "/usr/local/sbin/zipgateway",
  run_zipgateway_bin: false


config :sonex, Sonex.Discovery,
  net_device_name: "wlan0"