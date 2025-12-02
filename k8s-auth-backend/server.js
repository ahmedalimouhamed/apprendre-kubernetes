import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import {createClient} from "redis";

dotenv.config();

const app = express();
app.use(express.json());

await mongoose.connect(process.env.MONGO_URI);
console.log("Connected to MongoDB");

const redisClient = createClient({url: `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`});
await redisClient.connect();
console.log("Connected to Redis");

const userSchema = new mongoose.Schema({
    username: {type: String, unique: true},
    password: String
});

const User = mongoose.model("User", userSchema);

const authMiddleware = async (req, res, next) => {
    const token = req.headers.authorization?.split(" ")[1];
    if(!token) return res.status(401).json({message: "Token missing"});
    try{
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    }catch{
        res.status(401).json({message: "Invalid token"});
    }
};

app.post("/signup", async (req, res) => {
    const {username, password} = req.body;
    const hash = await bcrypt.hash(password, 10);
    await User.create({username, password: hash});
    res.status(201).json({message: "user created"});
});

app.post("/login", async(req, res) => {
    const {username, password} = req.body;
    const user = await User.findOne({username});
    if(!user) return res.status(404).json({message: "User not found"});

    const valid = await bcrypt.compare(password, user.password);
    if(!valid) return res.status(401).json({message: "Invalid Credentials"});

    const token = jwt.sign({username}, process.env.JWT_SECRET, {expiresIn: "1h"});
    await redisClient.set(`session:${username}`, token,{EX: 3600});
    res.json({token});
});

app.get("/profile", authMiddleware, async(req, res) => {
    const token = await redisClient.get(`session:${req.user.username}`);
    if(!token) return res.status(401).json({message: "Session expired"});
    res.json({message: `Welcome ${req.user.username}`});
});

app.get("/health", (req, res) => res.send("OK"));
app.get("/ready", (req, res) => res.send("READY"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`auth service running on port ${PORT}`));