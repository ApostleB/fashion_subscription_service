export const handelSqlError = (err) => {
    console.log(`handelSqlError SQL STATE = ${err.sqlState} SQL NO = ${err.errno} ERROR TEXT = ${err.text}`);

    if(!err){
        return false
    }
    if(err.sqlState === "FB000") return true;
    else if(err.sqlState === "FB001") return true;
    else if(err.sqlState === "FB002") return true;
    else if(err.sqlState === "FB003") return true;
    else if(err.sqlState === "FB004") return true;
    else if(err.sqlState === "FB005") return true;
    else if(err.sqlState === "FB006") return true;
    else if(err.sqlState === "FB007") return true;
    else if(err.sqlState === "FB008") return true;
    else if(err.sqlState === "FB009") return true;
    else if(err.sqlState === "FB010") return true;
    else if(err.sqlState === "FB011") return true;
    else if(err.sqlState === "FB012") return true;
    else if(err.sqlState === "FB013") return true;
    else if(err.sqlState === "FB014") return true;
    else if(err.sqlState === "FB015") return true;
    else if(err.sqlState === "FB016") return true;
    else if(err.sqlState === "FB100") return true;
    else if(err.sqlState === "FB999") return true;
    else return false;
}