import { status } from "express/lib/response";
import db from "../../db";
import { handelSqlError } from "../../libraries/handleSqlError";
import { adminUpload } from "../../middlewares";

export const uploadForm = async (req, res) => {
    return res.render("upload")
}

export const uploadImage = async (req, res) => {
    console.log(req.files);
    return res.status(200).json({"files":req.files})
}

export const postContent = async (req, res, next) => {
    console.log("POSTCONTENT 에서", req.files);
    const { Title,BodyType,Threshold, Type} = req.body;    
    console.log("REQ FILES",req.files);
    /////임시 인증
    const Author = "admin", AuthorId=1;
    /////임시 인증 끝
    if((Title, Type) === (undefined, null, "") ||isNaN(BodyType,Threshold)){
        console.log("실패");
        return res.status(400).json("항목을 모두 입력해주세요.");
    }
    console.log("성공");
    const conn = await db();
    try{
        const content = await conn.query(`CALL Admin_Post_Content(?,?,?,?,?)`,[Title, AuthorId, BodyType, Threshold, Type])
        req.body.ContentId = content[0][0].ContentId;
        delete content[0].meta;
        conn.release();
        // console.log("PROCEDURE CALL SUCESS : Admin_Post_Content \n");
        next();
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
        conn.release();
        return;
    }
}

export const postContentImage = async (req, res) => {
    const ContentId = req.body.ContentId;
    const FilePath = "uploads/"
    const files = req.files;
    const conn = await db();

    try{
        //Admin_Post_Content_Image
        let imageTry = [];
        for(let i = 0 ; i < files.length ; i++){
            try{
                if(i !== 0){
                    imageTry.push(await conn.query(`CALL Admin_Post_Content_Image(?,?,?,?,?)`, [ContentId, files[i].originalname, files[i].filename,FilePath, false]))
                    console.log("섬네일아닌거 OK");
                }
                else {
                    imageTry.push(await conn.query(`CALL Admin_Post_Content_Image(?,?,?,?,?)`, [ContentId, files[i].originalname, files[i].filename,FilePath, true]))
                    console.log("섬네일인거");
                }                
                
            }catch(err){
                console.log("2ERROR",err);
                const failed = await conn.query(`CALL Admin_Delete_Content(?)`,[ContentId]);
                console.log("삭제 완료", failed, "END");
                return res.status(400).json("게시물 업로드에 실패했습니다.");
            }
        }        
        // Admin_Post_Content_End
        // 성공시
        const success = await conn.query(`CALL Admin_Post_Content_End(?)`,[ContentId]);
        console.log("IMAGE TRY ",imageTry ,"AND" ,"Success : ", success);
        res.status(200).json(success);
    }catch(err){
        console.log("1ERROR",err);
        const failed = await conn.query(`CALL Admin_Delete_Content(?)`,[ContentId]);

        //cleanFile(file)
        
        return res.status(400).json({message:"업로드 실패 1ERROR"});
    }finally{
        conn.release();
        return;
    }
}

async function cleanFile(files) {
    const filePath = path.join(`../../../${files[0].FilePath}`);
    for(let i = 0 ; i < files.length ; i++){
        fs.unlink(files[i].filename, (err) => {
            if(err){
                console.log("ERROR : ",err);
            }
        })    
    }
}
