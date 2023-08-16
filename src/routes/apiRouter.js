import express from "express";

//UserController
import { findPasswordUsernameCheck,findPassword,findChangePassword,findPasswordCheckContact,checkUsername,register,userLogin,userLogout,sendRegisterContact,registerVerify,findUserName,userNameVerify,passwordVerify,subscription,getUserInfo,} from "../controllers/user/userController";
//APIController
import { addDeliver, setBodyType, uploadForm, uploadImage, csHome, selectBodyType,getUserRequest, noticeDetail, userPostRequest } from "../controllers/user/apiController";
//ContentController
import { getMainContent, getContent, getContents, getContentReview, getNextContent, getPopularContent, postContentReview, contentImagePermissionCheck, checkCanCustom, highViewContent, addBookmark, getBookmark, setSMSAgree, setEmailAgree, getSettings} from "../controllers/user/contentController";
//StyleGuideController
import { styleGuideContents, styleGuideContent,nextStyleGuideContent, styleImagePermissionCheck } from "../controllers/user/styleGuideController"
//MyPageController
import { unsubscribeInfo, getMyPageUserInfo, userChangeInfo, userLoginOnce, userPasswordChange, userChangeContactCheck, userChangeContactComfirm, userChangeContact, changeContactVerify, changeContactConfirm, changePassword, getScrap, payment, paymentDetail, editAuth, editUser, withdrawal, myCards, registerCard, deleteCard, getStylingReviews, getStylingReviewDetail, postStylingReview, getBookmarks, deleteReview, getMyReviews } from "../controllers/user/myPageController"
import { userFormUploads, pernsalStylingReview, sessionMiddleware, isLogin } from "../middlewares";
const apiRouter = express.Router();

apiRouter.use(sessionMiddleware);

import coolsms from "coolsms-node-sdk";
import smsConfig from "../config/smsConfig.json"

//알림톡 가이드
//https://docs.coolsms.co.kr/api-reference/messages/sendsimplemessage#ata
apiRouter.get("/kakao", (req, res, next) =>{
    const messageService = new coolsms(smsConfig.APIKEY,smsConfig.API_SECRET);
            
            messageService
              .sendOne({
                to: "01050991699",
                from: "029777669",
                type: "ATA",
                "kakaoOptions": {
                    "pfId": "KA01PF220509124323379ikVfspjr72E",
                    "templateId": "KA01TP2205121024090365LmDIgtE6Lf",
                },
                text: `Youarethe 카카오 알림톡 테스트`,
              })
              .then((success) => {
                res.status(200).json({ message: "알림톡 발신에 성공했습니다." });
              })
              .catch((err) => {
                console.log(err);
                res.status(400).json({ message: "알림톡 발신에 실패했습니다." });
              });
    return;
})
import crypto from "crypto";
//암호화 테스트
apiRouter.get("/crypto", (req, res) => {
    const passowrd = "Hello World!";
    const key = crypto.scryptSync("MyEncodedKey", password, 5 );
    const iv = crypto.randomBytes(16);

    // const cipher = crypto.createCipheriv
    // const key = crypto.scryptSync('wolfootjaIsSpecial','specialSalt', 32); // 나만의 암호화키. password, salt, byte 순인데 password와 salt는 본인이 원하는 문구로~ 
})

//home
apiRouter.get("/check/custom", checkCanCustom);
apiRouter.get("/home/contents",getMainContent);
//User
apiRouter.post("/user/check/username",checkUsername);
apiRouter.post("/user/check/contact", sendRegisterContact);
apiRouter.post("/user/verify/register", registerVerify);

apiRouter.get("/user/verify/username", userNameVerify);
apiRouter.post("/user/find/username", findUserName);

apiRouter.get("/user/find/password/check", findPasswordUsernameCheck)
apiRouter.get("/user/verify/password", findPasswordCheckContact);
apiRouter.post("/user/find/newpassword", findPassword)
apiRouter.post("/user/find/change/password", findChangePassword);

// apiRouter.post("/user/verify/password", passwordVerify);
apiRouter.post("/user/login", userLogin);
apiRouter.get("/user/getinfo", getUserInfo);
apiRouter.post("/user/logout", userLogout);
apiRouter.post("/user/register", register);
apiRouter.post("/user/subscription", subscription);

//Story
apiRouter.get("/story/content/highviewcontent",highViewContent)
apiRouter.get("/story/content",getContent)
apiRouter.get("/story/contents",getContents)
apiRouter.get("/story/content/next",getNextContent);
apiRouter.get("/story/content/popular",getPopularContent);
apiRouter.route("/story/content/review").get(getContentReview).post(postContentReview);
apiRouter.get("/story/content/image/:imageName",contentImagePermissionCheck);
apiRouter.post("/story/add/bookmark", addBookmark)
apiRouter.get("/story/bookmark", getBookmark)

//Set
apiRouter.post("/set/bodytype" ,setBodyType);
apiRouter.post("/set/selectbody" ,selectBodyType);
apiRouter.post("/set/bodytype/deliver" ,addDeliver);
apiRouter.post("/set/smsagree", setSMSAgree);
apiRouter.post("/set/emailagree" ,setEmailAgree);
apiRouter.get("/set/getsettings" ,getSettings);

//style
apiRouter.get("/style/styleguide/contents", styleGuideContents);
apiRouter.get("/style/styleguide/content", styleGuideContent);
apiRouter.get("/style/styleguide/highviewcontent", styleGuideContent);
apiRouter.get("/style/styleguide/next", nextStyleGuideContent);
apiRouter.get("/style/styleguide/image/:imageName",styleImagePermissionCheck);
apiRouter.route("/style/styleguide/review").get(getContentReview).post(postContentReview);

//1:1 Styling
import { applyForm, getPersnalStylingReview, postPersnalStylingReview, pernsalReviewImageCheck, detailReview } from "../controllers/user/persnalStyling";


apiRouter.post("/persnal/form",userFormUploads.array("files"), (err, req, res, next) => {
    if(err.code === 'LIMIT_FILE_SIZE'){
        console.log("MAX FILE SIZE");
        return res.status(400).json({message:"파일이 너무 큽니다."})
    }else if(err.code === 'LIMIT_FILE_COUNT'){
        console.log("LIMIT_FILE_COUNT");
        return res.status(400).json({message:"파일이 너무 많습니다."})
    }
    else{
        next();
    }
},applyForm)
apiRouter.route("/persnal/review").get(getPersnalStylingReview).post(pernsalStylingReview.array("files"), (err, req, res, next) => {
    if(err.code === 'LIMIT_FILE_SIZE'){
        console.log("MAX FILE SIZE");
        return res.status(400).json({message:"파일이 너무 큽니다."})
    }else if(err.code === 'LIMIT_FILE_COUNT'){
        console.log("LIMIT_FILE_COUNT");
        return res.status(400).json({message:"파일이 너무 많습니다."})
    }
    else{
        next();
    }
}, postPersnalStylingReview);
apiRouter.get("/persnal/review/image/:imageName",pernsalReviewImageCheck);
apiRouter.get("/persnal/review/detail", detailReview)



//////////////////////////////////////////////////////////////////////////////////
//My Page

//My Page_결제관련
// apiRouter.get("/mypage/payment", payment);
// apiRouter.get("/mypage/payment/detail", paymentDetail);
apiRouter.post("/mypage/payment/set/bodytype" ,setBodyType);   //api Controller 공유
// apiRouter.get("/mypage/payment/mycards", myCards);
// apiRouter.post("/mypage/payment/register", registerCard);
// apiRouter.get("/mypage/payment/delete", deleteCard);

//My Page_유저
// apiRouter.post("/mypage/edit/auth", editAuth);
// apiRouter.post("/mypage/edit/user", editUser);
apiRouter.get("/mypage/styling", getStylingReviews);
apiRouter.get("/mypage/styling/detail");
apiRouter.post("/mypage/styling/review", postStylingReview);

apiRouter.get("/mypage/scrap", getScrap);
apiRouter.get("/mypage/bookmarks", getBookmarks);
apiRouter.get("/mypage/review", getMyReviews);
apiRouter.post("/mypage/delete/review", deleteReview);

//구독 해지 예약 결제 정보
apiRouter.get("/mypage/unsub/info", unsubscribeInfo)

//마이페이지 정보 수정
apiRouter.get("/mypage/info/get",getMyPageUserInfo)
apiRouter.post("/mypage/change/login/once", userLoginOnce)
apiRouter.post("/mypage/change/password", userPasswordChange)
apiRouter.post("/mypage/change/contact/check", userChangeContactCheck)
apiRouter.post("/mypage/change/contact/confirm", userChangeContactComfirm)
apiRouter.post("/mypage/change/contact", userChangeContact)
apiRouter.post("/mypage/change/info", userChangeInfo)

apiRouter.post("/mypage/withdrawal", withdrawal);//회원 탈퇴
//////////////////////////////////////////////////////////////
//고객센터
apiRouter.get("/cs", csHome)
apiRouter.get("/cs/faq")
apiRouter.get("/cs/notice",noticeDetail);

apiRouter.route("/cs/request").get(getUserRequest).post(userPostRequest);

//////////결제모듈////////////
import {   breakdown,  breakdownDetail,  getInicis,  payInicis,  cancelPay,  cancelPayDetail,  regCard,  getProducts,  getCards,  registerPostInicis,  postFullPayInicis,  cancelCancel,  getPromotions,  changeNextBillingCard,  removeBillingKey, addPromotions,} from "../controllers/user/payController";
import { changeBilling } from "../controllers/user/payController2";

//회원가입후 결제
apiRouter.route("/pay/reginicis").get(getInicis).post(registerPostInicis);
//등록 후 바로 결제 
apiRouter.route("/pay/inicis").get(getInicis).post(postFullPayInicis);
//결제만
apiRouter.route("/pay/payment").post(payInicis);
//결제 취소
apiRouter.post("/pay/cancel",cancelPay);
apiRouter.post("/pay/cancel/detail",cancelPayDetail);
//결제 취소예약 취소
apiRouter.post("/pay/cancel/cancel",cancelCancel);
//결제 내역
apiRouter.get("/pay/breakdown", breakdown);
apiRouter.get("/pay/breakdown/detail", breakdownDetail);
//카드 등록만
apiRouter.route("/pay/regcard").get(getInicis).post(regCard);
//카드 목록
apiRouter.get("/pay/cards", getCards);
//카드 삭제
//apiRouter.post("/pay/cards/delete",removeBillingKey);

//카드변경
apiRouter.post("/pay/cards/change", changeBilling);

//다음 결제 카드 변경
// apiRouter.get("/pay/change", changeNextBillingCard)
//상품 목록
apiRouter.get("/pay/products", getProducts);
//프로모션
apiRouter.get("/pay/promotions", getPromotions);
apiRouter.post("/add/promotions", addPromotions);
export default apiRouter;