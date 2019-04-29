# locust master
run-load-tests:
	./scripts/locust-start.sh --file=src/load_test_script.py  --target=http://13.67.48.85:8000

REPO=grabds/locust
TAG=dynamic-service-menu-dev

# build image
docker-build:
	# only rebuild docker image
	docker build -t $(REPO):$(TAG) .

docker-push:
	docker push $(REPO):$(TAG)
