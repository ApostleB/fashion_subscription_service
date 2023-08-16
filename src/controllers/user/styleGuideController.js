import db from "../../db";
import path from "path";
import { handelSqlError } from "../../libraries/handleSqlError";

export const styleGuideContents = async (req, res) => {
    const UserId = req.session.user ? req.session.user.Id : null;
    const search = req.query.search ? req.query.search : null;
    const page = req.query.page ? req.query.page : null;
    const conn = await db();
    try{
        const contents = await conn.query(`CALL Get_SG_Contents(?,?,?)`,[UserId, search, page]);
        res.status(200).json({contents:contents[0], contentsCount: contents[1][0]});
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

export const styleGuideContent = async (req, res) => {
    // if(!req.session.user){
    //     return res.status(400).json("로그인이 필요합니다.")
    // }
    const userId = req.session.user ? req.session.user.Id : null;
    const contentId = req.query.contentId ? req.query.contentId : null;
    const conn = await db();
    try{
        const content = await conn.query(`CALL Get_SG_Content(?,?)`,[userId, Number(contentId)]);
        res.status(200).json(content[0]);
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }
    finally{
        conn.release();
        return;
    }
}

export const nextStyleGuideContent = async (req, res) => {
    if(!req.session.user){
        return res.status(400).json("로그인이 필요합니다.")
    }
    const userId = req.session.user ? req.session.user.Id : null;
    const contentId = req.query.contentId ? req.query.contentId : null;
    const conn = await db();
    try{
        const nextContent = await conn.query(`CALL Get_Next_SG_Content(?,?)`,[userId, Number(contentId)]);
        res.status(200).json({prev:nextContent[0][0] ?? null , next:nextContent[1][0] ?? null});
    }catch(err){
        if(handelSqlError(err)){
            res.status(400).json({message:err.text})
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
}


export const styleImagePermissionCheck = async (req, res) =>{
    
    const { imageName } = req.params;
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

export const highViewStyleGuideContents = async (req, res) =>{
    const userId = req.session.user ? req.session.user.Id : null;
    const contentId = req.query.contentId ? req.query.contentId : null;
    if(contentId === null){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
    const conn = await db();
    try{
        const view = conn.query(`CALL High_View_SG_Contents(?,?)`,[userId, contentId]);
        res.status(200).json(view[0]);
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

export const imagePermissionCheck = async (req, res) =>{
    const { imageName } = req.params
    const userId = req.session.user ? req.session.user.Id : null;
    const conn = await db();
    
    try{
        const check = await conn.query(`CALL Image_Permission_Check(?,?)`,[userId, imageName]);
        const fileName = check[0][0].FileName;
        if (fileName) res.download(path.join(__dirname, `../../uploads/${imageName}`), fileName);
    }catch(err){
        if (handelSqlError(err)) res.status(400).json(err.text);
        else res.status(400).json({message:"잠시후 다시 시도해주세요."});
    }finally{
        conn.release();
        return;
    }
}



/////////////////////////////////////리뷰
export const getStyleReview = async (req, res) => {
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

export const postStyleReview = async (req, res) => {
    
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