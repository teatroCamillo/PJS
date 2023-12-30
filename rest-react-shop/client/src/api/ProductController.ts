import axios from "axios";

class ProductController {

    readonly API_URL: string = "http://localhost:3000/api/v1/product";

    getAllProducts = (category: string) => {
        return axios.get(`${this.API_URL}${category}`)
    }
}

export default new ProductController();