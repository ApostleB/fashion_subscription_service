import express from "express";
import cors from "cors"
import session from "express-session";
import MySQLStore from "express-mysql-session";
import path from "path";
import schedule from "node-schedule";

import apiRouter from "./routes/apiRouter";
import adminApiRouter from "./routes/adminApiRouter";
import { passwordCrtpto, handelRequestDeny, traceMiddleware, scheduler, deleteVerifyIdSession, deleteMypageLoginOnce } from "./middlewares";
import sessionConfig from "./config/sessionConfig.json";
import dbConfig from "./config/dbConfig.json";
import payConfig from "./config/payConfig.json";
import {VUE_ROUTE_LIST} from "./libraries/vueRouter";
import { sessionOptions } from "./libraries/sessionOptions";
import { payScheduler } from "./libraries/scheduler"
import cookieParser from "cookie-parser";
const app = express();



//세션 설정
app.use(session({
    name:"FitboaAPI",
    secret:sessionConfig.COOKIE_SECRET,
    key: sessionConfig.SESSION_KEY,
    saveUninitialized:false,
    resave:false,
    store: new MySQLStore(sessionOptions)
}));
app.use(cookieParser());

app.use((req, res, next) => {
    console.log(`${req.secure ? 'https://' : 'http://'}${req.headers.host}${req.url}`);
    if(req.secure){
        next();
    }else{
        // let to = "https://" + req.headers.host + req.url;
        // console.log(to);

        // res.redirect("https://" + req.headers.host + req.url);
        res.redirect("https://" + req.hostname + req.url);
        // console.log(req.hostname);
        return;
    }
});
//back안보이게 하는거
app.disable('x-powered-by');
let corsOption = {
    origin: 'http://plushdev.com:8080', // 허락하는 요청 주소
    credentials: true, // true로 하면 설정한 내용을 response 헤더에 추가 해줍니다.
    exposedHeaders:["Content-Disposition"], //빌드시 삭제
};
app.use(cors(corsOption)); // CORS 미들웨어 추가
app.use("*", handelRequestDeny); //Deny Anything except GET or POST
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


//정기결제 스케쥴러
import db from "./db";
import crypto from "crypto";
import dayjs from "dayjs";
import { schedulePayment } from "./controllers/user/payController2";

const job2 = schedule.scheduleJob('0 0 * * * *', async () => {
    const hour = dayjs().format("hh");
    const miniute = dayjs().format("mm");
    const seconds = dayjs().format("ss");
    // console.log(`${hour}시 ${miniute}분 ${seconds}초`);
    console.log("scheduler : ",`${hour}시 ${miniute}분 ${seconds}초`);
    const conn = await db();
    try{
        const paymentTargets = await conn.query(`CALL Get_Billing_Scheduler()`);
        conn.release();
        for(let i = 0 ; i < paymentTargets[0].length ; i++){
            console.log("스케쥴러 테스트 : ",paymentTargets[0][i]);
            // console.log(i);

            //결제시도
            // schedulePayment(paymentTargets[0][i]);

            //결제 시도
        }
        // Set_Billing_Scheduler
    }catch(err){
        console.log(err);
        conn.release();
        return;
    }
    return;
})

// app.use(payScheduler());

// const job = schedule.scheduleJob('0 */2 * * *', (req, res) => {
//     const year = dayjs().format("YY");
//     const month = dayjs().format("MM");
//     const days = dayjs().format("DD");
//     const hour = dayjs().format("hh");
//     const miniute = dayjs().format("mm");
//     const seconds = dayjs().format("ss");
//     console.log(`${year}년 ${month}월 ${days}일 ${hour}시 ${miniute}분 ${seconds}초`);
//     return;
// })


app.use('/js', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/js${req.path}`));
})

app.use('/css', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/css${req.path}`));
})

app.use('/img', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/img${req.path}`));
})

app.use('/images', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/images${req.path}`));
})

app.use('/fonts', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/fonts${req.path}`));
})

app.get('/favicon.ico', (req, res, next) => {
    res.sendFile(path.join(__dirname, `./views/app/favicon.ico`));
})

app.use((req, res, next) => {
    if (VUE_ROUTE_LIST.includes(req.path)) {
        res.sendFile(path.join(__dirname, `./views/app/index.html`));
        return;
    }
    next();
})

// app.use(passwordCrtpto);
app.use(traceMiddleware);
app.use(deleteVerifyIdSession);
app.use(deleteMypageLoginOnce);
app.use("/api", apiRouter);
app.use("/admin/api", adminApiRouter);
export default app;