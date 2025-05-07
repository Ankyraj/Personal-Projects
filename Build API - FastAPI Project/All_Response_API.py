from fastapi import FastAPI, Path, Query, HTTPException, status
from typing import Optional
from pydantic import BaseModel

app = FastAPI()

# Data model for creating an item
class Item(BaseModel):
    name: str
    price: float
    brand: Optional[str] = None

# Data model for updating an item
class UpdateItem(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    brand: Optional[str] = None

# Simulated inventory
inventory = {}

# Endpoint to get item by ID
@app.get("/get-item/{item_id}")
def get_item(item_id: int = Path(..., description="The ID of the item you'd like to view.", gt=0)):
    if item_id not in inventory:
        raise HTTPException(status_code=404, detail="Item not found.")
    return inventory[item_id]

# Endpoint to get item by name
@app.get("/get-by-name")
def get_item_by_name(name: str = Query(..., title="Name", description="Name of item.", max_length=10, min_length=2)):
    for item_id in inventory:
        if inventory[item_id].name == name:
            return inventory[item_id]
    raise HTTPException(status_code=404, detail="Item name not found.")

# Endpoint to create an item
@app.post("/create-item/{item_id}")
def create_item(item_id: int, item: Item):
    if item_id in inventory:
        raise HTTPException(status_code=400, detail="Item ID already exists.")
    inventory[item_id] = item
    return inventory[item_id]

# Endpoint to update an item
@app.put("/update-item/{item_id}")
def update_item(item_id: int, item: UpdateItem):
    if item_id not in inventory:
        raise HTTPException(status_code=404, detail="Item ID does not exist.")
    if item.name is not None:
        inventory[item_id].name = item.name
    if item.price is not None:
        inventory[item_id].price = item.price
    if item.brand is not None:
        inventory[item_id].brand = item.brand
    return inventory[item_id]

# Endpoint to delete an item
@app.delete("/delete-item")
def delete_item(item_id: int = Query(..., description="The ID of the item to delete.", gt=0)):
    if item_id not in inventory:
        raise HTTPException(status_code=404, detail="Item ID does not exist.")
    del inventory[item_id]
    return {"success": True, "message": f"Item {item_id} deleted."}