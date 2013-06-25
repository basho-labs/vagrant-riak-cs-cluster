name "base"
description "Base role."
run_list(
  "recipe[ntp]",
  "recipe[nmap]",
  "recipe[htop]",
  "recipe[openssh]"
)
default_attributes(
  "openssh" => {
    "server" => {
      "password_authentication" => "no"
    }
  }
)
