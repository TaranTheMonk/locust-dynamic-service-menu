FROM python:3.6

ADD ./src /locust/src
ADD ./resources /locust/resources
ADD ./scripts /locust/scripts
ADD ./Makefile /locust/Makefile
ADD ./requirements.txt /locust/requirements.txt