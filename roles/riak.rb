lib = File.join(Chef::Config.file_cache_path, "lib")
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "erlang_template_helper"

name "riak"
description "Role for Riak Enterprise nodes."
run_list(
  "recipe[riak]"
)
default_attributes(
  "riak" => {
    "args" => {
      "+zdbbl" => 96000,
      "-env" => {
        "ERL_MAX_PORTS" => 16384
      }
    },
    "config" => {
      "riak_core" => {
        "default_bucket_props" => [["allow_mult", true].to_erl_tuple]
      },
      "riak_kv" => {
        "storage_backend" => "riak_cs_kv_multi_backend"
      }
    }
  }
)
