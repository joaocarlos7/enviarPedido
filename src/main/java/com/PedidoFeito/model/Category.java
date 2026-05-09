package com.PedidoFeito.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "categories")
public class Category {

    @Id
    private Long id;
    private String name;


}
