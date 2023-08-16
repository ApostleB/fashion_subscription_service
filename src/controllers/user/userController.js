/*
변수명
get은 camelCase사용하고
post는 camelCase+앞에 대문자
*/
import express from "express";
import { handelSqlError } from "../../libraries/handleSqlError";
import db from "../../db";
import axios from "axios";
import coolsms from "coolsms-node-sdk";
import smsConfig from "../../config/smsConfig.json"

export const testRegisterContact = async (req, res) => {
    console.log("sendRegister!!!!!!");

    //NCSLLBBUXVOMJNIY
    //5MYJU2KZRALQLQR6X1URB9FGJNRMPYBK
    const messageService = new coolsms(smsConfig.APIKEY, smsConfig.API_SECRET );

    messageService.sendMany([
        {
            to:"029777669",
            from:"01050991699",
            text:"한글 45자, 영자 90자 이하 입력되면 자동으로 SMS타입의 메시지가 발송됩니다."
        }
    ]).then(res => console.log(res))
    .catch(err => console.error(err));
    
    return res.status(200);
}

export const checkUsername = async (req, res) => {
    const {
        Username
    } = req.body;
    if(!Username) return res.status(400).json({message:"아이디를 입력해주세요."});
    const conn = await db();
    try{
        const check = await conn.query(`CALL Register_Check_Username(?)`, [Username]);
        res.status(200).json({message:"사용 가능한 아이디입니다."});
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message: "잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }     
}



export const sendRegisterContact = async (req, res) => {
    //Register_Check_Contact
    let {
        Contact
    } = req.body;
    console.log("sendRegisterContact");
    const regex = /[^0-9]/g;
    let result = Contact.replace(regex, "");
    console.log(Contact);
    const conn = await db();
    if (conn) {
        try{
            const check = await conn.query(`CALL Register_Check_Contact(?)`,[Contact]);
            console.log("sendRegisterContact : ", check[0][0]);

            const messageService = new coolsms(smsConfig.APIKEY, smsConfig.API_SECRET );
            
            messageService.sendOne({
                to:result,
                from: "029777669",
                text:`Youarethe 본인인증 문자메세지 ${check[0][0].Key}`
            }).then(success => {
                res.status(200).json({message:"메세지 발신에 성공했습니다."})
            }).catch(err => {
                console.log(err);
                res.status(400).json({message:"실패"});
            });
            
            console.log("문자메세지 발신 성공");
        }catch(err){
            console.log("sendRegisterContact ERR : ",err);
            console.log("======================================");
            console.log("======================================");
            console.log("======================================");
            console.log("======================================");
            console.log("======================================");
            console.log("======================================");
            if(err.sqlState){
                if(err.errno){
                    res.status(400).json({message:err.text});
                }
            }
            else res.status(400).json({message: "잠시후 다시 시도해주세요."})
        }finally{
            conn.release();
            return;
        }
    }
    res.status(400).json({message: "잠시후 다시 시도해주세요."})
}



export const registerVerify = async (req, res) => {
    console.log("registerVerify");
    const {
        Contact,
        VerifyKey,
    } = req.body;
    const Register = "Register";
    const conn = await db();
    if(conn){
        try{
            const smsVerify = await conn.query(`CALL Verify(?,?,?)`, [Contact, VerifyKey, Register]);
            conn.release();
            const Verify = {
                Key: VerifyKey,
                Id: smsVerify[0][0].Id,
            };
            res.status(200).json({ Verify })
        } catch(err){
            if(handelSqlError(err)){
                res.status(400).json({message:err.text});
            }
            else vres.status(400).json({message: "잠시후 다시 시도해주세요."})
        }finally{
            conn.release();
            return ;
        }
    }
}
export const userLogin = async (req, res) => {
    const {
        UserName,
        Password
    } = req.body

    if(!UserName || !Password){
        return res.status(400).json({ message:"항목을 모두 입력해주세요." });
    }
    const conn = await db();
    if(req.session.user){
        req.session.destroy();
    }
    if (conn) {
        try{
            const login = await conn.query(`CALL User_Login(?,?)`,[UserName, Password]); 
            const user = {
                Id:login[0][0].Id,
                PasswordChangeNeeded: login[0][0].PasswordChangeNeeded,
                NeedDelivery:login[0][0].NeedDelivery,
                IsSub:login[0][0].IsSub,
                ContentReviewNeedCount:login[0][0].ContentReviewNeedCount                
            }
            req.session.user = user;
            let expiryDate = new Date( Date.now() + 60 * 60 * 1000 * 24 * 1); // 24 hour 7일
            res.cookie("FL",true,{ expires:expiryDate, httpOnly:false, path:"/" });
            res.status(200).json(user);
        }catch(err){
            if(handelSqlError(err)){
                res.status(400).json({message: err.text});
            }
            else res.status(400).json({message: "잠시후 다시 시도해주세요."});
        }finally{
            conn.release();
            return;
        }
    }
    
    res.status(400).json({message: "잠시후 다시 시도해주세요."});
}
export const userLogout = (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message: "로그인을 해주세요"})
    }
    
    // req.session.destroy((err) => {
    //     if(err){
    //         console.log("로그아웃에러",err);
    //         return res.status(400).json("failed");
    //     }
    //     else{
    //         console.log("로그아웃중");
    //         res.clearCookie("FitboaAPI");
    //         res.clearCookie("FL");
    //         res.status(200);
    //         return;
    //     }
    // })
    console.log("로그아웃");
    req.session.destroy();
    res.clearCookie("FitboaAPI");
    res.clearCookie("FL");
    console.log("로그아웃 끝");
    return res.redirect("/");
}

export const getUserInfo = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    if(!req.session.user){
        return res.status(200).clearCookie("FL").json({message:"로그인이 필요합니다.",FL:false});
    }
    try{
        const info = await conn.query(`CALL Get_User_Info(?)`,[userId]);
        res.status(200).json(info[0][0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message: err.text});
        }
        else res.status(400).json({message: "잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

export const register = async (req, res) => {
    const {
        Name,
        UserName,
        Password,
        Contact,
        VerifyKey,
        // VerifyId,
        RoadAddress,    // 도로명 주소
        JibunAddress,   // 지번 주소
        ExtraAddress,   // 상세 주소
        PostCode,       // 우편 번호
        AddressType,    // 주소 선택 타입 0: 도로명, 1: 지번주소
        UseTerm,
        PrivateTerm,
        EmailTerm,
        SmsTerm,
    } = req.body;

    const VerifyId = req.body.VerifyId === "" ? null : req.body.VerifyId;

    //세션 체크    
    if(req.session.user){
        console.log("이미 로그인 되어있습니다.");
        console.log(req.session);
        return res.status(400).json({message:"이미 로그인 되어있습니다."})
    }
    //입력값 검사
    if(!UseTerm || !PrivateTerm || !EmailTerm || !SmsTerm){ 
        return res.status(400).json({message: "모두 동의 해야합니다."});
    }
    if(!Name || !UserName || !Password || !Contact ) {
        return res.status(400).json({message: "항목을 모두 입력해주세요."});
    }
    if(AddressType === "도로명"){
        if(!RoadAddress, !PostCode || PostCode.length > 5 || isNaN(PostCode) === true){
            return res.status(400).json({message:"도로명 주소를 다시 확인해주세요."});
        }
    }else if(AddressType === "지번"){
        if(!JibunAddress, !PostCode || PostCode.length > 5 || isNaN(PostCode) === true){
            return res.status(400).json({message:"지번 주소를 다시 확인해주세요."})
        }
    }else{
        return res.status(400).json({message:`주소 선택 타입을 확인해주세요. ${AddressType}`});
    }
    if(VerifyId === null){
        return res.status(400).json({message:"인증확인을 해주세요."});
    }

    
    const conn = await db();
    try{
        const list = [Name,UserName,Password,Contact,VerifyKey,VerifyId,RoadAddress,JibunAddress,ExtraAddress,PostCode,AddressType,UseTerm,PrivateTerm,EmailTerm,SmsTerm];
        const register = await conn.query(
            `CALL Register(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
            [Name,UserName,Password,Contact,VerifyKey,VerifyId,RoadAddress,JibunAddress,ExtraAddress,PostCode,AddressType,UseTerm,PrivateTerm,EmailTerm,SmsTerm]
        );
        let user;
        if(register[0][0].LoginResult === 1){
            let user = {
                Id:register[0][0].Id,
                PasswordChangeNeeded:0,
                NeedDelivery:1,
                IsSub:0
            }
            req.session.user = user;
        }

        let expiryDate = new Date( Date.now() + 60 * 60 * 1000 * 24 * 1); // 24 hour 7일
        res.cookie("FL",true,{ expires:expiryDate, httpOnly:false, path:"/", maxAge:null})
        res.status(200).json(user);
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message: err.text});
        }
        else {
            res.status(400).json({message: ""});
        }
    }finally{
        conn.release();
        return;
    }
}
//구독
export const subscription = async (req, res) => {
    
    if(!req.session.user){
        return res.status(400).json({message: "로그인이 필요합니다."});
    }
    if(req.session.user.IsSub === 1){
        return res.status(400).json({message: "이미 구독 중입니다."});
    }
    const UserId = Number(req.session.user.Id);
    const conn = await db();
    if (conn) {
        try{
            const sub = await conn.query(`CALL Subscribe(?)`,[UserId]);
            req.session.user.IsSub = 1;
            res.status(200).json(sub);
        } catch(err){
            if(handelSqlError(err)){
                res.status(400).json({message:err.text});
            }
            else res.status(400).json({message:"잠시후 다시 시도해주세요."});
        } finally{
            conn.release();
            return;
        }
    }
    
    res.status(400).json({message:"잠시후 다시 시도해주세요."});
}
export const userNameVerify = async (req, res) => {
    let {Name, Contact} = req.query;
    let regex = /[^0-9]/g;
    let result = null;
    if(!Contact || Contact.length > 13){
        Contact = null;
    }else{
        result = Contact.replace(regex, "");
    }
    const conn = await db();
    if (conn) {
        try{
            const check = await conn.query(`CALL FindUsername_Check_Contact(?,?)`,[Name, Contact]);
            console.log("아이디 찾기 문자 발송", check[0][0].Key);

            const messageService = new coolsms(smsConfig.APIKEY,smsConfig.API_SECRET);

            console.log(Contact);
            messageService
              .sendOne({
                to: result,
                from: "029777669",
                text: `Youarethe 본인인증 문자메세지 ${check[0][0].Key}`,
              })
              .then((success) => {
                res.status(200).json({ message: "메세지 발신에 성공했습니다." });
              })
              .catch((err) => {
                console.log(err);
                res.status(400).json({ message: "실패" });
              });
              console.log("아이디 찾기 문자메세지 발신 성공");
        }catch(err){
            console.log(err);
            if(handelSqlError(err)){
                res.status(400).json({message:err.text});
            }
            else res.status(400).json({ message:"잠시후 다시 시도해주세요."});
        }finally{
            conn.release();
            return;
        }
    }
    
    res.status(400).json({ message:"잠시후 다시 시도해주세요."});
}

export const findUserName = async (req, res) => {
    const {
        Name,
        Contact,
        VerifyKey
    } = req.body;
    console.log("!!!!!!!!!!!!");

    const conn = await db();
    if (conn) {
        try{
            const find = await conn.query(`CALL Find_Username(?,?,?)`,[Name,Contact,VerifyKey]);
            console.log(find);
            res.status(200).json({ find: find[0][0]});
        }catch(err){
            if(handelSqlError(err)){
                res.status(400).json({message:err.text});
            }
            else res.status(400).json({ message:"잠시후 다시 시도해주세요."});
        }finally{
            conn.release();
            return;
        }
    }
}

export const findPasswordUsernameCheck = async (req, res) => {
    const { userName } = req.query

    const conn = await db();
    try{
        const checkUsername = await conn.query(`CALL FindPassword_Check_Username(?)`,[userName]);
        console.log("check",checkUsername);
        console.log("정상");
        res.status(200).json("success");
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

export const findPasswordCheckContact = async (req, res) => {
    let { UserName, Name, Contact } = req.query;
    let regex = /[^0-9]/g;
    let result = null;
    if(!Contact || Contact.length > 13){
        Contact = null;
    }else{
        result = Contact.replace(regex, "");
    }

    const conn = await db();
    try{
        const check = await conn.query(`CALL FindPassword_Check_Contact(?,?,?)`,[UserName, Name, Contact]);
        console.log(check[0][0].Key);

        const messageService = new coolsms(
          smsConfig.APIKEY,
          smsConfig.API_SECRET
        );
        if(check[0][0]){
            messageService
            .sendOne({
                to: result,
                from: "029777669",
                text: `Youarethe 비밀번호 찾기 문자메세지 ${check[0][0].Key}`,
            })
            .then((success) => {
                res.status(200).json({ message: "메세지 발신에 성공했습니다." });
            })
            .catch((err) => {
                console.log(err);
                res.status(400).json({ message: "실패" });
            });

            console.log("문자메세지 발신 성공");
        }else{
            return res.status(400).json({message:"메세지 발송해 실패했습니다."})
        }
    }catch(err){
        if(handelSqlError(err)){
            return res.status(400).json({message:err.text});
        }
        else return res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const findPassword = async (req, res) => {
    const { UserName, Name, Contact, VerifyKey } = req.body

    const conn = await db();
    try{
        const find = await conn.query(`CALL Find_Password(?,?,?,?)`,[UserName, Name, Contact, VerifyKey]);
        console.log(find);
        req.session.VerifyId = find[0][0].VerifyId;
        console.log(req.session);

        res.status(200).json("success");
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

export const findChangePassword = async (req, res) => {
    console.log(req.session.VerifyId);
    const VerifyId = req.session.VerifyId;
    const { NewPassword } = req.body;
    console.log(req.session.VerifyId);

    const conn = await db();
    try{
        const change = await conn.query(`CALL Change_Password(?,?)`,[VerifyId, NewPassword]);
        console.log(change);
        res.status(200).json({message:"비밀번호가 변경되었습니다."});
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

// export const passwordVerify = async (req, res) => {
//     const {Contact} = req.body;

//     if(!Contact || Contact.length !== 13){
//         return res.status(200).json({ message:"올바른 휴대폰 번호를 입력해주세요." })
//     }
//     const conn = await db();
//     if (conn) {
//         try{
//             const verify = await conn.query(`CALL FindPassword_Check_Contact(?)`, [Contact]);
            
//             res.session.verifyKey = '';            
            
//             res.status(200).json(verify[0][0]);
//         }catch(err){
//             if(handelSqlError(err)){
//                 res.status(400).json({message:err.text});
//             }
//             else res.status(400).json({message: "잠시후 다시 시도해주세요."});
//         }finally{
//             conn.release();
//             return;
//         }
//     }
// }

// export const sendRegisterContact = async (req, res) => {
//     console.log("sendRegister!!!!!!");
//     //Register_Check_Contact
//     const {
//         Contact
//     } = req.body;
//     const conn = await db();
//     if (conn) {
//         try{
//             const check = await conn.query(`CALL Register_Check_Contact(?)`,[Contact])
//             console.log("sendRegisterContact : ", check[0][0]);
//             res.status(200).json({"VerifyKey":check[0][0].Key})
//         }catch(err){
//             console.log("sendRegisterContact ERR : ",err);
//             console.log("======================================");
//             console.log("======================================");
//             console.log("======================================");
//             console.log("======================================");
//             console.log("======================================");
//             console.log("======================================");
//             if(err.sqlState){
//                 if(err.errno){
//                     res.status(400).json({message:err.text});
//                 }
//             }
//             else res.status(400).json({message: "잠시후 다시 시도해주세요."})
//         }finally{
//             conn.release();
//             return;
//         }
//     }
//     res.status(400).json({message: "잠시후 다시 시도해주세요."})
// }
