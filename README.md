CS7323 flip4:

Student : Junhao Shen, CJ Sayre, Reid Russell

For Thought:

11. Is the current method of saving the classifier blocking to the tornado IOLoop? Justify your response.

    Answer: Yes, indeed, we use a blocking call in the function, the server will response after model trained.

12. Would the models saved on one server be useable by another server if we migrated the saved documents in MongoDB? Justify your response.

    Answer: Yes, we can reuse the model data to another server if we migrated the document in MongoDB.