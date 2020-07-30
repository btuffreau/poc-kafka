az vm stop -n kafka-broker-0 -g kafka_lab
az vm stop -n kafka-broker-1 -g kafka_lab
az vm stop -n kafka-broker-2 -g kafka_lab
az vm deallocate -n kafka-broker-0 -g kafka_lab
az vm deallocate -n kafka-broker-1 -g kafka_lab
az vm deallocate -n kafka-broker-2 -g kafka_lab

