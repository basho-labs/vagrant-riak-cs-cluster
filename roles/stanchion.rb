lib = File.join(Chef::Config.file_cache_path, "lib")
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "erlang_template_helper"

name "stanchion"
description "Role for the Stanchion node."
run_list(
  "recipe[riak_cs::stanchion]"
)
