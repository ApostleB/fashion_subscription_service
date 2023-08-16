import express from "express";
import schedule from "node-schedule";

import apiRouter from "./routes/apiRouter";
import dbConfig from "./config/dbConfig.json";

const app = express();

import dayjs from "dayjs";

const job = schedule.scheduleJob('30 * * * * *', () => {
    const time = dayjs().format('YYYYMMDDhhmmss');
    console.log("스케쥴러 테스트 현재 시간 : ",time);
})


/*
sudo pm2 start "npm run dev" --name fitboaTEST
sudo pm2 delete fitboaTEST

sudo pm2 start "npm run scheduler" --name schedulerTEST
sudo pm2 delete schedulerTEST
*/