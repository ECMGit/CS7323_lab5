import tornado.web
from project_handlers import AuthBaseHandler
from passlib.hash import sha256_crypt
import json


class RegisterHandler(AuthBaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        username = data['username']
        password = data['password']
        # dsids = []
        hashpwd = sha256_crypt.hash(password)
        dbid = self.db.users.insert({"username":username,"password":hashpwd})
        self.write_json({"username":username,
                         "password":password})


class LoginHandler(AuthBaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        username = data['username']
        password = data['password']
        passed = False
        if username == "junhaos" and password == "123":
            passed = True
        # user = self.db.users.find({"username":username})
        # passed = False
        # if user == None:
        #     self.write_json({"code": 404, "message": "User not existed"})
        # else:
        #     passed = sha256_crypt.verify(password, user["password"])
        
        if passed:
            # self.session.set('user_info',username) #set username as cookie info
            self.write_json({"code": "200", "message": "Login Successfully"})
        else:
            self.write_json({"code": "400", 'message':'login fail'})

class LogoutHandler(AuthBaseHandler):
    def get(self):
        self.session.delete('user_info')
        self.write_json({"code": "200", "message": "logout successfully"})