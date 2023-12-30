import { Request, Response } from "express";
import { Product } from "../model/Product";
import { ProductRepo } from "../repository/ProductRepo"

class ProductController {

  async create(req: Request, res: Response) {
    try{
        console.log(`headers: ${JSON.stringify(req.headers)}`)
        console.log(`method: ${JSON.stringify(req.method)}`)
        console.log(`body: ${JSON.stringify(req.body)}`)

        const newProduct = new Product()
        newProduct.name = req.body.name
        newProduct.category = req.body.category
        newProduct.price = req.body.price

        await new ProductRepo().save(newProduct)
        res.status(201).json({
            status: "Created"
        })
    }
    catch(err){
        res.status(500).json({
            status: "Internal Server Error"
        })
    }
  }

  async delete(req: Request, res: Response) {
    try {
      let id = parseInt(req.params["id"]);
      await new ProductRepo().delete(id);

      res.status(200).json({
        status: "Ok!",
        message: "Successfully deleted product!",
      });
    } catch (err) {
      res.status(500).json({
        status: "Internal Server Error!",
        message: "Internal Server Error!",
      });
    }
  }

  async findById(req: Request, res: Response) {
    try {
      let id = parseInt(req.params["id"]);
      const newProduct = await new ProductRepo().retrieveById(id);

      res.status(200).json({
        status: "Ok!",
        message: "Successfully fetched product by id!",
        data: newProduct,
      });
    } catch (err) {
      res.status(500).json({
        status: "Internal Server Error!",
        message: "Internal Server Error!",
      });
    }
  }

  async findByCategory(req: Request, res: Response) {
    try {
      const newProduct = await new ProductRepo().retrieveByCategory(req.params["category"]);

      res.status(200).json({
        status: "Ok!",
        message: "Successfully fetched all categorized products data!",
        data: newProduct,
      });
    } catch (err) {
      res.status(500).json({
        status: "Internal Server Error!",
        message: "Internal Server Error!",
      });
    }
  }

  async findAll(req: Request, res: Response) {
    try {
      const newProduct = await new ProductRepo().retrieveAll();

      res.status(200).json({
        status: "Ok!",
        message: "Successfully fetched all product data!",
        data: newProduct,
      });
    } catch (err) {
      res.status(500).json({
        status: "Internal Server Error!",
        message: "Internal Server Error!",
      });
    }
  }

  async update(req: Request, res: Response) {
    try {
      let id = parseInt(req.params["id"]);
      const newProduct = new Product();

      newProduct.id = id;
      newProduct.name = req.body.name;
      newProduct.category = req.body.category;
      newProduct.price = req.body.price

      await new ProductRepo().update(newProduct);

      res.status(200).json({
        status: "Ok!",
        message: "Successfully updated product data!",
      });
    } catch (err) {
      res.status(500).json({
        status: "Internal Server Error!",
        message: "Internal Server Error!",
      });
    }
  }
}

export default new ProductController()