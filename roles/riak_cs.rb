name "riak_cs"
description "Role for Riak CS nodes."
run_list(
  "recipe[riak-cs]"
)
default_attributes(
  "riak_cs" => {
    "config" => {
      "riak_cs" => {
        "fold_objects_for_list_keys" => true
      }
    }
  }
)
