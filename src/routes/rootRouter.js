import express from "express"

const rootRouter = express.Router();

rootRouter.route("/").get((req, res) => { res.send("root") });


export default rootRouter;