package com.PedidoFeito.service;

import com.PedidoFeito.dto.ProductResponse;
import com.PedidoFeito.model.Product;
import com.PedidoFeito.model.ProductPrice;
import com.PedidoFeito.repository.ProductPriceRepository;
import com.PedidoFeito.repository.ProductRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private final ProductRepository repository;
    private final ProductPriceRepository priceRepository;

    public ProductService(ProductRepository repository, ProductPriceRepository priceRepository) {
        this.repository = repository;
        this.priceRepository = priceRepository;
    }

    public List<ProductResponse> search(String search, String code, String category, int page, int size) {
        if (search == null && code == null && category == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Informe ao menos um filtro: search, code ou category."
            );
        }

        Pageable pageable = PageRequest.of(page, size);
        List<Product> products;

        if (code != null) {
            products = repository.findByCode(code, pageable).getContent();
        } else if (search != null && category != null) {
            products = repository.findByNameContainingIgnoreCaseAndCategory_Name(search, category, pageable).getContent();
        } else if (search != null) {
            products = repository.findByNameContainingIgnoreCase(search, pageable).getContent();
        } else {
            products = repository.findByCategory_Name(category, pageable).getContent();
        }

        return toResponseList(products);
    }

    private List<ProductResponse> toResponseList(List<Product> products) {
        List<Long> ids = products.stream()
                .map(Product::getId)
                .toList();

        Map<Long, BigDecimal> priceMap = priceRepository
                .findCurrentPricesByProductIds(ids)
                .stream()
                .collect(Collectors.toMap(
                        pp -> pp.getProduct().getId(),
                        ProductPrice::getPrice
                ));

        return products.stream()
                .map(p -> new ProductResponse(
                        p.getId(),
                        p.getCode(),
                        p.getName(),
                        p.getUnit(),
                        p.getCategory().getId(),
                        p.getCategory().getName(),
                        priceMap.get(p.getId())
                ))
                .toList();
    }
}