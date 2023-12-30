import { Product } from '../model/Product'

interface IProductRepo {
  save(product: Product): Promise<void>;
  update(product: Product): Promise<void>;
  delete(productId: number): Promise<void>;
  retrieveById(productId: number): Promise<Product>;
  retrieveByCategory(category: string): Promise<Product[]>;
  retrieveAll(): Promise<Product[]>;
}

export class ProductRepo implements IProductRepo {

  async save(product: Product): Promise<void> {
    try {
      await Product.create({
        name: product.name,
        category: product.category,
        price: product.price
      });
    } catch (error) {
      throw new Error("Failed to create product!");
    }
  }

  async update(product: Product): Promise<void> {
    try {
      const newProduct = await Product.findOne({
        where: {
          id: product.id,
        },
      });
      if (!newProduct) {
        throw new Error("Product not found!");
      }
      newProduct.name = product.name;
      newProduct.category = product.category;
      newProduct.price = product.price;

      await newProduct.save();
    } catch (error) {
      throw new Error("Failed to create product!");
    }
  }

  async delete(productId: number): Promise<void> {
    try {
      const newProduct = await Product.findOne({
        where: {
          id: productId,
        },
      });
      if (!newProduct) {
        throw new Error("Note not found!");
      }

      await newProduct.destroy();
    } catch (error) {
      throw new Error("Failed to destroy product!");
    }
  }

  async retrieveById(productId: number): Promise<Product> {
    try {
      const newProduct = await Product.findOne({
        where: {
          id: productId,
        }
      });
      if (!newProduct) {
        throw new Error("Product not found!");
      }
      return newProduct;
    } catch (error) {
      throw new Error("Failed to find product!");
    }
  }

  async retrieveByCategory(category: string): Promise<Product[]> {
    try {
     return await Product.findAll({
      where: {
        category: category,
      }
     });
    } catch (error) {
      throw new Error("Failed to find all products!");
    }
  }

  async retrieveAll(): Promise<Product[]> {
    try {
     return await Product.findAll();
    } catch (error) {
      throw new Error("Failed to find all products!");
    }
  }
}