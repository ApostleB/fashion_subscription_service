import coolsms from "coolsms-node-sdk";
import smsConfig from "../config/smsConfig.json";

export const sendMessage = (to) => {

    let regex = /[^0-9]/g;
    let result = to.replace(regex, "");

    const messageService = new coolsms(smsConfig.APIKEY,smsConfig.API_SECRET);
    messageService.sendOne({
        to: result,
        from: "029777669",
        text: `Youarethe 본인인증 문자메세지 ${check[0][0].Key}`,
    }).then((success) => {
        return true;
    }).catch((err) => {
        console.log(err);
        return false;
    });
    console.log("문자메세지 발신 성공");
}