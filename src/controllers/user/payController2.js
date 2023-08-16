import axios from "axios";
import crypto from "crypto";
import payConfig from "../../config/payConfig.json";
import {v1} from "uuid"
import dayjs from "dayjs";
import db from "../../db";
import { handelSqlError } from "../../libraries/handleSqlError";
import { setBillingKey } from "./payController";

//결제 카드 변경
export const changeBilling = async (req,res) => {
    const {
        resultcode,resultmsg,cardcd,billkey,mid,tid,authkey,orderid,cardno,
        merchantreserved,p_noti,data1,cardkind,pgauthdate,pgauthtime,CheckFlag
    } = req.body;

    const customOrderId = orderid.split('-');

    let productType = "M";  //기본 월결제
    let productId = null;
    let customUserId = null;
    let promotionCode = null;

    if (customOrderId.length === 3) {
        /*promotion Code 없음*/
        productType = customOrderId[0].slice(0, 1) === "M" ? 0 : 1; //연간 결제 = Y 월간 결제 = M
        productId = customOrderId[0].slice(1, customOrderId[0].length);
        customUserId = Number(customOrderId[1]);
        promotionCode = null;
        console.log(customOrderId.length,"프로모션 코드 없음");
        console.log(productType,productId,customUserId,promotionCode);
    } else if (customOrderId.length === 4) {
        /*promotion Code 있음*/
        productType = customOrderId[0].slice(0, 1) === "M" ? 0 : 1; //연간 결제 = Y 월간 결제 = M
        productId = Number(customOrderId[0].slice(1, customOrderId[0].length));
        customUserId = Number(customOrderId[1]);
        promotionCode = Number(customOrderId[2]);
        console.log(customOrderId.length,"프로모션 코드 있음");
        console.log(productType,productId,customUserId,promotionCode);
    } else {
      return res.status(400).json({ message: "잘못된 값입니다." });
    }
    //빌링키 발급에 성공
    if(req.body.resultcode === "00"){
        console.log(
            customUserId, resultcode, resultmsg, PGAuthDateTime, tid,mid,
            orderid, billkey, authkey, cardcd, cardno, cardkind, CheckFlag,
            data1, merchantreserved === '' ? null : merchantreserved
        );
        const conn = await db();
        const PGAuthDateTime = pgauthdate + pgauthtime;
        try{            
            const saveBilling = await conn.query(`CALL Change_Next_Billing_Card(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,[
                customUserId, resultcode, resultmsg, PGAuthDateTime, tid,mid,
                orderid, billkey, authkey, cardcd, cardno, cardkind, CheckFlag,
                data1, null
                //merchantreserved === '' ? null : merchantreserved
            ])
            console.log("세이브 빌링",saveBilling);
            res.status(200).json("success");
        }catch(changeErr){
            console.log(changeErr);
            //에러 발생 하면 어찌함?
            if(handelSqlError(changeErr)){
                return res.redirect(`https://192.168.0.2:8080/mypage/sub2/?message=DB 저장중 에러가 발생했습니다. \n${changeErr.text}`);
            }
            else return res.redirect(`https://192.168.0.2:8080/mypage/sub2/?message=DB 저장중 에러가 발생했습니다.`);
        }finally{
            
        }
        
    }else{
        if(req.body.resultcode){
            console.log("code : ",req.body.resultcode);
            console.log("resultmsg", req.body.resultmsg);
            return res.redirect(`https://192.168.0.2:8080/mypage/sub2/?message=카드 변경에 실패하였습니다.`);
        }else{
            return res.redirect(`https://192.168.0.2:8080/mypage/sub2/?message=PG Server ERR : 카드 변경에 실패하였습니다.`);
        }
    }
}

//객체별 정기결제시도
export const schedulePayment = async (payData) => {
    // Id: 53,
    // MId: 'INIBillTst',
    // MOId: 'M1-53-1652438755472',
    // ProductName: '구독상품1',
    // Name: 'jung',
    // Username: 'jung@nate.com',
    // Contact: '010-5099-1699',
    // Price: '1000',
    // BillKey: '7e7afe9250722d88b5bbf10973759633f5500b1e'
    const { Id,MId,MOId,ProductName,Name,Username,Contact,Price,BillKey } = payData;
    
    const time = dayjs().format('YYYYMMDDhhmmss');

    //결제 시도 데이터 준비
    const params = {
        INIAPIKey : payConfig.INIAPIKey,
        url: payConfig.HOME_URL,
        type:payConfig.TYPE,
        paymethod: "Card",
        timestamp: time,
        clientIp: "15.165.48.193",
        orderid: payData.MOId,
        price: payData.Price,
        mid: payData.MId,
        billkey: payData.BillKey,
        goodName: payData.ProductName,
        buyerName: payData.Username, //값 바뀜 ㅇㅋ
        buyerEmail: payData.Name, //값 바뀜 ㅇㅋ
        buyerTel: payData.Contact, //값 바뀜 ㅇㅋ
        authentification: "00",
    }

    //데이터 해쉬로 묶기
    const data = params.INIAPIKey +params.type +params.paymethod +
    params.timestamp +params.clientIp +params.mid +
    params.orderid +params.price +params.billkey;
    const hashData = crypto.createHash("sha512").update(data).digest("hex");

    console.log(params);
    const fetchRes = await axios({
        url:payConfig.BILLING_V1,
        method:payConfig.METHOD,
        headers:{
            "Content-type":payConfig.ContentType
        },
        params: {
            type: params.type,
            paymethod: params.paymethod,
            timestamp: params.timestamp,
            clientIp: params.clientIp,
            mid: params.mid,
            url: params.url,
            moid: params.orderid,
            goodName: params.goodName,
            buyerName: params.buyerName,
            buyerEmail: params.buyerEmail,
            buyerTel: params.buyerTel,
            price: params.price,
            billKey: params.billkey,
            authentification: params.authentification,
            hashData: hashData,
        }
    })
    
    console.log(fetchRes)

    // const dataSet = {
    //     UserId:payData.UserId,
    //     UserName:params.buyerName,
    //     UserContact:params.buyerTel,
    //     UserEmail:params.buyerEmail,
    //     CardId:payData.CardId,
    //     ResultCode:fetchRes.data.resultCode,
    //     ResultMsg:fetchRes.data.resultMsg,
    //     PayDateTime:params.timestamp,
    //     PayAuthCode:params.authentification,
    //     TId:fetchRes.data.tid,
    //     Price:fetchRes.price,
    //     CardCode:fetchRes.data.cardCode,
    //     CardQuota:fetchRes.data.cardQuota,
    //     CheckFlg:fetchRes.data.checkFlg,
    //     PrtcCode:fetchRes.data.prtcCode,
    //     MOId:params.moid,
    //     ProductId:"",
    //     ProductName:"",
    //     ProductNo:"",
    //     ProductPrice:"",
    //     ProductMonthlyPrice,
    //     ProductYearlyDiscountRate,
    //     Type,
    // }

    console.log("이니시스 결제 요청 결과 : ", fetchRes.data);
    if(fetchRes.data.resultCode === "00"){
        console.log("결제가 성공");
        const save = afterPaymentSave();
        if(save){
            //최종 성공
        }else{
            //결제 취소
        }
    }else{
        console.log("결제 실패");
        console.log(fetchRes.data);
    }


}

//객체별 정기결제 시도 후 DB저장
export const afterPaymentSave = async () => {

    const conn = await db();

    try{
        //결제 후
        const setBill = await conn.query(`CALL Set_Billing_Scheduler()`,[]);
        console.log();
    }catch(err){
        console.log("결제 시도 후 DB저장 중 에러발생", err.text);
    }finally{
        conn.release();
        return;
    }
}
/*
UserId
UserName
UserContact
UserEmail
CardId
ResultCode
ResultMsg
PayDateTime
PayAuthCode
TId
Price
CardCode
CardQuota
CheckFlg
PrtcCode
MOId
ProductId
ProductName
ProductNo
ProductPrice
ProductMonthlyPrice
ProductYearlyDiscountRate
Type
*/