import express, { Application, Request, Response } from "express";
import Database from "./db/Database"
import ProductRouter from "./router/ProductRouter";
import cors from 'cors';

class App {
  public app: Application;

  constructor() {
    this.app = express();
    this.databaseSync();
    this.plugins();
    this.routes();
  }

  protected plugins(): void {

    // allowedOrigins = ['http://localhost:3000'];

    // options: cors.CorsOptions = {
    //   origin: allowedOrigins
    // };

    this.app.use(cors())
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
  }

  protected databaseSync(): void {
    const db = new Database();
    db.sequelize?.sync();
  }

  protected routes(): void {
    this.app.route("/").get((req: Request, res: Response) => {
      res.send("welcome");
    });
    this.app.use("/api/v1/product", ProductRouter);
  }
}

const port: number = 3000;
const app = new App().app;

app.listen(port, () => {
  console.log("Server started successfully!");
});





