echo "ungrouped:" > inventory
echo "  hosts:" >> inventory
for index in $(seq 0 2); do
  container_name=$(terraform output --json | jq -r ".container_info.value[$index].name")
  ip_address=$(terraform output --json | jq -r ".container_info.value[$index].ip_address")
  echo "    $container_name:" >> inventory
  echo "      ansible_host: $ip_address" >> inventory

done

