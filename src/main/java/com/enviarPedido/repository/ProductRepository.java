package com.enviarPedido.repository;

import com.enviarPedido.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findByNameContainingIgnoreCase(String name, Pageable pageable);

    Page<Product> findByCode(String code, Pageable pageable);

    Page<Product> findByCategory_Name(String category, Pageable pageable);

    Page<Product> findByNameContainingIgnoreCaseAndCategory_Name(
            String name,
            String category,
            Pageable pageable
    );
}