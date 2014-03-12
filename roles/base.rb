name "base"
description "Base role."
run_list(
  "recipe[ntp]",
  "recipe[nmap]",
  "recipe[htop]",
  "recipe[openssh]",
  "recipe[serf]",
  "recipe[sudo]"
)
default_attributes(
  "authorization" => {
    "sudo" => {
      "users" => [ "vagrant", "serf" ],
      "passwordless" => "true"
    }
  },
  "openssh" => {
    "server" => {
      "password_authentication" => "no"
    }
  },
  "serf" => {
    "version" => "0.4.5"
  }
)
