import path from "path";
import db from "../../db";

import { handelSqlError } from "../../libraries/handleSqlError";


export const applyForm = async (req, res, next) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요한 서비스입니다."})
    }
    const UserId = req.session.user ? req.session.user.Id : null;
    const { Type, Content, Title } = req.body
    const conn = await db();

    const files = req.files ?? [];
    try{
        const apply = await conn.query(`
        CALL 
        Post_Styling_Inquiry(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        [
            UserId, Type, Title, Content,"UserUploads/Form",
            files[0]?.filename ?? null, files[0]?.originalname?? null,
            files[1]?.filename ?? null, files[1]?.originalname?? null,
            files[2]?.filename ?? null, files[2]?.originalname?? null,
            files[3]?.filename ?? null, files[3]?.originalname?? null,
            files[4]?.filename ?? null, files[4]?.originalname?? null,
        ]);
        res.status(200).json(apply);
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

export const getPersnalStylingReview = async (req, res) => {
    
    const page = isNaN(req.query.page) === false ? req.query.page : 1;
    const userId = req.session.user ? req.session.user.Id : null;
    // Get_Reviews
    const conn = await db();
    const reviewIds = [];
    try{
        
        const reviews = await conn.query(`CALL Get_Reviews(?,?,?)`,[userId, typeof(page) === "number" ? page : Number(page), false])        
        delete reviews[1].meta;
        let myDatas = [];
        const reviewData = reviews[1];
        for(let i = 0; i < reviewData.length ; i++){
            let state = true;
            let tempData = {};
            tempData = reviewData[i];
            tempData.Images = [reviewData[i].Image];
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

export const postPersnalStylingReview = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요한 서비스입니다."});
    }
    const files = req.files ?? [];
    const UserId = req.session.user ? req.session.user.Id : null;
    const { ContentId, Content, Rate } = req.body;
    if( !ContentId, !Content, !Rate ){
        return res.status(400).json({message:"항목을 모두 입력해주세요."});
    }
    const conn = await db();
    try{
        const review = await conn.query(`CALL Post_Review(?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        [UserId, Content, Rate,"userUploads/Review",
            files[0]?.filename ?? null,files[0]?.originalname?? null,
            files[1]?.filename ?? null,files[1]?.originalname?? null,
            files[2]?.filename ?? null,files[2]?.originalname?? null,
            files[3]?.filename ?? null,files[3]?.originalname?? null,
            files[4]?.filename ?? null,files[4]?.originalname?? null,
        ]);
        res.status(200).json("success");
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

export const pernsalReviewImageCheck = async (req, res) => {
    const { imageName } = req.params;
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
        try{
            const check = await conn.query(`CALL Image_Name_Check(?,?)`,[userId ?? null, imageName ?? null]);
            const fileName = check[0][0].OriginFileName;
            if(fileName) res.download(path.join(__dirname, `../../../userUploads/review/${imageName}`), fileName);
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

export const detailReview = async (req, res) => {
    const reviewId = Number(req.query.reviewId) ?? null;
    const userId = req.session.user ? req.session.user.Id : null;
    if(!reviewId){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }
    const conn = await db();
    try{
        const review = await conn.query(`CALL Get_Review(?,?)`,[userId, reviewId]);
        delete review[0].meta;
        let reviewData = review[0][0];
        reviewData.Images = [];
        for(let i = 0 ; i < review[0].length ; i++ ){
            reviewData.Images.push(review[0][i].Image);
        }
        if(reviewData.Images[0] === null){
            reviewData.Images = [];
        }        
        delete reviewData.Image
        res.status(200).json(reviewData);
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

    //Get_Review
}