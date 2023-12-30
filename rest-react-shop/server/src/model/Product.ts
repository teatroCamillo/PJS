
import { Model, Table, Column, DataType } from "sequelize-typescript";

@Table({
  tableName: Product.PRODUCT_TABLE_NAME,
})
export class Product extends Model {
  public static PRODUCT_TABLE_NAME = "product" as string;
  public static PRODUCT_ID = "id" as string;
  public static PRODUCT_NAME = "name" as string;
  public static PRODUCT_CATEGORY = "category" as string;
  public static PRODUCT_PRICE = "price" as string;

  @Column({
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: Product.PRODUCT_ID,
  })
  id!: number;

  @Column({
    type: DataType.STRING(100),
    field: Product.PRODUCT_NAME,
  })
  name!: string;

  @Column({
    type: DataType.STRING(255),
    field: Product.PRODUCT_CATEGORY,
  })
  category!: string;

  @Column({
    type: DataType.DECIMAL(10, 2),
    field: Product.PRODUCT_PRICE,
  })
  price!: number;
}

