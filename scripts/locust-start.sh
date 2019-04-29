#!/usr/bin/env bash

# http://www.philchen.com/2015/08/08/how-to-make-a-scalable-python-web-app-using-flask-and-gunicorn-nginx-on-ubuntu-14-04

echo ''
echo 'args: --target=http://localhost:8000 --master'
echo 'args: --target=http://localhost:8000 --slave --master-host=0.0.0.0'
echo 'export TARGET=http://localhost:8000; export MASTER=true; export SLAVE=true; export MASTER_HOST=0.0.0.0'
echo ''

for i in "$@"
do
case $i in
    -f=*|--file=*)
    A_FILE="${i#*=}"
    ;;
    -t=*|--target=*)
    A_TARGET="${i#*=}"
    ;;
    -m|--master)
    A_MASTER=true
    ;;
    -s|--slave)
    A_SLAVE=true
    ;;
    --master-host=*)
    A_MASTER_HOST="${i#*=}"
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
        # unknown option
    ;;
esac
done

# get vars from args or from env
if [[ -z ${A_FILE} ]]; then FILE=${FILE}; else FILE=${A_FILE}; fi
if [[ -z ${A_TARGET} ]]; then TARGET=${TARGET}; else TARGET=${A_TARGET}; fi
if [[ -z ${A_MASTER} ]]; then MASTER=${MASTER}; else MASTER=${A_MASTER}; fi
if [[ -z ${A_SLAVE} ]]; then SLAVE=${SLAVE}; else SLAVE=${A_SLAVE}; fi
if [[ -z ${A_MASTER_HOST} ]]; then MASTER_HOST=${MASTER_HOST}; else MASTER_HOST=${A_MASTER_HOST}; fi

# file (test.py)
if [[ -n ${FILE} ]];
    then
        echo 'test file: ' ${FILE}
    else
        ERROR_MSG='test file is required'
        echo 'ERROR: ' $ERROR_MSG
        exit -1
fi

# marathon provide dynamic port info using PORT0
if [[ -n ${PORT0} ]];
    then
        WEB_PORT=${PORT0}
        echo 'web-port:' ${WEB_PORT}
    else
        WEB_PORT=8089
fi

# target (rest service)
if [[ -n ${TARGET} ]];
    then
        echo 'target: ' ${TARGET}
    else
        ERROR_MSG='target is required, example: http://localhost:8000'
        echo 'ERROR: ' $ERROR_MSG
        exit -1
fi

# check if var is devined
if [[ -n ${MASTER} ]];
    then
        echo 'master mode'
        locust -f $A_FILE --host $TARGET --master --web-port=${WEB_PORT}
    else
        if [[ -n ${SLAVE} ]];
            then
                # slave required master host
                if [[ -n ${MASTER_HOST} ]];
                    then
                        echo 'slave mode with master on: ' ${MASTER_HOST}
                        locust -f $A_FILE --host $TARGET --web-port=${WEB_PORT} --slave --master-host=$MASTER_HOST
                    else               
                        ERROR_MSG='for slave mode, MASTER_HOST is required'
                        echo 'ERROR: ' $ERROR_MSG
                        exit -1
                fi
            else
                echo 'single mode'
                locust -f $FILE --host $TARGET --web-port=${WEB_PORT}
        fi
fi
