import http from "http";
import server from "./server";
import db from "./db.js";
import https from "https";
import fs from "fs";

const HTTP_PORT = 8000;
const HTTPS_PORT = 8080;

const options = {
    key: fs.readFileSync('/home/fitboa/Fitboa/certifications/www_youarethe.co.kr.key'),
    cert: fs.readFileSync('/home/fitboa/Fitboa/certifications/www_youarethe.co.kr_cert.crt'),
    ca: fs.readFileSync('/home/fitboa/Fitboa/certifications/www_youarethe.co.kr_root_cert.crt'),
};

http.createServer(server).listen(HTTP_PORT, () => {
    console.log(`http listening port:${HTTP_PORT}`);
});
https.createServer(options, server).listen(HTTPS_PORT, () => {
    console.log(`https listening port:${HTTPS_PORT}`);
});