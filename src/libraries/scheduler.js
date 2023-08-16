import dayjs from "dayjs";
import db from "../db";
import crypto from "crypto";

export const payScheduler = async (req, res) => {
    const year = dayjs().format("YY");
    const month = dayjs().format("MM");
    const days = dayjs().format("DD");
    const hour = dayjs().format("hh");
    const miniute = dayjs().format("mm");
    const seconds = dayjs().format("ss");
    console.log(`${year}년 ${month}월 ${days}일 ${hour}시 ${miniute}분 ${seconds}초`);
    
    const get = await getBillingScheduler();
    console.log(get);
    return get
}

const getBillingScheduler = async () => {
    const conn = await db();
    try{
        const getBillSchedule = conn.query(`CALL Get_Billing_Scheduler()`);
        conn.release();
        return getBillSchedule
    }catch(err){
        conn.release();
        return err;
    }
}