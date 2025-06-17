import { fetchApi } from './fetchFunction.js';

const itemsCart = document.querySelector('.cart__items');
const valorTotal = document.getElementById('totalValor');
const finalizarCompra = document.getElementById('cart__btn');

async function renderCart() {

    const response = await fetchApi('/api/carts/get-by-user');

    if (response.status_code == 200) {

        const cartID = response.data.cart_id;
        let cart = await fetchApi(`/api/carts/get/${cartID}`);

        if (cart.status_code == 200) {

            cart = cart.data;

            cart.products.forEach(product => {

                const cartProductContainer = document.createElement('article');
                cartProductContainer.className = 'cart__item d-flex align-items-center p-3 mb-3 bg-warning rounded';

                const img = document.createElement('img');
                img.src = product.image;
                img.alt = product.name;
                img.className = 'cart__item-image me-3';
                img.style.width = '80px';
                img.style.height = 'auto';

                cartProductContainer.appendChild(img);

                const infoDiv = document.createElement('div');
                infoDiv.className = 'cart__item-info flex-grow-1';

                const title = document.createElement('h2');
                title.className = 'cart__item-title';
                title.textContent = `${product.quantity} - ${product.name}`;

                const description = document.createElement('p');
                description.className = 'cart__item-description mb-1';
                description.textContent = product.description;

                infoDiv.appendChild(title);
                infoDiv.appendChild(description);
                cartProductContainer.appendChild(infoDiv);

                const priceDiv = document.createElement('div');
                priceDiv.className = 'cart__item-price text-end';

                const priceText = document.createElement('p');
                priceText.className = 'fw-bold mb-2';
                priceText.innerHTML = `Valor: <span class="text-dark">${product.price * product.quantity} Bananas</span>`;

                const removeBtn = document.createElement('button');
                removeBtn.className = 'cart__item-remove btn btn-danger btn-sm';
                removeBtn.textContent = 'Remover';

                removeBtn.addEventListener('click', async function () {

                    await fetchApi(`/api/carts/delete-product/${cartID}/${product.cart_product_id}`);

                    location.reload();

                });

                priceDiv.appendChild(priceText);
                priceDiv.appendChild(removeBtn);
                cartProductContainer.appendChild(priceDiv);

                itemsCart.appendChild(cartProductContainer);

            });

            valorTotal.textContent = `${cart.products.reduce((sum, product) => sum + parseFloat(product.price) * product.quantity, 0)} Bananas`;

            finalizarCompra.addEventListener('click', async function () {

                await fetchApi(`/api/carts/finish/${cartID}`);

                location.reload();

            });

        }

        else {
            Swal.fire({
                title: "Erro",
                text: "O carrinho não contém nenhum item",
                icon: "sucess",
                interval: 1000
            })

        }

    }

    else {
        location.href = '/login';
    }

}

document.addEventListener('DOMContentLoaded', async function () {

    await renderCart();

});