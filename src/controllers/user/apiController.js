import { type } from "express/lib/response";
import db from "../../db";
import { handelSqlError } from "../../libraries/handleSqlError";


export const uploadForm = async (req, res) => {
    return res.render("./upload.pug");

}
export const uploadImage = async (req, res) => {
    const uploadFiles = req.files
    uploadFiles.forEach(image => {
        console.log("파일 이름: ", image.path)
        console.log("저장 폴더: ",image.path,"\n");
    });
    res.status(200).json("success")
}

export const setBodyType = async (req, res) =>{
    const {
        Shoulder,
        Chest,
        Waist,
        Arm,
        Leg,
        Thigh,
    } = req.body;
    
    if(!req.session.user){
        res.status(400).json({message:"로그인을 해주세요."})
    }
    const UserId = Number(req.session.user.Id);
    // console.log("setBodyType",`
    // "UserId":${UserId}
    // "Shoulder":${Shoulder}
    // "Chest":${Chest}
    // "Waist":${Waist}
    // "Arm":${Arm}
    // "Leg":${Leg}
    // "Thigh":${Thigh}`
    // )
    if(!UserId,!Shoulder,!Chest,!Waist,!Arm,!Leg,!Thigh){
        return res.status(400).json({message:"항목을 모두 입력해주세요."})
    }
    const conn = await db();
    try{
        const setBodyType = await conn.query(`CALL Set_BodyType_Service(?,?,?,?,?,?,?)`, [2, Shoulder, Chest, Waist, Arm, Leg, Thigh])
        res.status(200).json("success");
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

export const selectBodyType = async (req, res, next) => {
    // Set_BodyType_Service2
    if(!req.session.user){
        return res.status(400).json({message:"로그인이 필요한 서비스입니다."});
    }
    const UserId = req.session.user ? req.session.user.Id : null;
    const BodyType = req.body.BodyType ? req.body.BodyType : null;
    if(!BodyType){
        res.status(400).json({message:"체형을 선택해주세요."})
    }

    const conn = await db();
    try{
        const type = await conn.query(`CALL Set_BodyType_Service2(?,?)`, [UserId, BodyType]);
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


export const addDeliver = async (req, res) =>{
    if(!req.session.user){
        return res.status(400).json("로그인이 필요합니다.")
    }
    else{
        if(!req.session.user.IsSub === 1){
            return res.status(400).json("구독이 필요한 서비스입니다.");
        }
    }
    console.log("테테테테",
      (Name,
      Contact,
      RoadAddress,
      JibunAddress,
      ExtraAddress,
      PostCode,
      AddressType)
    );

    const UserId = req.session.user ? req.session.user.Id : null;
    const { Name, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType } = req.body
    if(!Name, !Contact, !RoadAddress, !JibunAddress, !ExtraAddress, !PostCode, !AddressType){
        return res.status(400).json({message:"항목을 모두 입력해주세요."});
    }
    const conn = await db();
    try{
        const deliver = await conn.query(`CALL Add_Delivery(?,?,?,?,?,?,?,?)`, [UserId, Name, Contact, RoadAddress, JibunAddress, ExtraAddress, PostCode, AddressType])
        res.status(200).json("success");
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


export const csHome = async (req, res) => {
    // const typeNum = req.query.typeNum ? Number(req.query.typeNum) : null; // 0:공지사항 1:FAQ
    let typeNum = req.query.typeNum === "0" ? Number(req.query.typeNum) : (req.query.typeNum === "1" ? 1 : null ) ;
    const search = req.query.search ? req.query.search : null;
    
    console.log("TYPENUM",typeNum, "SEARCH : ",search);
    const conn = await db();
    try{
        const cs = await conn.query(`CALL Get_Customer_Services(?,?)`,[typeNum, search]);
        res.status(200).json(cs[0])
    }catch(err){
        // console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

export const getUserRequest = async (req, res) => {
    console.log("asd");
    const conn = await db();
    try{
        const inquiries = await conn.query(`CALL Get_Inquiries(?)`,[req.session.user ? req.session.user.Id : null]);
        res.status(200).json(inquiries[0])
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }
}

//Get_Customer_Services_Detail
export const noticeDetail = async (req, res) => {
    const noticeId = isNaN(req.query.noticeId) === false ? Number(req.query.noticeId) : null ;
    console.log(noticeId);
    if(noticeId === undefined || noticeId === null){
        return res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }
    const conn = await db();
    try{
        const inquiries = await conn.query(`CALL Get_Customer_Services_Detail(?)`,[noticeId]);
        res.status(200).json(inquiries[0][0])
    }catch(err){
        console.log(err);
        if(handelSqlError(err)){
            res.status(400).json({message:err.text});
        }
        else res.status(400).json({message:"잠시후 다시 시도해주세요."})
    }finally{
        conn.release();
        return;
    }

}


export const userPostRequest = async (req, res, next) => {
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
            UserId, Type, Title, Content,null,
            null, null,
            null, null,
            null, null,
            null, null,
            null, null,
        ]);
        res.status(200).json(apply);
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
