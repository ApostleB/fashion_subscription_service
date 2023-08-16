import multer from "multer";
import sharp from "sharp";
import db from "./db";
import schedule from "node-schedule";
import dayjs from "dayjs";
import bcrypt from "bcrypt";
import crypto from "crypto";
import base64 from "base-64";

// export const passwordCrtpto = async (req, res, next) => {
//     // const Password = req.body.Password
//     // if(req.body.Password){
//     //    console.log(Password);
//     // }
//     const Password = "123";
    
//     bcrypt.genSalt(10, (err, salt) => {
//         bcrypt.hash(Password, 10, (err, hash) => {
//             //console.log('0', base64.encode(salt));
//             console.log("1",salt);
//             console.log("2",hash);
//             let d = hash.split('$');
//             d = d[d.length - 1];
//             d = d.substring(0, 22);
//             console.log('3', d);
//             bcrypt.compare(Password, hash, (err, result) => {
//                 console.log("result", result);
//             })
//         })
//     })
//     // const encoded = crypto.createHash("sha512").update(Password).digest('base64');
//     // console.log(Password ,encoded);
//     next();
// }

// export const passwordCrtpto = async (req, res, next) => {
//     // const Password = req.body.Password
//     // if(req.body.Password){
//     //    console.log(Password);
//     // }    
//     // const encoded = crypto.createHash("sha512").update(Password).digest('base64');
//     // console.log(Password ,encoded);
//     next();
// }

export const deleteVerifyIdSession = (req, res, next) => {
    if(req.session.VerifyId){
        if( !(req.originalUrl === "/api/user/find/change/password" || req.originalUrl === "/findPass/result" 
        || req.originalUrl === "/api/mypage/change/contact" || req.originalUrl === "/mypage/info") ){
            delete req.session.VerifyId;
            console.log("VerifyId 세션 삭제");
        }
    }
    next();
}

export const deleteMypageLoginOnce = (req, res, next) => {
    const VerifyIdList = [
        "/api/mypage/info/get",
        "/api/mypage/change/login/once",
        "/api/mypage/change/password",
        "/api/mypage/change/contact/check",
        "/api/mypage/change/contact/confirm",
        "/api/mypage/change/contact",
        "/api/mypage/change/info",
        "/api/user/getinfo",
        "/mypage/info",
    ];
    if(req.session.loginOnce){
        if(!(VerifyIdList.includes(req.path))){
            delete req.session.loginOnce;
            console.log("loginOnce 삭제");
        }
    }
    next();
}

export const sessionMiddleware = (req, res, next) => {
    if (req.session.user) {
      if (!req.cookies.FL) {
        console.log("쿠키 재생성");
        let expiryDate = new Date(Date.now() + 60 * 60 * 1000 * 24 * 1); // 24 hour 7일
        res.cookie("FL", true, {
          expires: expiryDate,
          httpOnly: false,
          path: "/",
        });
      }
    } else {
      if (req.cookies.FitboaAPI) {
        console.log("쿠키 삭제");
        res.clearCookie("FitboaAPI");
        res.clearCookie("FL");
      }
    }
    next();
}

export const userFormUploads = multer({
    dest:"userUploads/form/",
    limits: {
        files:5,
        // fileSize: 524288, // 5 Mb
    },
    onError : (err, next) => {
        console.log('error');
        next(err);
    }
})

export const pernsalStylingReview = multer({
    dest:"userUploads/review/",
    limits: {
        files:5,
        // fileSize: 524288, // 5 Mb
    },
    onError : (err, next) => {
        console.log('error');
        next(err);
    }
})

export const adminUpload = multer({ 
    dest: "uploads/"
});

export const isLogin = (req, res, next) => {
    if(!req.session.user){
        res.status(400).json({message:"로그인이 필요합니다."})
    }
}

export const imageResizer = async (req, res, next) => {
    const files = req.files;
    //jpg나 png만 퀄리티 리사이징 가능
    const ContentId = req.body.ContentId ? req.body.ContentId : null;
    const conn = await db();
    files.forEach(async (file) => {
        try{
            //Midium save
            sharp(file.path)
            .resize({width:300})
            .jpeg({ quality: 8})
            .png({ quality:8 }) //progressive:true
            .toFile(`midium/${file.filename}_midium`, (err, info) => {
                if(err) throw err
                console.log("info2 : ", info);
            });
            //Small save
            sharp(file.path)
            .jpeg({ quality: 8})
            .png({ quality:8 }) //progressive:true
            .resize({width:220})
            .toFile(`uploads/small/${file.filename}_small`, (err, info) => {
                if(err) throw err
                console.log("info3 : ", info);
            });
            conn.query(`CALL Admin_Post_Content_Image(?,?,?,?)`, [5, file.originalname,file.filename, "uploads"]);
            conn.release();
            next();
        }catch(err){
            console.log("이미지 리사이징 에러 : ",err);
            conn.release();
            res.status(400).json({message:"이미지 업로드에 실패했습니다."});            
        }
    });
    
}

export const isAdmin = (req, res, next) => {
    if(req.session.adminLoggedIn === true){
        next();
    }else{
        return res.status(400).json("접근 권한이 없습니다.");
    }
}
export const handelRequestDeny = (req, res, next) =>{
    const allowedMethods = ["GET", "POST"];
    if(!allowedMethods.includes(req.method)){
        console.log("Middleware! Deny Anything except GET or POST")
        res.status(405).json("비정상적인 접근입니다.");
    }
    return next();
}

export const traceMiddleware = ('/', (req, res, next) => {
    const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || '').split(':');
    const today = new Date();
    const year = today.getFullYear();
    const month = ('0' + (today.getMonth() + 1)).slice(-2);
    const day = ('0' + today.getDate()).slice(-2);
    const hours = ('0' + today.getHours()).slice(-2); 
    const minutes = ('0' + today.getMinutes()).slice(-2);
    const seconds = ('0' + today.getSeconds()).slice(-2); 

    let dateString = year + '-' + month  + '-' + day + ' ' + hours + ':' + minutes  + ':' + seconds;
    let params = '';
    if (req.method === 'GET') {
        Object.keys(req.query).forEach((key, index) => {
            if (index === 0) params += `${key}: ${req.query[key]}`;
            else params += `, ${key}: ${req.query[key]}`;
        })
    }
    else if (req.method === 'POST') {
        Object.keys(req.body).forEach((key, index) => {
            if (index === 0) params += `${key}: ${req.body[key]}`;
            else params += `, ${key}: ${req.body[key]}`;
        })
    }
    else {
        console.log(`[${dateString}] ip: ${ip[ip.length - 1]}, route: ${req.originalUrl}, unexpected method: ${req.method}`);
        res.status(403).json({ code: 403, message: `unexpected method: ${req.method}` });
        return;
    }

    console.log(`[${dateString}] ip: ${ip[ip.length - 1]}, route: ${req.originalUrl}, method: ${req.method}, params: { ${params} }`);
    next();
});
