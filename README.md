CS7323 Lab5:

Student : Junhao Shen, CJ Sayre, Reid Russell

backend

```
> python tornado_project.py
```

using AlamoFire for Http request on IOS

Drawing page reference: https://github.com/vin20777/Swift-Paint





API

/Handlers[/]?        ph.PrintHandlers

/AddDataPoint[/]?    ph.UploadLabeledDatapointHandler

/UpdateModel[/]?,     ph.UpdateModelForDatasetI			update Choosing model by choosing dataset

/PredictOne[/]?,      ph.PredictOneFromDatasetId),			predict by choosing model

/UploadImage[/]?,     ph.UploadImageHandler),				upload image

/Login[/]?,           auth.LoginHandler),									user login

/Register[/]?,        auth.RegisterHandler),								user register

/Logout[/]?,          auth.LogoutHandler),								user logout

/UploadTrainSet[/]?,  ph.UploadTrainDataHandler)			(optional API) uploading training dataset