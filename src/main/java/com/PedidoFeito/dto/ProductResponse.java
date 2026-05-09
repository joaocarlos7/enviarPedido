package com.PedidoFeito.dto;

import java.math.BigDecimal;

public record ProductResponse(
        Long id,
        String code,
        String name,
        String unit,
        Long categoryId,
        String categoryName,
        BigDecimal price
) {
}