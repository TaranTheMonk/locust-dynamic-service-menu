FROM python:3.6

ENV LOCUST_DIR /locust
RUN mkdir -p ${LOCUST_DIR}

ADD ./src ${LOCUST_DIR}/src
ADD ./resources ${LOCUST_DIR}/resources
ADD ./scripts ${LOCUST_DIR}/scripts
ADD ./Makefile ${LOCUST_DIR}/Makefile
ADD ./requirements.txt ${LOCUST_DIR}/requirements.txt

WORKDIR ${LOCUST_DIR}

RUN pip install -r requirements.txt

ENTRYPOINT ["sh", "./scripts/docker-entrypoint.sh"]