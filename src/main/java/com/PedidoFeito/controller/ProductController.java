package com.PedidoFeito.controller;

import com.PedidoFeito.dto.ProductResponse;
import com.PedidoFeito.service.ProductService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @GetMapping
    public List<ProductResponse> getProducts(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return service.search(search, code, category, page, size);
    }
}