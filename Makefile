.PHONY: info dev banner local

github = git@github
repo = kafka-metrics
tag = v$(shell date '+%Y%m%d%H%M')

define assembly
	sbt clean assembly
	cp target/scala-2.12/KafkaMetrics-assembly-*.jar $(1)/kafka-kerberos
endef

define copy
	mkdir -p /tmp/$(repo)/k8s
	cp -R docker                                     /tmp/$(repo)
	cp deploy/k8s/kafka-metrics-service.conf         /tmp/$(repo)
	cp deploy/k8s/kafka-metrics-deployment.yaml      /tmp/$(repo)/k8s
endef

define end
	rm -rf /tmp/$(repo)
	@echo "End"
endef

info: banner
	@echo "Push files of Kafka Metrics calculation under Kubernetes"
	@echo
	@echo "  - info     : show the help usage."
	@echo "  - assembly : make a fat jar of KafkaMetrics."
	@echo "  - dev      : publish a DEV branch for deploying into development kubernetes cluster."
	@echo "  - local    : testing in a LOCAL environment with Docker."
	@echo

banner:
	@echo "_  _ ____ ____ _  _ ____    _  _ ____ ___ ____ _ ____ ____ "
	@echo "|_/  |__| |___ |_/  |__|    |\/| |___  |  |__/ | |    [__  "
	@echo "| \_ |  | |    | \_ |  |    |  | |___  |  |  \ | |___ ___] "
	@echo "                                                           "

assembly:
	$(call assembly,.)

dev: banner
	@echo "Preparing git clone ..."
	@bash deploy/scripts/git-prepare.sh $(gitlab) $(repo) "dev"
	$(call assembly,/tmp/$(repo))
	$(call copy)
	@bash deploy/scripts/git-publish.sh $(repo) "deploying" "dev" $(tag)
	$(call end)

local: banner assembly
	@docker build -t angelrojo/kafka-kerberos:1.0 .
	@docker run -it angelrojo/kafka-kerberos:1.0
