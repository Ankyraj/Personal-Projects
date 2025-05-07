const express= require("express"); 
const app =express ();

app.get("/", (req, res)=>{
res.json([
    {
        id: 1,
        name: "Harsh", 
        age: 24
    },
    {
        id: 2,
        name: "Ankit", 
        age: 27
    },
    {
        id: 3,
        name: "Nidhi", 
        age: 26
    }
])
});

app.listen (5500, ()=>{
    console. log("app is running on 5500 port")
    })