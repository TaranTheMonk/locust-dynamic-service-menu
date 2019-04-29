from locust import HttpLocust, TaskSet, task
from unittest.mock import MagicMock
import pandas as pd
import os
import json
from random import randint
import datetime
import random
from pytz import timezone


def check_result(service_response, result_e, max_error_percent=0.05, precision=4):
    """
    check server response and compare with etalon
    raise exception if not equal
    """
    # service result
    #['vehicle_type_id', "score"]
    result = service_response

    top_1 = int(result[0]['vehicle_type_id'])
    top_2 = int(result[1]['vehicle_type_id'])

    print("expected: ", result_e)
    print("result1: ", top_1)
    print("result2: ", top_2)


    # if top_1!=result_e and top_2!=result_e:
    #
    #     msg = 'top_1 is not equal to result and top_2 is not equal to result'
    #     raise Exception(msg)


def load_test_data(data_path):
    #---load data in .json format
    f = open(data_path)
    r = json.loads(f.read())

    #SeriesID is identifier for each unique priceChecking
    #Chosen indicator is used to indicate whether pax booked this vehicle type

    return r


def min_max_norm(x, min, max):
    return (x - min) / (max - min)


def min_max_reverse(z, min, max):
    return z * (max - min) + min


def rnd_val(min, max):
    x = random.random()
    return min_max_reverse(x, min, max)


class Ctx:
    """
    store compiled_src dataset
    """

    r = load_test_data(
        #--for local test
        #data_path='/Users/rui.tan/docker/dynamic_service_menu/.data/testRecords_sg.json'.format(os.getcwd())
        #  for docker image test
        data_path = '{}/resources/testRecords_regional.json'.format(os.getcwd())
    )


class ModelPredict(TaskSet):

    def on_start(self):
        print('current dir: {}'.format(os.getcwd()))

    @task(1)
    def test_dynamic_service_menu_singapore_v1(l):

        rnd_idx = randint(0, Ctx.r.__len__() - 1) #works
        # req = {
        #     "records": [
        #         Ctx.x_test.iloc[rnd_idx].to_dict()
        #     ]
        # }
        # use pandas json serializer
        req = Ctx.r[rnd_idx]
        req_header = {'content-type': 'application/json'}
        meta_data = req['metadata']
        city_id = int(req["city_id"])

        req = {"records": req}

        # if city_id in (1, 4, 5, 6,9,10, 14, 46, 82):
        #     resultR = l.client.post("/api/v1/predict/dynamic_service_menu?tag=city_id_{}_v1".format(city_id), json=req,
        #                             headers=req_header, catch_response=True)
        # else:
        #     resultR = l.client.post("/api/v1/predict/dynamic_service_menu?tag=city_id_regional_v1", json=req,
        #                             headers=req_header, catch_response=True) # data=req

        resultR = l.client.post("/api/v1/predict/dynamic_service_menu?tag=v1", json=req,
                                     headers=req_header, catch_response=True)
        #print(resultR)
        #print(resultR.status_code)
        if resultR.status_code == 500:
            r_json = resultR.json()
            print("debug 500:")
            print(req)
            print(r_json)
        if resultR.status_code == 200:
            try:
                r_json = resultR.json()["result"]
                #print(type(r_json))
                # print(r_json)
                result_e = int(pd.DataFrame(meta_data).query("chosen >0.0").vehicle_type_id.values[0]) # Send the vector id with chosen = 1
                check_result(
                    service_response=r_json,
                    result_e=result_e
                )
                resultR.success()

            except Exception as ex:
                resultR.failure(str(ex))
        else:
            resultR.failure('status code: {}'.format(resultR.status_code))

class WebsiteUser(HttpLocust):
    task_set = ModelPredict
    min_wait = 5000
    max_wait = 9000
