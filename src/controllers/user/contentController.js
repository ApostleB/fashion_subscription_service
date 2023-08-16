import db from "../../db";
import path from "path";
import { handelSqlError } from "../../libraries/handleSqlError";
import { type } from "express/lib/response";
import { reset } from "nodemon";

export const getMainContent = async (req, res) => {
    let {
        isCustom 
    } = req.query;
    const userId = req.session.user ? req.session.user.Id : null;
    isCustom === "true" ? isCustom = true : isCustom = false;

    const conn = await db();
    try{
        const mainContent = await conn.query(`CALL Get_Main_Contents(?,?)`,[isCustom, userId]);
        res.status(200).json(mainContent[0]);
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

export const checkCanCustom = async (req, res) =>{
    console.log("check Custom");
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        const check = await conn.query(`CALL Check_Can_Custom(?)`,[userId])
        res.status(200).json(check[0][0]);
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

export const getContent = async (req, res) => {
    const contentId = Number(req.query.contentId);
    const userId = req.session.user ? req.session.user.Id : null;
    
    const conn = await db();
    if (conn) {
        try{
            const content = await conn.query(`CALL Get_Content(?,?)`,[userId, contentId]);    
            res.status(200).json(content[0])
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

    res.status(400).json({message:"잠시후 다시 시도해주세요."});
}

//Get_Contents
export const getContents = async (req, res) => {
    const isCustom = req.query.isCustom === "true" ? true : false;
    const search = req.query.search === null | "" ? null : req.query.search;
    const page = Number(req.query.page);
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        const contents = await conn.query(`CALL Get_Contents(?,?,?,?)`,[isCustom, userId, search, page]);
        res.status(200).json({contents:contents[0], contentsCount : contents[1][0]})
    }catch(err){
        if(err.sqlState === '22001'){
            if(err.errno === 1406){
                return res.status(400).json({message:"검색어가 너무 깁니다."});
            }
        }
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}
export const getContentReview = async (req, res) => {
    const { contentId} = req.query;
    const userId = req.session.user ? req.session.user.Id : null;
    if(!req.session.user){
        return res.status(400).json("로그인이 필요합니다.");
    }
    if(!contentId){
        return res.status(400).json("Content ID가 없습니다.");
    }
    const conn = await db();
    try{
        const review = await conn.query(`CALL Get_Content_Reviews(?,?)`, [userId,contentId]);
        res.status(200).json(review[0]);
    } catch(err){
        if(handelSqlError(err)){
            res.status(400).json({"message":err.text});
        }
        else res.status(400).json({"message":"잠시후 다시 시도해주세요."});
    } finally{
        conn.release();
        return;
    }
}

export const getNextContent = async (req, res) => {
    const {
        contentId
    } = req.query;
    if(!req.session.user){
        return res.status(400).json({"message":"로그인이 필요합니다."});
    }
    const userId = req.session.user.Id;
    if(!contentId){
        return res.status(400).json({"message":"잠시후 다시 시도해주세요."});
    }
    const conn = await db();
    try{
        const nextContent = await conn.query(`CALL Get_Next_Content(?,?)`,[userId, Number(contentId)]);
        res.status(200).json({prev:nextContent[0][0] ?? null , next:nextContent[1][0] ?? null})
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

export const getPopularContent = async (req, res) => {
    const {contentId} = req.query;
    if(!req.session.user){
        return res.status(400).json({"message":"로그인이 필요합니다."});
    }
    else if(!contentId){
        return res.status(400).json({"message":"잠시후 다시 시도해주세요."});
    }
    else{
        const userId = req.session.user.Id;
    }
    const conn = await db();
    try{
        const popularContent = await conn.query(`CALL Get_Popular_Contents(?,?)`,[Number(userId), Number(contentId)])
        res.status(200).json(popularContent[0])
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

export const postContentReview = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({"message":"로그인이 필요합니다."});
    }
    const { ContentId, ReviewId, ReviewContent} = req.body;
    if(ReviewId){
        if(typeof(ReviewId) !== "number"){
            return res.status(400).json({"message":"잠시후 다시 시도해주세요."});
        }
    }
    if(typeof(ContentId) !== "number" ){
        return res.status(400).json({"message":"잠시후 다시 시도해주세요."});
    }if(!ReviewContent){
        return res.status(400).json({"message":"내용을 입력해주세요."});
    }
    const UserId = req.session.user.Id;
    const conn = await db();
    try{
        const createReview = await conn.query(`CALL Post_Content_Review(?,?,?,?)`,[UserId, ContentId, ReviewId, ReviewContent]);
        res.status(200).json({message:"리뷰가 등록 되었습니다. 감사합니다!", item:createReview[0][0]});
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

export const highViewContent = async (req, res) => {
    const {contentId} = req.query;    
    if(!req.session.user){
        return res.status(400).json({message:"로그인을 먼저 해주세요."});
    }if(!contentId){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }
    const userId = req.session.user.Id;
    const conn = await db();
    try{
        const content = await conn.query(`CALL High_View_Contents(?,?)`,[userId, Number(contentId)]);
        res.status(200).json(content[0]);
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

export const contentImagePermissionCheck = async (req, res) =>{
    const { imageName } = req.params
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        const check = await conn.query(`CALL Image_Permission_Check(?,?)`,[userId, imageName]);
        const fileName = check[0][0].FileName;
        if (fileName) res.download(path.join(__dirname, `../../../uploads/${imageName}`), fileName);
    }catch(err){
        if (handelSqlError(err)) res.status(400).json(err.text);
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}

// 38645546ffc3981089488de5b419223902

export const addBookmark = async (req, res) => {
    const IsAdd = req.body.IsAdd === true ? true : false;
    const ContentId = Number(req.body.ContentId);    
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const UserId = req.session.user.Id ? req.session.user.Id : null;
    const conn = await db();
    try{
        const add = await conn.query(`CALL Add_Bookmark(?,?,?)`,[UserId, Number(ContentId), IsAdd]);
        res.status(200).json("북마크가 등록되었습니다.")
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


export const getBookmark = async (req, res) => {
    const contentId = Number(req.query.contentId);
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const userId = req.session.user.Id ? req.session.user.Id : null;
    const conn = await db();
    try{
        const bookmark = await conn.query(`CALL Get_Bookmark(?,?)`,[userId, contentId]);
        res.status(200).json(bookmark[0][0])
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

export const setSMSAgree = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const userId = req.session.user ? req.session.user.Id : null;
    const IsOn = req.body.IsOn;
    
    const conn = await db();
    try{
        const agree = await conn.query(`CALL Set_SMS_Agree(?,?)`,[userId, IsOn]);
        res.status(200).json("success")
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

export const setEmailAgree = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const userId = req.session.user ? req.session.user.Id : null;
    const IsOn = req.body.IsOn;
    const conn = await db();
    try{
        const agree = await conn.query(`CALL Set_Email_Agree(?,?)`,[userId, IsOn]);
        res.status(200).json("success")
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

export const getSettings = async (req, res) => {    
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요합니다."});
    }
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    try{
        const getSetting = await conn.query(`CALL Get_Settings(?)`,[userId])
        res.status(200).json(getSetting[0][0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json("잠시후 다시 시도해주세요.")
    }finally{
        conn.release();
        return;
    }
}   
