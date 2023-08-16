import express from "express";
import { adminUpload, imageResizer, isAdmin } from "../middlewares";
import { uploadForm, postContent, postContentImage } from "../controllers/admin/adminApiController";

const adminApiRouter = express.Router();

adminApiRouter.route("/content").post(adminUpload.array("files"),postContent, postContentImage);

//회원 관리
adminApiRouter.get("/member");
adminApiRouter.get("/member/search");
adminApiRouter.get("/member/next");
adminApiRouter.get("/member/ruler");
adminApiRouter.get("/member/searche");

//상품 관리
adminApiRouter.get("/product");
adminApiRouter.get("/product/:prductId");

//결제 관리
adminApiRouter.get("/payment");

//콘텐츠 관리
adminApiRouter.get("/contents");

//프로모션 관리
adminApiRouter.get("/promotion");

//CS 관리
adminApiRouter.get("/cs");

export default adminApiRouter;