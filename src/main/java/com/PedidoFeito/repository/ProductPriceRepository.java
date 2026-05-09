package com.PedidoFeito.repository;

import com.PedidoFeito.model.ProductPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductPriceRepository extends JpaRepository<ProductPrice, Long> {

    Optional<ProductPrice> findByProductIdAndValidUntilIsNull(Long productId);

    @Query("SELECT pp FROM ProductPrice pp WHERE pp.product.id IN :productIds AND pp.validUntil IS NULL")
    List<ProductPrice> findCurrentPricesByProductIds(@Param("productIds") List<Long> productIds);
}