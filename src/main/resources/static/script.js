

    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    let searchTimeout;

    async function loadCategories() {
    const response = await fetch('/categories');
    const categories = await response.json();

    console.log('Categorias carregadas:', categories);

    const categoriesDiv = document.getElementById('categories');
    categoriesDiv.innerHTML = '';

    categories.forEach(category => {
        const item = document.createElement('div');
        item.textContent = category.name;

        item.onclick = () => {
            loadProductsByCategory(category.name);
        };

        categoriesDiv.appendChild(item);
    });
}
    async function loadProductsByCategory(categoryName) {
    const response = await fetch(`/products?category=${encodeURIComponent(categoryName)}&page=0&size=50`);
    const products = await response.json();

    renderProducts(products);
}

    function renderProducts(products) {
    const productsDiv = document.getElementById('products');
    productsDiv.innerHTML = '';

    products.forEach(product => {
        const existing = cart.find(item => item.id === product.id);
        const quantity = existing ? existing.quantity : 0;

        const item = document.createElement('div');

        item.innerHTML = `
        <strong>${product.name}</strong>

        <div class="product-meta">
        Código: ${product.code}<br>
        Embalagem: ${product.unit}
        </div>

        <span class="price">R$ ${product.price ?? '-'}</span>

        <div class="quantity-control">
        <button class="decrease">-</button>
        <span class="quantity-value">${quantity}</span>
        <button class="increase">+</button>
        </div>
`;



        item.querySelector('.increase').onclick = () => {
            addToCart(product);
            renderProducts(products);
        };

        item.querySelector('.decrease').onclick = () => {
            decreaseQuantity(product.id);
            renderProducts(products);
        };

        productsDiv.appendChild(item);
    });
}
    function addToCart(product) {
    const existing = cart.find(item => item.id === product.id);

    if (existing) {
        existing.quantity++;
    } else {
        cart.push({
            ...product,
            quantity: 1
        });
    }
    saveCart();
    renderCart();
}
    function renderCart() {
        const cartDiv = document.getElementById('cart');
        cartDiv.innerHTML = '';

        cart.forEach(item => {
            const div = document.createElement('div');

            div.innerHTML = `
            <strong>${item.name}</strong><br>
            Código: ${item.code}<br>
            Embalagem: ${item.unit}<br>
            Preço ref.: R$ ${item.price ?? '-'}<br>
            Quantidade solicitada: ${item.quantity}<br>
            <button type="button" class="decrease">-</button>
            <button type="button" class="increase">+</button>
            <button type="button" class="remove">Remover</button>
        `;

            div.querySelector('.increase').onclick = () => increaseQuantity(item.id);
            div.querySelector('.decrease').onclick = () => decreaseQuantity(item.id);
            div.querySelector('.remove').onclick = () => removeFromCart(item.id);

            cartDiv.appendChild(div);
        });
    }
    function increaseQuantity(productId) {
        const item = cart.find(item => item.id === productId);

        if (item) {
            item.quantity++;
            saveCart();
            renderCart();
        }
    }
    function decreaseQuantity(productId) {
        const item = cart.find(item => item.id === productId);

        if (!item) return;

        item.quantity--;

        if (item.quantity <= 0) {
            removeFromCart(productId);
            return;
        }
        saveCart();
        renderCart();
    }
    function removeFromCart(productId) {
        cart = cart.filter(item => item.id !== productId);
        saveCart();
        renderCart();
    }
    function sendToWhatsApp() {
    if (cart.length === 0) {
        alert('Carrinho vazio.');
        return;
    }

    const sellerPhone = '5515996996901';

    let message = 'Pedido:%0A%0A';

    cart.forEach(item => {
        const nameShort = item.name.substring(0, 40);

        message += `${item.quantity}x [*${item.code}*] ${nameShort}%0A`;
        message += `Un: ${item.unit} | Ref: R$ ${item.price ?? '-'}%0A%0A`;
    });

    message += 'Obs: valores sujeitos à confirmação.';

    window.open(`https://wa.me/${sellerPhone}?text=${message}`, '_blank');
}
    function saveCart() {
    localStorage.setItem('cart', JSON.stringify(cart));
}

    document.addEventListener('DOMContentLoaded', () => {
    loadCategories();
    renderCart();

    document.getElementById('whatsappButton').onclick = sendToWhatsApp;
});
    document.getElementById('searchInput').addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        const value = e.target.value;

        searchTimeout = setTimeout(() => {
            if (value.length === 0) return;

            fetch(`/products?search=${encodeURIComponent(value)}&page=0&size=20`)
                .then(res => res.json())
                .then(renderProducts);
        }, 400);});