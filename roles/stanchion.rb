name "stanchion"
description "Role for the Stanchion node."
run_list(
  "recipe[riak-cs::stanchion]"
)
