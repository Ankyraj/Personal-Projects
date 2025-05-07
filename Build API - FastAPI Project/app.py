from fastapi import FastAPI

app = FastAPI()

@app.get('/predict')
def predict_model(age: int, sex:str):
# Below is a demo rule based model. Assume a complex model here.
    if age<15 or sex=='F':
        return {'survived': 1}
    else:
        return {'survived': 0}