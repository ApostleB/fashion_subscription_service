import db from "../../db";
import path from "path";
import fs from "fs";
import { handelSqlError } from "../../libraries/handleSqlError";
import { fstat } from "fs";
import coolsms from "coolsms-node-sdk";
import smsConfig from "../../config/smsConfig.json"


//최근 결제내역
// export const payment = async (req, res) => {
//     if(!req.session.user){
//         return res.status(400).json({message:"로그인이 필요합니다."})
//     }
//     const payment = {
//         "결제명": "Fitboa 정기구독권",
//         "결제금액": "27,000",
//         "주문일" : "2020-06-11",
//         "결제완료": "결제완료",
//         "결제코드": "DFJR255647",
//     }

//     const conn = await db();
//     try{
//         // const payment = await conn.query(`CALL payment(?)`,[]);
//         // res.status(200).json(payment)
//         res.status(200).json(payment);
//     }catch(err){
//         if(handelSqlError(err)){
//             res.status(400).json({message:err.text})
//         }
//         else res.status(400).json({message: "잠시후 다시 시도해주세요."})
//     }finally{
//         conn.release();
//         return;
//     }
// }

// export const paymentDetail = async (req, res) => {
//     if(!req.session.user){
//         return res.status(400).json({message:"로그인이 필요합니다."})
//     }
//     const paymentNumber = req.query.paymentNumber ? req.query.paymentNumber : null;

//     const payInfo = {
//         "결제명":"Fitboa정기 구독권",
//         "주문자 정보":{
//             "이름":"홍길동",
//             "휴대폰 번호": "010-1234-5678"
//         },
//         "결제 정보":{
//             "결제 금액":"50,000",
//             "총 할인금액":"-5,000",
//             "최종 결제 금액":"45,000",
//         },
//         "취소 사유":{
//             "Number":1,
//             "Other": "기상청은 낮에는 봄처럼 온화한 날씨가 예상되나 구름이 많고 날씨가 예상되나 구름이 많고 날씨가",
//         },

//     };
//     const conn = await db();
//     try{
//         // const paymentDetail = await conn.query(`CALL paymentDetail(?)`,[t]);
//         // res.status(200).json(paymentDetail);
//         res.status(200).json(payInfo);

//     }catch(err){
//         if(handelSqlError(err)){
//             res.status(400).json({message:err.text});
//         }
//         else res.status(400).json({message:"잠시후 다시 시도해주세요."});
//     }finally{
//         conn.release();
//         return;
//     }
// }

// export const editAuth = async (req, res) => {
//     if(!req.session.user){
//         return res.status(400).json({message:"로그인이 필요합니다."})
//     }
//     const UserId = req.session.user ? req.session.user.Id : null;
//     const Password = req.body.Password ?? null;

//     const conn = await db();
//     try{
//         const auth = await conn.query(`CALL User_Login(?,?)`,[UserId, Password]); 
//         res.status(200).json("success");
//         // req.session.editAuth = true;
//     }catch(err){
//         if(handelSqlError(err)){
//             res.status(400).json({message:err.text});
//         }
//         else res.status(400).json({message:"잠시후 다시 시도해주세요."});
//     }finally{
//         conn.release();
//         return;
//     }
// }

// export const editUser = async (req, res) => {
//     if(!req.session.user){
//         return res.status(400).json({message:"로그인이 필요합니다."})
//     const {
//         Password, NextPassword, Contact, Address, EmailTerm, SMSTerm
//     } = req.body
//     const UserId = req.session.user ? req.session.user.Id : null;

//     const conn = await db();

//     try{
//         //const edit = conn.query(`CALL editUser(?,?,?,?,?,?)`,[Password, NextPassword, Contact, Address, EmailTerm, SMSTerm])
//         res.status(200).json("success");
//         req.session.user.editAuth ? req.session.user.editAuth = false : req.session.user.editAuth ;
//     }catch(err){
//         if(handelSqlError(err)){
//             res.status(400).json({message:err.text});
//         }
//         else res.status(400).json({message:"잠시후 다시 시도해주세요."});
//     }finally{
//         conn.release();
//         return;
//     }
// }

export const withdrawal = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const {
        Content, LongContent, Password
    } = req.body;
    console.log(Content, LongContent, Password);

    // if(!Content){
    //     return res.status(400).json({message:"항목을 모두 입력해주세요."});
    // }    
    if(!Password){
        return res.status(400).json({message:"패스워드를 입력해주세요."});
    }

    const conn = await db();
    try{
        const drawal = await conn.query(`CALL User_Secession(?,?,?,?)`,[userId, Content, LongContent , Password])
        console.log(drawal);
        // console.log("회원 탈퇴 완료 : ",drawal);
        req.session.destroy();
        res.clearCookie("FitboaAPI");
        res.clearCookie("FL");
        res.status(200).json({message:"회원탈퇴가 완료되었습니다."});
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

export const getStylingReviews = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }

    const userId = req.session.user ? req.session.user.Id : null;

    const conn = await db();
    try{
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}
export const getMyReviews = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요한 서비스입니다."});
    }
    const page = isNaN(req.query.page) === false ? req.query.page : 1;
    const userId = req.session.user.Id
    const conn = await db();
    try{
        const reviews = await conn.query(`CALL Get_Reviews(?,?,?)`,[userId, typeof(page) === "number" ? page : Number(page), true])
        delete reviews[1].meta;
        let myDatas = [];
        const reviewData = reviews[1];
        
        console.log(reviews);

        for(let i = 0; i < reviewData.length ; i++){
            let state = true;
            let tempData = {};
            tempData = reviewData[i];
            tempData.Images = [reviewData[i].Image];
            delete tempData.Image
            for(let j = 0 ;j< myDatas.length; j++){
                if(myDatas[j].ReviewId === tempData.ReviewId){
                    myDatas[j].Images.push(tempData.Images[0]);
                    state = false;
                    break;
                }
            }
            if(state){
                myDatas.push(tempData);
            }
        }
        myDatas.forEach(data=> {
            if(data.Images[0] === null){
                data.Images = [];
            }
        })
        
        res.status(200).json({"contents":myDatas, "itemCount":reviews[0][0]});
        //이미지 작업
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const postStylingReview = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }

    const userId = req.session.user ? req.session.user.Id : null;
    const {
        Star, Content
    } = req.body;
    const conn = await db();
    try{
        // const review = conn.query(`CALL Post_Review(?,?)`,[Star, Content]);
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}

export const getBookmarks = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }

    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        const bookmark = await conn.query(`CALL Get_Bookmarks(?)`,[userId]);
        delete bookmark[0].meta;
        const data = bookmark[0];
        
        const groupBy = (items, key) => Object.values(items.reduce(
            (result, item) => ({
                ...result,
                    [item[key]]: [
                        ...(result[item[key]] || []),
                        item,
                ],
            }),
            {},
        ));
        const sortBookmark = groupBy(data, 'Date');
        console.log();
        res.status(200).json(sortBookmark)
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}

async function cleanFile(file) {
    fs.unlink(file, (err) => {
        if(err){
            console.log("ERROR : ",err);
        }
    })
}

export const deleteReview = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }
    const UserId = req.session.user ? req.session.user.Id : null;
    const ReviewId = req.body.ReviewId ?? null

    console.log("asdsad", ReviewId);
    if(ReviewId === null){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
    
    const conn = await db();
    try{
        const review = await conn.query(`CALL Delete_Review(?,?)`,[UserId, ReviewId]);
        delete review[0].meta;
        const data = review[0];
        console.log("Length : ", data.length);
        for(let i = 0 ; i < data.length ; i ++){
            // console.l÷og(data[i])
            if(data[i].FileName){
                let fileDir = path.join(__dirname, `../../../userUploads/review/${data[i].FileName}`);
                try{
                    await cleanFile(fileDir);
                    console.log("success FILENAME : ",fileDir,"||", data[i].FileName);
                }catch(fileErr){
                    console.log("FileError :", fileErr);
                }
            }                
            console.log("===========================");
        }
        //fs 파일 직접삭제
        //스케쥴러 사용?
        res.status(200).json("리뷰가 삭제되었습니다.")
    }catch(err){
        console.log(err)
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const getQna = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }

    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        // const qnas = conn.query(`CALL bookmark(?)`,[userId]);
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}
export const postQna = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }
    const {
        type,
        Title,
        Content
    } = req.body;

    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        // const qna = conn.query(`CALL Post_Qna(?,?,?,?)`,[UserId, Type, Title, Content]);
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}

export const faq = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        // const qna = conn.query(`CALL Get_Faq`);
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}

export const notice = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});   
    }
    const conn = await db();
    try{
        // const notice = conn.query(`CALL Get_Notice`);
        res.status(200).json("success")
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
    }finally{
        conn.release();
        return;
    }
}

export const getScrap = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const userId = req.session.user ? req.session.user.Id : null;
}

// export const changePassword = async (req, res) => {
//     const {
//         OldPassword,
//         NewPassword1,
//         NewPassword2
//     } = req.body

//     if( NewPassword1 !== NewPassword2){
//         res.status(400).json({message:"비밀번호가 일치하지 않습니다."});
//     }
//     const conn = await db();
//     try{
//         // const passwordConfirm = await conn.query(`CALL ()`,[OldPassword]);
//     }catch(err){
//         if(handelSqlError(err)){
//             res.status(400).json({message:err.text});
//         }
//         else res.status(400).json({message:"잠시후 다시 시도해주세요."});
//     }
//     finally{
//         conn.release();
//         return;
//     }    
// }

//마이페이지 정보수정 접근 전 사용자 인증
export const userLoginOnce = async (req, res) => {
    const { Password } = req.body;

    const userId = req.session.user ? req.session.user.Id : null
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
     
    console.log(req.session.loginOnce);

    const conn = await db();
    try{
        // const loginOnce = await conn.query(`CALL User_Login_Once(?,?)`,[2, ]);
        const loginOnce = await conn.query(`CALL User_Login_Once(?,?)`,[userId, Password]);
        // res.session.onceUser
        // 임의로 구별할 세션 넣기
        console.log(loginOnce);
        req.session.loginOnce = true;
        res.status(200).json("success");
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message: err.text});
        }
        else res.status(400).json({message: "잠시후 다시 시도해주세요."});
    }
}

export const userPasswordChange = async (req, res) => {
    const { OldPassword, NewPassword} = req.body;
    console.log("LoginOnce?",req.session.loginOnce);

    const userId = req.session.user ? req.session.user.Id : null;
    if(req.session.loginOnce !== true){
        return res.status(400).json({message:"인증이 필요합니다."});
    }

    if(!userId){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }

    const conn = await db();
    try{
        const change = await conn.query(`CALL User_Password_Change(?,?,?)`,[userId, OldPassword, NewPassword]);
        console.log(change);
        return res.status(200).json({message:"비밀번호가 변경되었습니다."})

    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const userChangeContactCheck = async (req, res) => {
    let { Contact } = req.body

    const userId = req.session.user ? req.session.user.Id : null;
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    if(req.session.loginOnce !== true){
        return res.status(400).json({message:"인증이 필요합니다."});
    }
    let regex = /[^0-9]/g;
    let result = null;
    if(!Contact || Contact.length > 13){
        Contact = null;
    }else{
        result = Contact.replace(regex, "");
    }

    console.log("loginOnce",req.session.loginOnce);

    const conn = await db();
    try{
        const check = await conn.query(`CALL User_Change_Contact_Check(?,?)`,[userId, Contact]);
        console.log("check",check);

        //sms
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
                res.status(400).json({ message: "메세지 발신에 실패했습니다." });
              });
              console.log("마이페이지 휴대폰 번호 변경 문자메세지 발신 성공");
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const userChangeContactComfirm = async (req, res) => {
    const { VerifyKey, Contact } = req.body;

    const userId = req.session.user ? req.session.user.Id : null;
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    if(req.session.loginOnce !== true){
        return res.status(400).json({message:"인증이 필요합니다."});
    }
    console.log(req.session.loginOnce);

    const conn = await db();
    try{
        const confirm = await conn.query(`CALL User_Change_Contact_Confirm(?,?,?)`,[userId, Contact, VerifyKey]);
        console.log("confirm",confirm[0][0].VerifyId);
        req.session.VerifyId = confirm[0][0].VerifyId
        console.log("VerifyId 확인 : ",req.session.VerifyId);
        res.status(200).json("success");
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const userChangeContact = async (req, res) => {
    const { Contact } = req.body;
    console.log("VerifyId 확인2 : ",req.session.VerifyId);
    console.log(req.session.user.Id);
    const userId = req.session.user ? req.session.user.Id : null;
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    if(req.session.loginOnce !== true){
        return res.status(400).json({message:"인증이 필요합니다."});
    }
    let verifyId = req.session.VerifyId ? req.session.VerifyId : null;

    if(verifyId === null){
        return res.status(400).json({message:"인증 확인을 해주세요."})
    }

    const conn = await db();
    try{
        const change = await conn.query(`CALL User_Change_Contact(?,?,?)`,[userId, Contact, verifyId]);
        console.log("confirm",change);
        delete req.session.VerifyId;
        console.log("VerifyId 삭제");
        res.status(200).json({message:"연락처가 변경되었습니다."});
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}


export const userChangeInfo = async (req, res) => {
    const { RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, EmailTerm, SMSTerm } = req.body;
    
    const userId = req.session.user ? req.session.user.Id : null;
    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    if(req.session.loginOnce !== true){
        return res.status(400).json({message:"인증이 필요합니다."});
    }
    const conn = await db();
    try{
        const change = await conn.query(`CALL User_Info_Change(?,?,?,?,?,?,?,?)`,[userId, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType, EmailTerm, SMSTerm]);
        
        console.log("confirm",change);
        res.status(200).json({message:"회원정보가 수정되었습니다."});
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const getMyPageUserInfo = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null
    console.log("마이페이지 인포 세션 확인", req.session.loginOnce);

    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    if(!req.session.loginOnce){
        return res.status(400).json({message:"인증이 필요합니다."})
    }
    
    const conn = await db();
    try{
        const info = await conn.query(`CALL Get_User_Mypage_Info(?)`,[userId]);
        console.log("info",info);
        res.status(200).json(info[0][0]);
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }    
}


export const unsubscribeInfo = async (req, res) => {
    const userId = req.session.user ? req.session.user.Id : null

    if(userId === null){
        return res.status(400).json({message:"로그인이 필요합니다."})
    }
    
    const conn = await db();
    try{
        const info = await conn.query(`CALL Get_My_Sub_Info(?)`,[2]);
        console.log("info",info);
        res.status(200).json(info[0][0]);
    }catch(err){
        console.log(err.text);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}
