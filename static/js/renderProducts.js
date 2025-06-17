function renderProducts(productsArr, productsContainer)
{

    productsArr.forEach(product => {

        const productCard = document.createElement('div');
        productCard.classList.add('catalogo__card')

        // Carrosel

        const carousel = document.createElement('div');
        carousel.className = 'carousel slide';
        carousel.setAttribute('data-bs-ride', 'carousel');

        const inner = document.createElement('div');
        inner.className = 'carousel-inner';

        product.images.forEach((image, index) => {

            const carouselItem = document.createElement('div');
            carouselItem.className = 'carousel-item';

            if (index == 0)
            {
                carouselItem.classList.add('active');
            }

            const img = document.createElement('img');
            img.className = 'd-block w-100';
            img.setAttribute('src', image);

            carouselItem.appendChild(img);
            inner.appendChild(carouselItem);

        });

        carousel.appendChild(inner);
        productCard.appendChild(carousel);

        const infoContainer = document.createElement('div');
        infoContainer.classList.add('catalogo__info');

        // Title

        const title = document.createElement('h2')
        title.textContent = product.name;
        title.classList.add('catalogo__titulo');

        infoContainer.appendChild(title);

        // Description

        const description = document.createElement('p');
        description.textContent = product.description;
        description.classList.add('catalogo__descricao');

        infoContainer.appendChild(description);

        //#region Actions

        const actionsGroup = document.createElement('div');
        actionsGroup.classList.add('catalogo__acoes');

        // Btn Ver Mais

        const purchaseButton = document.createElement('a');
        purchaseButton.setAttribute('href', `/product/${product.product_id}`)
        purchaseButton.textContent = 'Ver Mais';
        purchaseButton.classList.add('catalogo__botao');

        actionsGroup.appendChild(purchaseButton);

        // Price

        const price = document.createElement('span');
        purchaseButton.classList.add('catalogo__preco');

        const strong = document.createElement('strong');
        strong.textContent = `${product.price} Bananas`;

        price.appendChild(strong);

        actionsGroup.appendChild(price);

        //#endregion
        
        infoContainer.appendChild(actionsGroup);

        //#endregion

        productCard.appendChild(infoContainer);
        productsContainer.appendChild(productCard);

    });

}

export
{

    renderProducts

}