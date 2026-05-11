package com.enviarPedido.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "products")

public class Product {

    @Id
    private Long id;
    private String code;
    private String name;
    private String unit;


    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;

}
