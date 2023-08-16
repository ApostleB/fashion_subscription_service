export const handelSqlError = (err) => {
    console.log(`handelSqlError SQL STATE = ${err.sqlState} SQL NO = ${err.errno} ERROR TEXT = ${err.text}`);
    
    if(!err){
        return false
    }
    
    
    if(err.errno === 1460){
        return "데이터가 너무 깁니다.";
    }
    else return false;
}