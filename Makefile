# locust master
run-stage-load-tests-master:
    ./scripts/locust-start.sh --file=src/load_test_script.py  --target=http://13.67.48.85:8000 --master

# locust slave
run-stage-load-tests-slave:
    ./scripts/locust-start.sh --file=src/load_test_script.py  --target=http://13.67.48.85:8000 --slave --master-host=0.0.0.0
