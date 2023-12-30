import BaseRoutes from "./base/BaseRouter"
import ProductController from "../controller/ProductController"

class ProductRoutes extends BaseRoutes {
  public routes(): void {
    this.router.post("", ProductController.create)
    this.router.patch("/:id", ProductController.update)
    this.router.delete("/:id", ProductController.delete)
    this.router.get("", ProductController.findAll)
    this.router.get("/:category", ProductController.findByCategory)
    this.router.get("/:id", ProductController.findById)
  }
}

export default new ProductRoutes().router

