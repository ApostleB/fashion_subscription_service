import mariadb from "mariadb";
import config from "./config/dbConfig.json";

const pool = mariadb.createPool(config);

async function db() {
    let conn;
    try {
        console.log("DB연결");
        conn = await pool.getConnection();
    } catch(err){
        console.error(err);
    } finally{
        if(conn) return conn;
    }
}

module.exports = db;