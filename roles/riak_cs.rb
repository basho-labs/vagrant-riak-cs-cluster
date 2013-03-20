lib = File.join(Chef::Config.file_cache_path, "lib")
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "erlang_template_helper"

name "riak_cs"
description "Role for Riak CS nodes."
run_list(
  "recipe[riak-cs]"
)
