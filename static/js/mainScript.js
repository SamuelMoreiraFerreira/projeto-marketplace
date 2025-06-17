//#region Carrosel

const carousel = document.querySelector('.carousel');

new bootstrap.Carousel(carousel, {

    interval: 2000,
    touch: false

});

//#endregion

import { renderProducts } from "./renderProducts.js";
import { fetchApi } from "./fetchFunction.js";

const highlightsContainer = document.querySelector('.main__destaques');

document.addEventListener('DOMContentLoaded', async function () {

    // Destaques

    const highlights = await fetchApi('/api/products/get-highlights/4');
    renderProducts(highlights, highlightsContainer);

});