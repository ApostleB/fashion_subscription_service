import axios from "axios";
import crypto from "crypto";
import payConfig from "../../config/payConfig.json";
import {v1} from "uuid"
import dayjs from "dayjs";
import db from "../../db";
import { handelSqlError } from "../../libraries/handleSqlError";
import requestIp from "request-ip";
import res from "express/lib/response";

/////////////

export const getInicis = (req, res) => {
    console.log("PARAMS : ",req.params, "QUERYS : ",req.query);
    return;
}

export const payInicis = async (req, res) => {
    const CardId = req.body.CardId ?? null ;
    const userId = req.session.user ? req.session.user.Id : null;

    let ip = requestIp.getClientIp(req);
    ip = ip.substring(7);

    console.log("Card ID : "+CardId, "User ID : "+ userId);
    if(userId === null || CardId === null){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
    const conn = await db();
    try{
        const billing = await conn.query(`CALL Get_Billing_Key(?,?)`,[userId, 1]);
        
        console.log("GET Billing Key",billing[0][0]);
        if(billing[0][0] === undefined){
            return res.status(400).json({message:"잠시후 다시 시도해주세요 : BIL!1"})
        }
        try{
            const time = dayjs().format('YYYYMMDDhhmmss');
            const params = {
                INIAPIKey: payConfig.INIAPIKey,
                url: payConfig.HOME_URL, //값 바뀜 ㅇㅋ
                type: payConfig.TYPE,
                paymethod: payConfig.PAYMETHOD, //값 바뀜 ㅇㅋ
                timestamp: time, //값 바뀜 ㅇㅋ Length값 바뀌면 안됨
                clientIp: ip, //값 바뀜 ㅇㅋ
                orderid: req.body.orderid, //값 바뀜 ㅇㅋ
                price: "1000", //값 바뀜 ㅇㅋ
                mid: billing[0][0].MId, //값 바뀜 X
                billkey: billing[0][0].BillKey, //값 바뀜 X
                goodName: "test02", //값 바뀜 ㅇㅋ
                buyerName: billing[0][0].UserName, //값 바뀜 ㅇㅋ
                buyerEmail: billing[0][0].Username, //값 바뀜 ㅇㅋ
                buyerTel: billing[0][0].UserContact, //값 바뀜 ㅇㅋ
                authentification: "00",
            };
            const data = payConfig.INIAPIKey + params.type +params.paymethod + params.timestamp + 
            params.clientIp + params.mid + params.orderid + params.price + params.billkey;
            const hashData = crypto.createHash('sha512').update(data).digest('hex');
            const fetchRes = await axios({
                url:payConfig.BILLING_V1,
                method:'POST',
                headers:{
                    "Content-type": "application/x-www-form-urlencoded;charset=utf-8"
                },
                params:{
                    type:params.type,
                    paymethod:params.paymethod,                         //지불수단 코드 [Card:신용카드, HPP:휴대폰]
                    timestamp:params.timestamp,          //전문생성시간[YYYYMMDDhhmmss]
                    clientIp:params.clientIp,
                    mid:params.mid,          //상점아이디
                    url:params.url,            //가맹점 URL
                    moid:params.orderid,                             //가맹점주문번호
                    goodName:params.goodName,                              //상품명
                    buyerName:params.buyerName,                         //구매자 명
                    buyerEmail:params.buyerEmail,           //구매자이메일주소
                    buyerTel:params.buyerTel,                 //구매자 휴대폰번호
                    price:params.price,
                    billKey:params.billkey,
                    authentification:params.authentification,                    //본인인증 여부
                    hashData:hashData,            
                }
            })
            try{
                const savePay = await conn.query(
                  `CALL Set_Billing(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                  [
                    userId,
                    params.buyerName,
                    params.buyerTel,
                    params.buyerEmail,
                    CardId,
                    fetchRes.data.resultCode,
                    fetchRes.data.resultMsg,
                    String(fetchRes.data.payDate + fetchRes.data.payTime),
                    fetchRes.data.payAuthCode,
                    fetchRes.data.tid,
                    fetchRes.data.price,
                    fetchRes.data.cardCode,
                    fetchRes.data.cardQuota,
                    fetchRes.data.checkFlg,
                    fetchRes.data.prtcCode,
                    params.orderid,
                    typeof(productId) === "number" ? productId : Number(productId), //product ID, month, year
                    productType, //type Month : 0 Year : 1
                    promotionCode ? promotionCode : null,
                  ]
                );
                console.log("Success pay");
                conn.release();
                return res.status(200).json({message:"결제가 성공적으로 이루어졌습니다."})
            }catch(saveErr){
                //결제 실패 처리            
                
                
                conn.release();
                console.log("저장중 에러발생",saveErr);
                if(handelSqlError(err)){
                    res.status(400).json({message:err.text});
                }
                else return res.status(400).json({message:"저장중 에러발생 : saveErr"})
            }
        }catch(payErr){
            console.log("payErr",payErr);
            conn.release();
            if(handelSqlError(err)){
                res.status(400).json({message:err.text});
            }
            else return res.status(400).json({message:"잠시후 다시 시도해주세요. : payErr"})
        }
    }catch(err){
        console.log(err);
        conn.release();
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
        return;
    }
}

export const cancelPay = async (req, res) => {
  const userId = req.session.user ? req.session.user.Id : null;
  const MerchantId = req.body.MerchantId ? req.body.MerchantId : null;
  
  if(!userId){
    return res.status(400).json({message:"로그인이 필요합니다."});
  }
  const conn = await db();
    try{
        const prevCancelBilling = await conn.query(`CALL Prev_Cancel_Billing(?,?)`,[MerchantId,userId])
        console.log(prevCancelBilling[0][0]);
        conn.release();
        return res.status(200).json(prevCancelBilling[0][0]);
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            conn.release();
            return res.status(400).json({message:err.text})
        }else{
            conn.release();
            return res.status(400).json({message:"잠시후 다시 시도해주세요."})
        }
  }
};

export const cancelPayDetail = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null;
  const MerchantId = req.body.MerchantId ? Number(req.body.MerchantId) : null;
  const { CancelType, CancelDetail } = req.body;
  if(!userId){
    return res.status(400).json({message:"로그인이 필요합니다."});
  }
  if(!CancelType){
    return res.status(400).json({message:"취소 사유를 선택해주세요."})
  }

  if(CancelType === "기타 사유"){
    if(!CancelDetail){
        return res.status(400).json({message:"기타 사유를 입력해주세요."});
    }
    if(CancelDetail.length > 500){
        return res.status(400).json({message:"취소 사유의 최대 허용 길이을 초과했습니다.\n500자 이내로 적어주세요."});
    }
  }

  if(CancelType.length > 40){
    return res.status(400).json({message:"취소 사유의 최대 허용 길이을 초과했습니다."});
  }
  console.log(CancelType, CancelDetail);
  const conn = await db();
  let cancel = '';
    try{
        const prevCancelBillingDetail = await conn.query(`CALL Prev_Cancel_Billing_Detail(?,?)`,[MerchantId,userId])
        console.log("#123",prevCancelBillingDetail[0][0]);
        conn.release();
        if((prevCancelBillingDetail[0][0].MId,prevCancelBillingDetail[0][0].TId)){
            console.log("바로 취소 가능 거래 : ", prevCancelBillingDetail[0][0].MId,prevCancelBillingDetail[0][0].TId);
            //fetch    
            const mid = prevCancelBillingDetail[0][0].MId;
            const tid = prevCancelBillingDetail[0][0].TId;
            let ip = requestIp.getClientIp(req);
            ip = ip.substring(7);
            const time = dayjs().format("YYYYMMDDhhmmss");
            const dataSet = {
                key: payConfig.INIAPIKey,
                type: "Refund",
                paymethod: "Card",
                timestamp: time,
                clientIp: ip,
                mid,
                tid,
                msg:CancelType
            };
            const data = dataSet.key + dataSet.type + dataSet.paymethod 
            + dataSet.timestamp + dataSet.clientIp + dataSet.mid + dataSet.tid;
            const hashData = crypto.createHash("sha512").update(data).digest("hex");

            cancel = await axios({
                url: payConfig.BILLING_REFUND,
                method: payConfig.METHOD,
                headers: {
                "Content-type": payConfig.ContentType,
                },
                params: {
                type: dataSet.type,
                paymethod: dataSet.paymethod,
                timestamp: dataSet.timestamp,
                clientIp: dataSet.clientIp,
                mid: dataSet.mid,
                tid: dataSet.tid,
                msg: dataSet.msg,
                hashData,
                },
            });
            console.log("API 호출 성공", cancel.data.cancelDate);
            console.log("API 호출 성공", cancel.data);
            if(cancel.data.cancelDate !== ''){
                const cancelDate = cancel.data.cancelDate;
                const date = cancelDate.slice(0,4)+"-"+cancelDate.slice(4,6)+
                "-"+cancelDate.slice(6);
                console.log("CANCEL DATE 문자열 재배치",cancelDate);
            }
            

            if (cancel.data.resultCode === "00") {
                console.log("취소 성공", cancel.data);
            } else {
                console.log("취소 실패", cancel.data);
                const APIdateTime = (cancel.data.cancelDate, cancel.data.cancelTime) === '' 
                    ? null: cancel.date.cancelDate+cancel.data.cancelTime;

                //DB저장
                try{
                    // Cancel_Billing
                    const saveFailCancel = await conn.query(`CALL Cancel_Billing(?,?,?,?,?,?,?,?,?)`,[
                        MerchantId, userId, 
                        cancel.data.resultCode, 
                        cancel.data.resultMsg,
                        null,
                        cancel.data.detailResultCode,
                        cancel.data.receiptInfo,
                        CancelType,CancelDetail
                    ])
                    conn.release();
                    console.log(saveFailCancel);
                    return res.status(400).json({message:
                        `취소에 실패 하였습니다.`+
                        `취소 사유 : `+cancel.data.resultMsg
                    });
                }catch(failCancelError){
                    conn.release();
                    console.log(failCancelError.text);
                    if(handelSqlError(failCancelError)){
                        return res.status(400).json({message:failCancelError.text})
                    }
                    else return res.status(400).json({message:"취소 실패, 데이터베이스 저장에 실패했습니다."})
                }
            }
        }
        try{
            console.log("save Procedure \n\n");
            let saveCancel = null;
            if((prevCancelBillingDetail[0][0].MId,prevCancelBillingDetail[0][0].TId)){
                console.log("바로 취소 가능 거래");
                
                //바로 취소 가능 거래
                saveCancel = await conn.query(`CALL Cancel_Billing(?,?,?,?,?,?,?,?,?)`,[
                    MerchantId, userId, 
                        cancel.data.resultCode, 
                        cancel.data.resultMsg,
                        null,//날짜 파싱 한거
                        cancel.data.detailResultCode,
                        cancel.data.receiptInfo,
                        CancelType,CancelDetail
                ])
                console.log("saveCancel 있냐?", saveCancel);

            }else{
                console.log("취소 예약 거래");
                saveCancel = await conn.query(`CALL Cancel_Billing(?,?,?,?,?,?,?,?,?)`,[
                    MerchantId, userId, 
                    null,
                    null,
                    null,//날짜 파싱 없으니 null
                    null,
                    null,
                    CancelType,CancelDetail
                ])
            }
            console.log("\n\n",saveCancel);
            conn.release();
            return res.status(200).json(saveCancel[0]);
        }catch(cancelError){
            conn.release();
            console.log("\n\n",cancelError);
            if(handelSqlError(cancelError)){
                return res.status(400).json({message:cancelError.text})
            }
            else return res.status(400).json({message:"취소에 실패했습니다."})
        }
    }catch(err){
        console.log(err);
        conn.release();
        if(handelSqlError(err)){
            return res.status(400).json({message:err.text})
        }
        else return res.status(400).json({message:"잠시후 다시 시도해주세요."})
  }
}

export const cancelCancel = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null;
    const MerchantId = req.body.MerchantId;
    console.log(MerchantId);
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    if(!MerchantId){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }

    const conn = await db();

    try{
        const cancelCancel = await conn.query(`CALL Cancel_Cancel_Next_Billing(?,?)`,[Number(MerchantId), userId])
        console.log(cancelCancel[0]);
        return res.status(200).json("취소 예약이 취소되었습니다.");
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
    finally{
        conn.release();
        return;
    }
}

//등록후 바로 결제 //마이페이지 결제
export const postFullPayInicis = async (req, res) => {
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
        console.log(productType,productId,customUserId,promotionCode);
    } else if (customOrderId.length === 4) {
        /*promotion Code 있음*/
        productType = customOrderId[0].slice(0, 1) === "M" ? 0 : 1; //연간 결제 = Y 월간 결제 = M
        productId = Number(customOrderId[0].slice(1, customOrderId[0].length));
        customUserId = Number(customOrderId[1]);
        promotionCode = Number(customOrderId[2]);
        console.log(productType,productId,customUserId,promotionCode);
    } else {
      return res.status(400).json({ message: "잘못된 값입니다." });
    }
   
    if(req.body.resultcode === "00"){
        const conn = await db();
        //빌링 성공
        console.log("success code : ",req.body.resultcode);
        try {
            req.body.resType = "Full"
            const successBillingKey = await setBillingKey(req);
            const CardId = successBillingKey[0][0].CardId;
            console.log("01. CALL SetBillingKey", CardId);
            try{
                const getBilling = await conn.query(`CALL Get_Billing_Key(?,?)`, [customUserId,CardId,]);
                console.log("02. Get Billing_Key", getBilling[0][0]);
                //fetch
                try{
                    // const moid = orderid;
                    const time = dayjs().format("YYYYMMDDhhmmss");
                    let ip = requestIp.getClientIp(req);
                    ip = ip.substring(7);
                    ip = "127.0.0.1"
                    const params = {
                        INIAPIKey: payConfig.INIAPIKey,
                        url: payConfig.HOME_URL,
                        type: payConfig.TYPE,
                        paymethod: "Card",
                        timestamp: time,
                        clientIp: ip,
                        orderid: orderid,
                        price: "1000",
                        mid: getBilling[0][0].MId, //값 바뀜 X
                        billkey: getBilling[0][0].BillKey, //값 바뀜 X
                        goodName: "test02",
                        buyerName: getBilling[0][0].UserName,
                        buyerEmail: getBilling[0][0].Username,
                        buyerTel: getBilling[0][0].UserContact,
                        authentification: "00",
                    };
                    console.log("!!!!!!!!!!!!!!!!!!!!!!!");
                    console.log("ORDER ID : ",params.orderid);
                    console.log("MID : ", params.mid);
                    console.log("IP : ",params.clientIp);
                    console.log("!!!!!!!!!!!!!!!!!!!!!!!");
                    const data = payConfig.INIAPIKey +params.type 
                    +params.paymethod +params.timestamp +params.clientIp +params.mid +params.orderid +params.price +params.billkey;
                    const hashData = crypto.createHash("sha512").update(data).digest("hex");

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
                            clientIp: ip,
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
                        },
                    });
                    console.log("04. 결제 요청 결과 : ",fetchRes.data);
                    req.body.tid = fetchRes.data.tid
                    if (fetchRes.data.resultCode === "00") {
                        try{
                            // console.log("성공시1",);
                            // console.log("RESULTCODE 00", fetchRes.data.resultCode);
                            // console.log("userID 타입",typeof(customUserId));
                            // console.log("promotion Code",promotionCode,typeof(promotionCode));
                            // console.log("DATE : ",(fetchRes.data.payDate + fetchRes.data.payTime));
                            // console.log(fetchRes.prtcCode);
                            // console.log(orderid);
                            // console.log();
                            // console.log("");
                            const savePay = await conn.query(
                                `CALL Set_Billing(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                                [
                                    customUserId,//userId
                                    params.buyerName,
                                    params.buyerTel,
                                    params.buyerEmail,
                                    CardId,
                                    fetchRes.data.resultCode,
                                    fetchRes.data.resultMsg,
                                    String(fetchRes.data.payDate + fetchRes.data.payTime),
                                    fetchRes.data.payAuthCode,
                                    fetchRes.data.tid,
                                    fetchRes.data.price,
                                    fetchRes.data.cardCode,
                                    fetchRes.data.cardQuota,
                                    fetchRes.data.checkFlg,
                                    fetchRes.data.prtcCode,
                                    orderid,
                                    typeof(productId) === "number" ? productId : Number(productId), //product ID, month, year
                                    productType, //type Month : 0 Year : 1
                                    promotionCode ? promotionCode : null,
                                ]
                                );
                            console.log("05. Success pay Set_Billing", savePay );
                            console.log("결제 성공!");
                            conn.release();
                            return res.redirect("https://youarethe.co.kr/mypage/pay?message=결제가 완료되었습니다.");
                        }
                        catch(saveErr){
                            if(handelSqlError(saveErr)){
                                console.log(saveErr.text);
                                if(revokePay(req, res)){
                                    conn.release();
                                    //parmas
                                    return res.redirect(`https://youarethe.co.kr/mypage/sub?message=결제가 취소되었습니다.${saveErr.text}`);
                                    // return res.status(400).json({
                                    //     message:
                                    //     `결제가 취소되었습니다.${saveErr.text}`
                                    // })
                                }
                                else{
                                    conn.release();
                                    return res.redirect(`https://youarethe.co.kr/mypage/sub?message=결제중 문제가 발생했습니다. 잠시후 다시 시도해주세요.${saveErr.text}`);
                                    // return res.status(400).json({message:`결제중 문제가 발생했습니다. 잠시후 다시 시도해주세요.${saveErr.text}`})
                                }
                            }else {
                                console.log(saveErr);
                                if(revokePay(req, res)){
                                    console.log("revokeIF");
                                    conn.release();
                                    return res.redirect("https://youarethe.co.kr/mypage/sub?message=결제가 취소되었습니다. 잠시후 다시 시도해주세요.");
                                    // return res.status(400).json({message:"결제가 취소되었습니다. 잠시후 다시 시도해주세요."})
                                }else{
                                    conn.release();
                                    return res.redirect("https://youarethe.co.kr/mypage/sub?message=결제중 문제가 발생했습니다. 잠시후 다시 시도해주세요.");
                                    // return res.status(400).json({message:"결제중 문제가 발생했습니다. 잠시후 다시 시도해주세요."})
                                }
                            }
                        }
                    }else{
                        console.log("결제 요청 실패", fetchRes.data.resultCode,fetchRes.data.resultMsg);
                        console.log("성공시",);
                            console.log("RESULTCODE 00", fetchRes.data.resultCode);
                            console.log("userID 타입",typeof(customUserId));
                            console.log("DATE : ",(fetchRes.data.payDate + fetchRes.data.payTime));
                            const savePay = await conn.query(
                                `CALL Set_Billing(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                                [
                                    customUserId,//userId
                                    params.buyerName,
                                    params.buyerTel,
                                    params.buyerEmail,
                                    CardId,
                                    fetchRes.data.resultCode,
                                    fetchRes.data.resultMsg,
                                    String(fetchRes.data.payDate + fetchRes.data.payTime),
                                    fetchRes.data.payAuthCode,
                                    fetchRes.data.tid,
                                    fetchRes.data.price,
                                    fetchRes.data.cardCode,
                                    fetchRes.data.cardQuota,
                                    fetchRes.data.checkFlg,
                                    fetchRes.data.prtcCode,
                                    orderid,
                                    typeof(productId) === "number" ? productId : Number(productId), //product ID, month, year
                                    productType, //type Month : 0 Year : 1
                                    promotionCode ? promotionCode : null,
                                ]
                                );
                            console.log("05. Success pay Set_Billing", savePay );
                            conn.release();
                            return res.redirect("https://youarethe.co.kr/mypage/sub?message=결제에 실패했습니다.");
                            // return res.status(400).json({message:"결제에 실패했습니다."})
                    }
                }catch(fetchErr){
                    console.log("fetchErr!!!! :", fetchErr);
                    conn.release();
                    return res.redirect("https://youarethe.co.kr/mypage/sub?message=결제에 실패했습니다.");
                }
            }
            //getBilling
            catch(getBillingErr){
                console.log("카드정보를 가져올 수 없습니다.", getBillingErr);
                conn.release();
                if (handelSqlError(getBillingErr)) {
                    return res.redirect(`https://youarethe.co.kr/mypage/sub?message=${getBillingErr.text}`);
                } else return res.redirect(`https://youarethe.co.kr/mypage/sub?message=카드 정보를 가져올 수 없습니다. 잠시후 다시 시도해주세요.`);
            }
        } catch(err) {
            console.log("err : regCard",err);
            return res.redirect(`https://youarethe.co.kr/mypage/sub?message=결제에 실패했습니다.`);
        }
    }else{
        if(req.body.resultcode){
            //카드 등록에서
            console.log("code : ",req.body.resultcode);
            // const failBilling = await setBillingKey(req);
            // return res.status(200).json({message:req.body.resultmsg})
            return res.redirect(`https://youarethe.co.kr/mypage/sub?message=결제에 실패했습니다.`);
        }else{
            //서버에러
            return res.redirect("https://youarethe.co.kr/mypage/sub?message=PG Server ERR : 카드 등록에 실패하였습니다.");
            // return res.status(400).json({message:"PG Server ERR : 카드 등록에 실패하였습니다."})
        }
    }
}

export const setBillingKey = async (req) => {
    console.log("SETBILLINGKEY");
    const {
        resultcode,resultmsg,cardcd,billkey,mid,tid,authkey,orderid,cardno,
        merchantreserved,p_noti,data1,cardkind,pgauthdate,pgauthtime,CheckFlag
    } = req.body;
    const customOrderId = orderid.split('-');
    const customUserId = customOrderId[1];
    const userId = req.session.user ? req.session.user.Id : false;

    const conn = await db();
    try{
        const setCard = await conn.query(
            `CALL Set_Billing_Key(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
            [
                userId ? userId : customUserId,
                resultcode,
                resultmsg,
                pgauthdate+pgauthtime,
                tid,
                mid,
                orderid,
                billkey,
                authkey,
                cardcd,
                cardno,
                cardkind,
                CheckFlag,
                data1,
                merchantreserved
            ]
        );
        conn.release();
        console.log("return setBIllingKey");
        return setCard;
    }catch(err){
        console.log("Set Billing Key function ERR",err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
        conn.release();
        return;
    }    
}

export const regCard = async (req, res) => {
    console.log("reg Card",req.body);
    req.body.resType = "half";
    if(req.body.resultcode === "00"){
        //빌링 성공
        console.log("success code? : ",req.body.resultcode);
        try {
            const successBilling = await setBillingKey(req);
            console.log("Success Billing", successBilling[0]);
            return res.status(200).json("카드가 등록되었습니다.")
        } catch(err) {
            console.log("err : regCard",err);
            return res.status(400).json({message:"잠시후 다시 시도해주세요."})
        }
    }else{    
        if(req.body.resultcode){
            //카드 등록에서
            console.log("code : ",req.body.resultcode);
            const failBilling = await setBillingKey(req);
            console.log("Failed Billing", failBilling[0]);
            return res.status(200).json({message:req.body.resultmsg})
        }else{
            //서버에러
            return res.status(400).json({message:"PG Server ERR : 카드 등록에 실패하였습니다."})
        }
    }
}

export const getProducts = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }

    const conn = await db();
    try{
        const products = await conn.query(`CALL Get_Products()`)
        res.status(200).json(products[0][0]);
    }
    catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }
    finally{
        conn.release();
        return;
    }
}

export const getCards = async(req, res) => {
    const userId = req.session.user ? req.session.user.Id : null;
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }

    const conn = await db();
    try{
        const cards = await conn.query(`CALL Get_Cards(?)`,[userId]);
        res.status(200).json(cards[0])
    }catch{
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

//회원가입 후 결제
export const registerPostInicis = async (req, res) => {
    console.log("reginicis");
    const { resultcode,resultmsg,cardcd,billkey,mid,tid,authkey,orderid,cardno,merchantreserved,data1,cardkind,pgauthdate,pgauthtime,CheckFlag, } = req.body;

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
        console.log(productType,productId,customUserId,promotionCode);
    } else if (customOrderId.length === 4) {
        /*promotion Code 있음*/
        productType = customOrderId[0].slice(0, 1) === "M" ? 0 : 1; //연간 결제 = Y 월간 결제 = M
        productId = Number(customOrderId[0].slice(1, customOrderId[0].length));
        customUserId = Number(customOrderId[1]);
        promotionCode = Number(customOrderId[2]);
        console.log(productType,productId,customUserId,promotionCode);
    } else {
      return res.status(400).json({ message: "잘못된 값입니다." });
    }

    const failedRedirectURL = "https://youarethe.co.kr/join/sub";
    const successRedirecURL = "https://youarethe.co.kr/join/com";

    if (resultcode === "00") {
        const conn = await db();
        if (conn) {
            try {
                const card = await conn.query(
                `CALL Set_Billing_Key(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                [  customUserId, resultcode, resultmsg, pgauthdate + pgauthtime, tid, mid, customUserId,billkey, authkey,cardcd,cardno,cardkind,CheckFlag,data1,merchantreserved, ]
                );
                const CardId = card[0][0].CardId;
                console.log("01. CALL SetBilling Key", card[0][0]);
                try {
                    const getBilling = await conn.query(`CALL Get_Billing_Key(?,?)`, [customUserId ,CardId,]);
                    console.log("02. Get Billing_Key",getBilling[0][0]);
                    try {
                        
                        const time = dayjs().format("YYYYMMDDhhmmss");
                        let ip = requestIp.getClientIp(req);
                        ip = ip.substring(7);
                        const params = {
                            INIAPIKey: payConfig.INIAPIKey,
                            url: payConfig.HOME_URL,
                            type: payConfig.TYPE,
                            paymethod: "Card",
                            timestamp: time,
                            clientIp: ip,
                            orderid: orderid,
                            price: "1000",
                            mid: getBilling[0][0].MId, //값 바뀜 X
                            billkey: getBilling[0][0].BillKey, //값 바뀜 X
                            goodName: "test02",
                            buyerName: getBilling[0][0].UserName,
                            buyerEmail: getBilling[0][0].Username,
                            buyerTel: getBilling[0][0].UserContact,
                            authentification: "00",
                        };
                        const data = payConfig.INIAPIKey +params.type +params.paymethod +params.timestamp 
                                +params.clientIp +params.mid +params.orderid +params.price +params.billkey;
                        const hashData = crypto.createHash("sha512").update(data).digest("hex");
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
                                clientIp: ip,
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
                            },
                        });
                        console.log("04. 결제 요청 결과 : ",fetchRes.data);
                        req.body.tid = fetchRes.data.tid
                        if (fetchRes.data.resultCode === "00") {
                            try {
                                const savePay = await conn.query(
                                `CALL Set_Billing(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                                [
                                    customUserId, //userId
                                    params.buyerName,
                                    params.buyerTel,
                                    params.buyerEmail,
                                    CardId,
                                    fetchRes.data.resultCode,
                                    fetchRes.data.resultMsg,
                                    String(fetchRes.data.payDate + fetchRes.data.payTime),
                                    fetchRes.data.payAuthCode,
                                    fetchRes.data.tid,
                                    fetchRes.data.price,
                                    fetchRes.data.cardCode,
                                    fetchRes.data.cardQuota,
                                    fetchRes.data.checkFlg,
                                    fetchRes.data.prtcCode,
                                    params.orderid,
                                    typeof(productId) === "number" ? productId : Number(productId), //product ID, month, year
                                    productType, //type Month : 0 Year : 1
                                    promotionCode ? promotionCode : null,
                                ]
                                );
                                console.log("05. Success pay Set_Billing", savePay );
                                conn.release();
                                console.log("결제 성공!");
                                return res.redirect("https://youarethe.co.kr/join/com");
                            } catch (saveErr) {
                                console.log(saveErr);
                                if(resultcode === "00"){
                                    //결제 실패 처리
                                    if(handelSqlError(saveErr)){
                                        if(revokePay(req, res)){
                                            conn.release();
                                            return res.status(400).json({
                                                message:
                                                `결제가 취소되었습니다.${saveErr.text}`
                                            })
                                        }
                                        else{
                                            conn.release();
                                            return res.status(400).json({message:`결제에 문제가 있습니다. 잠시후 다시 시도해주세요.${saveErr.text}`})
                                        }    
                                    }else {
                                        if(revokePay(req, res)){
                                            console.log("revokeIF");
                                            conn.release();
                                            return res.status(400).json({message:"결제가 취소되었습니다. 잠시후 다시 시도해주세요."})
                                        }else{
                                            conn.release();
                                            return res.status(400).json({message:"결제에 문제가 있습니다. 잠시후 다시 시도해주세요."})
                                        }
                                    }
                                }
                                conn.release();
                                if(handelSqlError(saveErr)){
                                    return res.status(400).json({message:saveErr.text});
                                }else return res.status(400).json({message:"잠시후 다시 시도해주세요."})
                                
                            }
                        } else {
                            console.log("결제 요청 실패", fetchRes.data.resultCode,fetchRes.data.resultMsg);
                            const savePay = await conn.query(
                              `CALL Set_Billing(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
                              [
                                customUserId, //userId
                                params.buyerName,
                                params.buyerTel,
                                params.buyerEmail,
                                CardId,
                                fetchRes.data.resultCode,
                                fetchRes.data.resultMsg,
                                String(
                                  fetchRes.data.payDate + fetchRes.data.payTime
                                ),
                                fetchRes.data.payAuthCode,
                                fetchRes.data.tid,
                                fetchRes.data.price,
                                fetchRes.data.cardCode,
                                fetchRes.data.cardQuota,
                                fetchRes.data.checkFlg,
                                fetchRes.data.prtcCode,
                                orderid,
                                typeof(productId) === "number" ? productId : Number(productId), //product ID, month, year
                                productType, //type Month : 0 Year : 1
                                promotionCode ? promotionCode : null,
                              ]
                            );
                            console.log("05. Success pay Set_Billing", savePay );
                            conn.release();
                            return res.status(400).json({message:"결제에 실패했습니다."})
                        }
                    } catch (fetchErr) {
                        console.log("fetchErr : 106", fetchErr);
                        conn.release();
                        return res.status(400).json({ message: "결제에 실패했습니다." });
                    }
                } catch (err) {
                console.log("err #0101!!!!!", err);
                conn.release();
                if (handelSqlError(err)) {
                    return res.status(400).json({ message: err.text });
                } else return res.status(400).json({ message: err.text });
                }
            } catch (err) {
                console.log(err);
                if (handelSqlError(err)) {
                res.status(400).json({ message: err.text });
                } else res.status(400).json({ message: "잠시후 다시 시도해주세요." });
                return;
            } finally {
                conn.release();
            }
        }
    }else{
        console.log("Billing Key발급 실패");
        if(resultmsg){
            console.log("Result MSG : ",resultmsg);    
        }else{
            console.log("이니시스 서버측에서 메세지를 받지 못했습니다.");
        }   

        //실패 리다이렉트
        return res.redirect("https://youarethe.co.kr/join/sub");
    }
    return;
};

//이미 구독중인 회원 결제 취소 / DB콜 없음
const revokePay = async (req, res) => {
    console.log("revokePay");
    console.log("revoke mid : ",req.body.mid);
    console.log("revoke tid : ",req.body.tid);
    const conn = await db();
    //취소 패치
    let ip = requestIp.getClientIp(req);
    const time = dayjs().format("YYYYMMDDhhmmss");
    ip = ip.substring(7);
    const dataSet = {
        key: payConfig.INIAPIKey,
        type: "Refund",
        paymethod: "Card",
        timestamp: time,
        clientIp: ip,
        mid: req.body.mid,
        tid: req.body.tid,
    };
    const data =
        dataSet.key +
        dataSet.type +
        dataSet.paymethod +
        dataSet.timestamp +
        dataSet.clientIp +
        dataSet.mid +
        dataSet.tid;
    const hashData = crypto
        .createHash("sha512")
        .update(data)
        .digest("hex");

    const cancel = await axios({
        url: payConfig.BILLING_REFUND,
        method: payConfig.METHOD,
        headers: {
        "Content-type": payConfig.ContentType,
        },
        params: {
        type: dataSet.type,
        paymethod: dataSet.paymethod,
        timestamp: dataSet.timestamp,
        clientIp: dataSet.clientIp,
        mid: dataSet.mid,
        tid: dataSet.tid,
        msg: dataSet.msg,
        hashData,
        },
    });
    if (cancel.data.resultCode === "00") {
        console.log("취소 성공", cancel.data);
        return true
    } else {
        console.log("취소 오류!!", cancel.data);
        return false;
    }

    // # CANCEL BILLING cancel Billing저장
};

//최근 결제 내역
export const breakdown = async (req, res) => {
    console.log("breakdown");
    const userId = req.session.user ? req.session.user.Id : null;
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const conn = await db();
    try{
        const breakdown = await conn.query(`CALL Get_Merchants(?)`,[userId])
        console.log("breakdown", breakdown[0]);
        res.status(200).json(breakdown[0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

//최근 결제 내역 디테일
export const breakdownDetail = async (req,res) => {
    console.log("breakdownDetail", req.query.merchantId);
    const userId = req.session.user ? req.session.user.Id : null;
    const merchantId = req.query.merchantId ? req.query.merchantId : null;
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    if(!merchantId){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }
    const conn = await db();
    try{
        const breakdown = await conn.query(`CALL Get_Merchant(?,?)`,[userId, Number(merchantId)])
        console.log("breakdown", breakdown[0][0]);
        res.status(200).json(breakdown[0][0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

export const getPromotions = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null;
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const conn = await db();
    try{
        const promotions = await conn.query(`CALL Get_Promotions(?)`,[userId])
        console.log("promotions", promotions[0]);
        res.status(200).json(promotions[0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

export const addPromotions = async (req, res) => {
    const PromotionCode = req.body.PromotionCode;
    const userId = req.session.user ? req.session.user.Id : null;
    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    console.log(PromotionCode.length);
    
    //19byte
    if(!PromotionCode.length === 19){
        return res.status(400).json({message:"프로모션 코드가 존재하지 않습니다."})
    }
    const conn = await db();
    try{
        const addPromotions = await conn.query(`CALL Add_Promotion(?,?)`,[userId, PromotionCode])
        console.log(addPromotions);
        res.status(200).json({message:"프로모션 코드가 등록되었습니다."});
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}
// export const removeBillingKey = async (req, res) => {
//     const {
//         CardId
//     } = req.body;
//     const userId = req.session.user ? req.session.user.Id : null;
//     if(!userId){
//         return res.status(400).json({message:"로그인이 필요합니다."});
//     }
//     if(!CardId){
//         return res.status(400).json({message:"잘못된 접근입니다."});
//     }

//     const conn = await db();
//     try{
//         const remove = await conn.query(`CALL Remove_Billing_Key(?,?)`,[userId, CardId])

//     }catch(err){
//         console.log("카드 삭제 에러",err);
//         if(handelSqlError(err)){
//             return res.status(400).json({message:err.text})
//         }else{
//             return res.status(400).json({message:"잠시후 다시 시도해주세요."})
//         }
//     }
// }