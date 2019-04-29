# locust master
run-load-tests-master:
	./scripts/locust-start.sh --file=src/load_test_script.py  --target=http://13.67.48.85:8000 --master &

# locust slave
run-load-tests-slave:
	./scripts/locust-start.sh --file=src/load_test_script.py  --target=http://13.67.48.85:8000 --slave --master-host=0.0.0.0 &

REPO=grabds/locust
TAG=dynamic-service-menu-dev

# build image
docker-build:
	# only rebuild docker image
	docker build -t $(REPO):$(TAG) .
