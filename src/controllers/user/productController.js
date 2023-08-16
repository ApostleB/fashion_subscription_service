import db from "../../db";
import { handelSqlError } from "../../libraries/handleSqlError";

export const everyOneContent = (req, res) => {
    //비회원 미구독회원 구독회원
    //req정보에 user정보가 있나 없나
    const {
        user
    } = req.body;
    if(user){
        //회원, 미구독회원을 위한 상품들
        if(user.subscribe === true){
            //구독회원 처리
            const productList = {
                "상품1":"구독회원 상품1",
                "상품2":"구독회원 상품2",
            };
            return res.status(200).json({productList});
        }        
        //미구독 회원 처리
        const productList = {
            "상품1":"미구독자 상품1",
            "상품2":"미구독자 상품2",
        };
        
        return res.status(200).json({productList});
    }    
    //비회원에 대한 상품들
    const productList = {
            "상품1":"비회원 상품1",
            "상품2":"비회원 상품2",
        };
    return res.status(200).json({productList});
}

export const getProduct = async (req, res) => {
    // Get_Products
    const connection = await db();
    if (connection) {
        try{
            const products = await connection.query(`CALL Get_Products`);
            return res.status(200).json(products[0]);
        }catch(err){
            if(handelSqlError(err)){
                connection.release();
                return res.status(400).json({message:err.text});
            }
            else res.status(400).json({message: "잠시후 다시 시도해주세요."});
        }finally{
            connection.release();
            return;
        }
    }
    
    res.status(400).json({message: "잠시후 다시 시도해주세요."});
}
