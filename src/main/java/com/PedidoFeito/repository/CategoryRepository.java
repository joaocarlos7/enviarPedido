package com.PedidoFeito.repository;

import com.PedidoFeito.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}
