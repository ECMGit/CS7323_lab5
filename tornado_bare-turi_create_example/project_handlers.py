#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from PIL import Image
from basehandler import BaseHandler
from pycket.session import SessionMixin
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
import pickle
from bson.binary import Binary
import json
import numpy as np

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class AuthBaseHandler(BaseHandler, SessionMixin):
    def get_current_user(self):
        return self.session.get('user_info', None)
        
# class AddUserHandler(BaseHandler):
#     def post(self):
        


class UploadImageHandler(BaseHandler):
    def post(self):
        data = self.request.files.get("image", None)[0]
        print("received : filename ", data["filename"])
        save_to = 'static/uploads/{}'.format(data['filename'])
        with open(save_to,'wb') as f:
            f.write(data['body'])
            
        # dsid = int(data['dsid'])
        # image  = Image.open("static/uploads/file.jpeg").convert("L")
        # image_array = (255 - np.array(image))
        # fvals = image_array.flatten().reshape(1,-1)

       	# if(self.clf == []):
        #     print('Loading Model From DB')
        #     tmp = self.db.models.find_one({"dsid":dsid})
        #     self.clf = pickle.loads(tmp['model'])
        # predLabel = self.clf.predict(fvals)
        self.write_json({"message":"upload successfully"})


class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))
        image  = Image.open("static/uploads/file.jpeg").convert("L")
        # print(np.array(image))
        image_array = (255 - np.array(image))
        fvals = image_array.flatten().tolist()
        label = data['label']
        sess  = int(data['dsid'])
        dbid = self.db.labeledinstances.insert(
            {"feature":fvals,"label":label,"dsid":sess}
            )
        # self.write_json({"id":str(dbid),
        #     "feature":[str(len(fvals))+" Points Received",
        #             "min of: " +str(min(fvals)),
        #             "max of: " +str(max(fvals))],
        #     "label":label})

class RequestNewDatasetId(BaseHandler):
    def get(self):
        '''Get a new dataset ID for building a new dataset
        '''
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid'])+1
        self.write_json({"dsid":newSessionId})

class UpdateModelForDatasetId(BaseHandler):
    def post(self):
        '''Train a new model (or update) for given dataset ID
        '''
        jsondata = json.loads(self.request.body.decode("utf-8"))  
        dsid = int(jsondata['dsid'])
        modeltype = "KNN"
        modeltype = jsondata["modeltype"]

        # create feature vectors from database
        f=[]
        for a in self.db.labeledinstances.find({"dsid":dsid}): 
            f.append([float(val) for val in a['feature']])

        # create label vector from database
        l=[]
        for a in self.db.labeledinstances.find({"dsid":dsid}): 
            l.append(a['label'])

        # fit the model to the data
        if modeltype == "SVM":
            print("Using Support Vector Machine")
            c1 = SVC()
        
        else:
            neighbors = int(jsondata["neighbors"])
            print("Using K-Nearest Neighbors")
            c1 = KNeighborsClassifier(n_neighbors=neighbors)
        acc = -1
        if l:
            c1.fit(f,l) # training
            lstar = c1.predict(f)
            self.clf = c1
            acc = sum(lstar==l)/float(len(l))
            bytes = pickle.dumps(c1)
            self.db.models.update({"dsid":dsid},
                {  "$set": {"model":Binary(bytes)}  },
                upsert=True)

        # send back the resubstitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"modelType": modeltype ,"resubAccuracy":acc})

class PredictOneFromDatasetId(BaseHandler):
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        data = json.loads(self.request.body.decode("utf-8"))
        dsid = int(data["dsid"])
        image  = Image.open("static/uploads/file.jpeg").convert("L")
        # print(np.array(image))
        image_array = (255 - np.array(image))
        fvals = image_array.flatten().reshape(1,-1)
        # print(fvals.shape)
        # print(fvals)
        # load the model from the database (using pickle)
        # we are blocking tornado!! no!!
        if(self.clf == []):
            print('Loading Model From DB')
            tmp = self.db.models.find_one({"dsid":dsid})
            self.clf = pickle.loads(tmp['model'])
        predLabel = self.clf.predict(fvals)
        self.write_json({"prediction":str(predLabel)})


class UploadTrainDataHandler(BaseHandler):
     def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))
        vals = data['feature']
        label = data['label']
        sess  = data['dsid']

        dbid = self.db.labeledinstances.insert(
            {"feature":vals,"label":label,"dsid":sess}
            )